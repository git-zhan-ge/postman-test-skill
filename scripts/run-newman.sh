#!/bin/bash
# 自动运行 Postman Collection 并生成报告
# 用法: ./run-newman.sh <collection文件> <环境文件(可选)>

COLLECTION="${1:-collection.postman_collection.json}"
ENVIRONMENT="${2}"

if [ -n "$ENVIRONMENT" ]; then
  newman run "$COLLECTION" -e "$ENVIRONMENT" --reporters cli,json --reporter-json-export newman-report.json
else
  newman run "$COLLECTION" --reporters cli,json --reporter-json-export newman-report.json
fi