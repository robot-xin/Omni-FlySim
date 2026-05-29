# Copyright (c) 2026 The Omni-FlySim Authors. All rights reserved.

from __future__ import annotations

import numpy as np

FLOAT32_MAX = float(np.finfo(np.float32).max)


def ClampUint16(value: float) -> int:
  return int(np.clip(round(value), 0, 65535))


def ClampInt16(value: float) -> int:
  return int(np.clip(round(value), -32768, 32767))


def ClampUint8(value: float) -> int:
  return int(np.clip(round(value), 0, 255))


def ClampUint32(value: float) -> int:
  return int(np.clip(round(value), 0, 4294967295))


def ClampUint64(value: float) -> int:
  return int(np.clip(round(value), 0, 18446744073709551615))


def ClampInt32(value: float) -> int:
  return int(np.clip(round(value), -2147483648, 2147483647))


def SanitizeFloat(value: float,
                  default: float = 0.0,
                  min_value: float | None = None,
                  max_value: float | None = None) -> float:

  try:
    scalar = float(value)
  except (TypeError, ValueError):
    scalar = default

  if not np.isfinite(scalar):
    scalar = default

  if min_value is not None:
    scalar = max(scalar, min_value)

  if max_value is not None:
    scalar = min(scalar, max_value)

  scalar = float(np.clip(scalar, -FLOAT32_MAX, FLOAT32_MAX))
  return scalar


def SanitizeVector(values: np.ndarray | list[float],
                   size: int,
                   default: float = 0.0) -> np.ndarray:

  array = np.asarray(values, dtype=float).reshape(-1)
  result = np.full(size, default, dtype=float)
  copy_count = min(size, array.shape[0])
  if copy_count > 0:
    result[:copy_count] = array[:copy_count]
  return np.array([SanitizeFloat(v, default=default) for v in result],
                  dtype=float)
