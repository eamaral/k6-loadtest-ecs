#!/bin/bash
set -e

export RPS_RAMP_UP=$1
export DURATION_RAMP_UP=$2
export RPS_TARGET=$3
export DURATION_TARGET=$4
export RPS_RAMP_DOWN=$5
export DURATION_RAMP_DOWN=$6

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

aws ecs run-task \
  --cluster "$CLUSTER_NAME" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=${SUBNET_IDS},assignPublicIp=ENABLED}" \
  --task-definition "$TASK_DEFINITION_ARN" \
  --overrides "$overrides"
