#!/usr/bin/env bash
# PreToolUse フック: 破壊的なコマンドをエージェントが実行する前に機械的にブロックする。
#
# [要確認] 本スクリプトはベストエフォート実装です。Antigravity CLIのHooks入出力契約
# (stdinで渡されるJSONの正確なフィールド名、stdoutで返す decision の正確な値)は、
# 執筆時点で参照した情報源の間でも表記が揺れており、実機検証ができていません。
# 利用前に、お使いのバージョンの公式ドキュメントまたは `agy inspect` で契約を確認してください。
# 併用として ~/.gemini/antigravity-cli/settings.json 側の Deny ルールも設定することを推奨します。
#
# 設計方針: JSONパーサへの依存(jq等)を避け、grepによるベストエフォートのパターンマッチのみを行う。
# 生成先プロジェクトの技術スタックを問わず動作させるため。

set -euo pipefail

INPUT="$(cat)"

DENY_PATTERNS='rm -rf /|rm -rf ~|git push .*--force|git push .*-f |git reset --hard|git clean -fd|DROP TABLE|DROP DATABASE'

if echo "${INPUT}" | grep -Eiq "${DENY_PATTERNS}"; then
  printf '{"decision":"deny","reason":"破壊的なコマンドが検出されたため自動的にブロックしました(.agents/hooks/deny-destructive-commands.sh)。ユーザーの明示的な承認を得てから、手動で実行してください。"}\n'
  exit 0
fi

printf '{"decision":"allow"}\n'
exit 0
