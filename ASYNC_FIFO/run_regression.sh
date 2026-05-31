#!/bin/bash

set -e

CONFIGS=(
  "8 4 10 10"
  "8 16 10 20"
  "16 8 20 10"
  "32 16 10 17"
  "64 4 13 29"
)

LOG_DIR="sim/regression_logs"
mkdir -p ${LOG_DIR}

for cfg in "${CONFIGS[@]}"; do

  WIDTH=$(echo $cfg | awk '{print $1}')
  DEPTH=$(echo $cfg | awk '{print $2}')
  WR_CLK=$(echo $cfg | awk '{print $3}')
  RD_CLK=$(echo $cfg | awk '{print $4}')

  TEST_NAME="async_fifo_test"

  LOG_NAME="${LOG_DIR}/w${WIDTH}_d${DEPTH}_wr${WR_CLK}_rd${RD_CLK}.log"

  echo "================================================="
  echo "WIDTH=${WIDTH} DEPTH=${DEPTH}"
  echo "WR_CLK=${WR_CLK}ns RD_CLK=${RD_CLK}ns"
  echo "================================================="

  make clean
  mkdir -p ${LOG_DIR}

  make \
      WIDTH=${WIDTH} \
      DEPTH=${DEPTH} \
      WR_CLK_PERIOD=${WR_CLK} \
      RD_CLK_PERIOD=${RD_CLK} \
      TEST=${TEST_NAME} \
      | tee ${LOG_NAME}

  if grep -q "UVM_ERROR :    0" ${LOG_NAME} && \
     grep -q "UVM_FATAL :    0" ${LOG_NAME}; then

      echo "[PASS] WIDTH=${WIDTH} DEPTH=${DEPTH} WR=${WR_CLK} RD=${RD_CLK}"

  else

      echo "[FAIL] WIDTH=${WIDTH} DEPTH=${DEPTH} WR=${WR_CLK} RD=${RD_CLK}"
      exit 1

  fi

done

echo "======================================"
echo "REGRESSION PASSED"
echo "======================================"