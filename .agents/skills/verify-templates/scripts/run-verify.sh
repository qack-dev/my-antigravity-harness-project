#!/usr/bin/env bash
# 本リポジトリ(テンプレート集)の自己検証スキル(Harness Skill)
# Gemini CLI版(.gemini/skills/run-tests.sh)と同じ設計思想: 失敗時はログを出力し、
# エージェントがそれを読んで自己修正できるようにする。

set -euo pipefail
cd "$(dirname "$0")/../../../.."

echo "🔍 テンプレート整合性チェックと静的解析を実行中..."

export FORCE_COLOR=0

if ! npm run lint --silent > lint-results.log 2>&1; then
  echo "❌ Lintエラーが発生しました。以下のログを解析して修正してください:"
  cat lint-results.log
  exit 1
fi

if ! npm test --silent > test-results.log 2>&1; then
  echo "❌ テンプレート整合性チェックが失敗しました。以下のログを解析して修正してください:"
  cat test-results.log
  exit 1
fi

echo "✅ すべての検証をクリアしました!"
exit 0
