# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

from __future__ import annotations

import os
import threading
import time
import numpy as np
from pathlib import Path
from typing import Optional
from dataclasses import dataclass

from .common import SanitizeVector
from .common import ClampUint64
from .common import SanitizeFloat
from .common import ClampUint32
from .common import ClampUint8

os.environ.setdefault("MAVLINK20", "1")
from pymavlink import mavutil

mavutil.set_dialect("common")

K_ALL_HIL_SENSOR_FIELDS = 8191


@dataclass
class OmniBridgeConfig:
  model: Path = None
  mavlink_host: str = "127.0.0.1"
  mavlink_port: int = 4560
  px4_hover_thrust: float = 0.50
  real_time_factor: float = 1.0


class OmniBridge:

  def __init__(self, host: str, port: int) -> None:
    self.host_ = host
    self.port_ = port
    self.mav_handle_ = None
    self.was_connected_ = False
    self.reader_thread_ = None
    self.reader_thread_lock_ = threading.Lock()
    self.reader_thread_stop_ = threading.Event()
    self.heartbeat_time_ = 0.0
    self.armed_ = False
    self.received_actuator_ = False
    self.actuator_controls_: Optional[np.ndarray] = None

  def Connect(self) -> None:
    endpoint = f"tcpin:{self.host_}:{self.port_}"
    self.mav_handle_ = mavutil.mavlink_connection(endpoint,
                                                  source_system=1,
                                                  source_component=200)

    print(f"[OmniBridge] Listening for PX4 on {endpoint}")

    self.StartReaderThread()

  def StartReaderThread(self) -> None:
    if self.mav_handle_ is None or self.reader_thread_ is not None:
      return

    self.reader_thread_ = threading.Thread(
        target=self.ReaderThreadCallback,
        name="mav_reader",
        daemon=True,
    )
    self.reader_thread_.start()

  def ReaderThreadCallback(self) -> None:
    reader = self.mav_handle_

    while not self.reader_thread_stop_.is_set():
      try:
        msg = reader.recv_match(blocking=True, timeout=0.1)
      except Exception:
        continue

      if msg is None:
        continue

      msg_type = msg.get_type()

      if msg_type == "HEARTBEAT":
        self.heartbeat_time_ = time.time()
        continue

      if msg_type == "HIL_ACTUATOR_CONTROLS":
        controls = np.array(msg.controls, dtype=float)
        armed = bool(msg.mode & mavutil.mavlink.MAV_MODE_FLAG_SAFETY_ARMED)

        with self.reader_thread_lock_:
          self.armed_ = armed
          self.received_actuator_ = True
          self.actuator_controls_ = controls

  def Connected(self) -> bool:
    return bool(self.mav_handle_ is not None and
                getattr(self.mav_handle_, "port", None) is not None)

  def Close(self) -> None:
    self.reader_thread_stop_.set()
    if self.reader_thread_ is not None and self.reader_thread_.is_alive():
      self.reader_thread_.join(timeout=1.0)

    if self.mav_handle_ is not None:
      try:
        self.mav_handle_.close()
      except Exception:
        pass

  def ConnectionStateChanged(self) -> Optional[bool]:
    connected = self.Connected()
    if connected == self.was_connected_:
      return None
    self.was_connected_ = connected
    return connected

  def SendHeartbeat(self) -> None:
    if self.mav_handle_ is None:
      return

    now = time.time()
    if now - self.heartbeat_time_ < 1.0:
      return

    self.mav_handle_.mav.heartbeat_send(
        mavutil.mavlink.MAV_TYPE_GENERIC,
        mavutil.mavlink.MAV_AUTOPILOT_INVALID,
        0,
        0,
        0,
    )

    self.heartbeat_time_ = now

  def SendHilSensorData(
      self,
      timestamp_us: int,
      accel_frd: np.ndarray,
      gyro_frd: np.ndarray,
      mag_frd: np.ndarray,
      pressure_hpa: float,
      pressure_alt_m: float,
      temperature_c: float = 20.0,
  ) -> None:
    if self.mav_handle_ is None:
      return

    accel = SanitizeVector(accel_frd, 3)
    gyro = SanitizeVector(gyro_frd, 3)
    mag = SanitizeVector(mag_frd, 3)

    self.mav_handle_.mav.hil_sensor_send(
        ClampUint64(timestamp_us),
        SanitizeFloat(accel[0]),
        SanitizeFloat(accel[1]),
        SanitizeFloat(accel[2]),
        SanitizeFloat(gyro[0]),
        SanitizeFloat(gyro[1]),
        SanitizeFloat(gyro[2]),
        SanitizeFloat(mag[0]),
        SanitizeFloat(mag[1]),
        SanitizeFloat(mag[2]),
        SanitizeFloat(pressure_hpa, min_value=0.0),
        SanitizeFloat(0.0, min_value=0.0),
        SanitizeFloat(pressure_alt_m),
        SanitizeFloat(temperature_c),
        ClampUint32(K_ALL_HIL_SENSOR_FIELDS),
        ClampUint8(0),
    )

  def PollActuatorControlData(self, wait: bool) -> Optional[np.ndarray]:
    if self.mav_handle_ is None:
      return None

    deadline = time.monotonic() + 0.02 if wait else time.monotonic()

    while True:
      with self.reader_thread_lock_:
        if self.actuator_controls_ is not None:
          controls = np.array(self.actuator_controls_, dtype=float)
          self.actuator_controls_ = None
          return controls

      if not wait or time.monotonic() >= deadline:
        return None

      time.sleep(0.001)

  def LogDebugInfo(self) -> None:
    print(
        "[debug] "
        f"mav_handle_is_none={self.mav_handle_ is None} "
        f"mav_handle_type={type(self.mav_handle_)} "
        f"mav_handle_port={getattr(self.mav_handle_, 'port', None)}",
        flush=True,
    )
