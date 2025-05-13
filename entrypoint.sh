#!/bin/bash
set -e

echo "[INFO] Iniciando execução do teste com k6..."

# Cria diretório para o relatório
mkdir -p /home/k6/results || mkdir -p /results || echo "[WARN] Falha ao criar pasta results, tentando mesmo assim..."

# Executa o teste
k6 run /scripts/load-test.js \
  --env RPS_RAMP_UP="${RPS_RAMP_UP}" \
  --env DURATION_RAMP_UP="${DURATION_RAMP_UP}" \
  --env RPS_TARGET="${RPS_TARGET}" \
  --env DURATION_TARGET="${DURATION_TARGET}" \
  --env RPS_RAMP_DOWN="${RPS_RAMP_DOWN}" \
  --env DURATION_RAMP_DOWN="${DURATION_RAMP_DOWN}"

echo "[INFO] Teste concluído. Procurando relatório HTML..."

# Upload do relatório
aws s3 cp /home/k6/results/index_load_test.html s3://k6-loadtest-report/index_load_test.html || \
aws s3 cp /results/index_load_test.html s3://k6-loadtest-report/index_load_test.html || \
echo "[ERRO] Relatório não encontrado. Verifique se foi gerado corretamente."
