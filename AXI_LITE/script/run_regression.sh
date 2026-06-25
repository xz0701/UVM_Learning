#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
AXI_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
LOG_DIR="${AXI_ROOT}/sim/regression_logs"

DEFAULT_TESTS=(
  axi_lite_smoke_test
  axi_lite_full_cov_test
  axi_lite_read_only_test
  axi_lite_direct_load_test
  axi_lite_load_conflict_test
  axi_lite_prot_test
  axi_lite_demux_smoke_test
  axi_lite_demux_stress_test
  axi_lite_random_test
)

if [[ "$#" -gt 0 ]]; then
  TESTS=("$@")
else
  TESTS=("${DEFAULT_TESTS[@]}")
fi

mkdir -p "${LOG_DIR}"

pass_count=0
fail_count=0
failed_tests=()

check_run_log() {
  local test_name="$1"
  local run_log="$2"

  if [[ ! -f "${run_log}" ]]; then
    echo "[FAIL] ${test_name}: run.log was not generated"
    return 1
  fi

  if ! grep -Eq "UVM_ERROR[[:space:]]*:[[:space:]]*0" "${run_log}"; then
    echo "[FAIL] ${test_name}: UVM_ERROR count is not zero"
    return 1
  fi

  if ! grep -Eq "UVM_FATAL[[:space:]]*:[[:space:]]*0" "${run_log}"; then
    echo "[FAIL] ${test_name}: UVM_FATAL count is not zero"
    return 1
  fi

  if ! grep -q "Scoreboard passed" "${run_log}"; then
    echo "[FAIL] ${test_name}: scoreboard pass message was not found"
    return 1
  fi

  return 0
}

echo "AXI-Lite regression"
echo "Root: ${AXI_ROOT}"
echo "Logs: ${LOG_DIR}"
echo

for test_name in "${TESTS[@]}"; do
  console_log="${LOG_DIR}/${test_name}_console.log"
  compile_log="${LOG_DIR}/${test_name}_compile.log"
  run_log_copy="${LOG_DIR}/${test_name}_run.log"

  echo "==> Running ${test_name}"

  make -C "${AXI_ROOT}" TEST="${test_name}" run > "${console_log}" 2>&1
  make_status=$?

  if [[ -f "${AXI_ROOT}/sim/compile.log" ]]; then
    cp "${AXI_ROOT}/sim/compile.log" "${compile_log}"
  fi

  if [[ -f "${AXI_ROOT}/sim/run.log" ]]; then
    cp "${AXI_ROOT}/sim/run.log" "${run_log_copy}"
  fi

  if [[ ${make_status} -ne 0 ]]; then
    echo "[FAIL] ${test_name}: make returned ${make_status}"
    failed_tests+=("${test_name}")
    fail_count=$((fail_count + 1))
    echo
    continue
  fi

  if check_run_log "${test_name}" "${run_log_copy}"; then
    cov_line=$(grep -m 1 "AXI-Lite functional coverage" "${run_log_copy}" || true)
    if [[ -n "${cov_line}" ]]; then
      echo "[PASS] ${test_name}: ${cov_line}"
    else
      echo "[PASS] ${test_name}"
    fi
    pass_count=$((pass_count + 1))
  else
    failed_tests+=("${test_name}")
    fail_count=$((fail_count + 1))
  fi

  echo
done

echo "Regression summary: ${pass_count} passed, ${fail_count} failed"

if [[ ${fail_count} -ne 0 ]]; then
  echo "Failed tests:"
  for test_name in "${failed_tests[@]}"; do
    echo "  ${test_name}"
  done
  exit 1
fi

exit 0
