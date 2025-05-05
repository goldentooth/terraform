#!/usr/bin/env bash

repo_root="$(git rev-parse --show-toplevel)";
pushd "${repo_root}/terraform/modules/dynamic_dns/lambda" > /dev/null;
zip function.zip lambda.py;
aws lambda update-function-code \
  --function-name goldentooth-cluster-dynamic-dns \
  --zip-file fileb://function.zip;
rm function.zip;
