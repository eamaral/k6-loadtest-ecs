#!/bin/bash
set -e

# Recebe os parâmetros do workflow
export RPS_RAMP_UP=$1
export DURATION_RAMP_UP=$2
export RPS_TARGET=$3
export DURATION_TARGET=$4
export RPS_RAMP_DOWN=$5
export DURATION_RAMP_DOWN=$6

# Verifica dependência
if ! command -v jq >/dev/null 2>&1; then
  echo "Erro: 'jq' não está instalado."
  exit 1
fi

# Corrige SUBNET_IDS para formato aceito
SUBNETS=$(echo "$SUBNET_IDS" | jq -r '. | join(",")')

# Constrói overrides
overrides=$(cat <<EOF
{
  "containerOverrides": [{
    "name": "k6",
    "environment": [
      { "name": "RPS_RAMP_UP",         "value": "$RPS_RAMP_UP" },
      { "name": "DURATION_RAMP_UP",    "value": "$DURATION_RAMP_UP" },
      { "name": "RPS_TARGET",          "value": "$RPS_TARGET" },
      { "name": "DURATION_TARGET",     "value": "$DURATION_TARGET" },
      { "name": "RPS_RAMP_DOWN",       "value": "$RPS_RAMP_DOWN" },
      { "name": "DURATION_RAMP_DOWN",  "value": "$DURATION_RAMP_DOWN" }
    ]
  }]
}
EOF
)

echo "Iniciando task no ECS..."

TASK_ARN=$(aws ecs run-task \
  --cluster "$CLUSTER_NAME" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],assignPublicIp=ENABLED}" \
  --task-definition "$TASK_DEFINITION_ARN" \
  --overrides "$overrides" \
  --query "tasks[0].taskArn" \
  --output text)

if [ -z "$TASK_ARN" ]; then
  echo "Erro: falha ao iniciar a task ECS."
  exit 1
fi

echo "Task iniciada: $TASK_ARN"
echo "Aguardando conclusão da task..."

for i in {1..60}; do
  STATUS=$(aws ecs describe-tasks \
    --cluster "$CLUSTER_NAME" \
    --tasks "$TASK_ARN" \
    --query "tasks[0].lastStatus" \
    --output text)

  echo "Status atual: $STATUS"

  if [ "$STATUS" = "STOPPED" ]; then
    echo "Task finalizada com sucesso."
    exit 0
  fi

  sleep 5
done

echo "Erro: Task não finalizou em tempo hábil."
exit 1
