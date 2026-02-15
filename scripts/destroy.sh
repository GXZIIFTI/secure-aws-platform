#!/usr/bin/env bash
set -euo pipefail

cd ecs-cicd-bluegreen/infra

echo "Destroying application infrastructure (NOT backend state bucket/table)..."
terraform destroy -auto-approve

echo "Done."
