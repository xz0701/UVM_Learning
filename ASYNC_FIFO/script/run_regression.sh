#!/bin/bash

set -e

CONFIGS=(
  "8 4"
  "8 16"
  "16 8"
  "32 16"
  "64 4"
)

LOG_DIR="sim/regression_logs"
mkdir -p ${LOG_DIR}

for cfg in "${CONFIGS[@]}"; do
  WIDTH=$(echo $cfg | awk '{print $1}')
  DEPTH=$(echo $cfg | awk '{print $2}')

  TEST_NAME="sync_fifo_test"
  LOG_NAME="${LOG_DIR}/w${WIDTH}_d${DEPTH}.log"

  echo "======================================"
  echo "Running WIDTH=${WIDTH}, DEPTH=${DEPTH}"
  echo "======================================"

  make clean
  make WIDTH=${WIDTH} DEPTH=${DEPTH} TEST=${TEST_NAME} | tee ${LOG_NAME}

  if grep -q "UVM_ERROR :    0" ${LOG_NAME} && grep -q "UVM_FATAL :    0" ${LOG_NAME}; then
    echo "[PASS] WIDTH=${WIDTH} DEPTH=${DEPTH}"
  else
    echo "[FAIL] WIDTH=${WIDTH} DEPTH=${DEPTH}"
    exit 1
  fi
done

echo "======================================"
echo "REGRESSION PASSED"
echo "======================================"