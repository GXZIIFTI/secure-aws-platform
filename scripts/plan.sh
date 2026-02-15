#!/usr/bin/env bash
set -euo pipefail
cd ecs-cicd-bluegreen/infra
terraform init
terraform plan
