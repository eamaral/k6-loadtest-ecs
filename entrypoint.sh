#!/bin/bash
set -e

echo "Executando teste com k6..."

# Garante que a pasta results existe
mkdir -p results

# Executa o teste
k6 run /scripts/load-test.js \
  --env RPS_RAMP_UP="${RPS_RAMP_UP}" \
  --env DURATION_RAMP_UP="${DURATION_RAMP_UP}" \
  --env RPS_TARGET="${RPS_TARGET}" \
  --env DURATION_TARGET="${DURATION_TARGET}" \
  --env RPS_RAMP_DOWN="${RPS_RAMP_DOWN}" \
  --env DURATION_RAMP_DOWN="${DURATION_RAMP_DOWN}"

echo "Verificando se report foi gerado..."
ls -lah results || echo "❌ Report não encontrado"

echo "Enviando HTML para o bucket S3..."
aws s3 cp results/index_load_test.html s3://k6-loadtest-report/index_load_test.html || echo "❌ Falha no upload do report"
