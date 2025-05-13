#!/bin/bash
set -e

echo "▶️ Executando teste com k6..."

k6 run /scripts/load-test.js \
  --env RPS_RAMP_UP="${RPS_RAMP_UP}" \
  --env DURATION_RAMP_UP="${DURATION_RAMP_UP}" \
  --env RPS_TARGET="${RPS_TARGET}" \
  --env DURATION_TARGET="${DURATION_TARGET}" \
  --env RPS_RAMP_DOWN="${RPS_RAMP_DOWN}" \
  --env DURATION_RAMP_DOWN="${DURATION_RAMP_DOWN}"

echo "📄 Procurando report gerado..."
ls -lah results || echo "❌ Diretório de report não encontrado"

echo "⬆️ Fazendo upload do HTML para S3..."
aws s3 cp results/index_load_test.html s3://k6-loadtest-report/index_load_test.html

echo "✅ Teste finalizado com sucesso!"
