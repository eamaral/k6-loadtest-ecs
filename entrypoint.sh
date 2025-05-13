#!/bin/bash
set -e

echo "Executando teste com k6..."

mkdir -p /tmp/results

k6 run /scripts/load-test.js \
  --env RPS_RAMP_UP="${RPS_RAMP_UP}" \
  --env DURATION_RAMP_UP="${DURATION_RAMP_UP}" \
  --env RPS_TARGET="${RPS_TARGET}" \
  --env DURATION_TARGET="${DURATION_TARGET}" \
  --env RPS_RAMP_DOWN="${RPS_RAMP_DOWN}" \
  --env DURATION_RAMP_DOWN="${DURATION_RAMP_DOWN}" \
  --summary-export=/tmp/results/summary.json

echo "Gerando HTML com k6-reporter..."
npx k6-reporter /tmp/results/summary.json /tmp/results/index_load_test.html

echo "Enviando HTML para o S3..."
aws s3 cp /tmp/results/index_load_test.html s3://k6-loadtest-report/index_load_test.html

echo "Teste finalizado com sucesso."
