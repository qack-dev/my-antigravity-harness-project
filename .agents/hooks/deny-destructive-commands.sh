#!/usr/bin/env bash
# PreToolUse フック: 破壊的なコマンドをエージェントが実行する前に機械的にブロックする。
#
# 2026-08時点でantigravity.google/docs/hooksおよび複数の独立したコミュニティ記事(公式ドキュメント
# のみでは実サンプル未掲載)から、stdinのJSONは概ね次の形であることを確認した(docs/adr/0003参照):
#   {"toolCall":{"name":"run_command","args":{"CommandLine":"...","Cwd":"...", ...}},
#    "stepIdx":N,"conversationId":"...","workspacePaths":[...],"transcriptPath":"...",
#    "artifactDirectoryPath":"..."}
# 実行されようとしているコマンド文字列は toolCall.args.CommandLine に入る想定だが、本スクリプトは
# JSONパーサ(jq等)への依存を避けるため、stdin全体をそのままgrepでパターンマッチしている
# (CommandLineの値も含めJSON全文が対象になるため、フィールド名の細部が仕様と多少ずれても検知は機能する
# 設計)。生成先プロジェクトの技術スタックを問わず動作させるための意図的な選択。
#
# [要確認] stdoutで返す decision の値("allow"/"deny"/"ask"/"force_ask")は公式ドキュメントで確認済みだが、
# 実機での最終動作確認はできていない。また、hooks.json側の command は相対パスだとagyの起動ディレクトリ
# (ワークスペースルートとは限らない)を基準に解決され、ズレると exit 127 で無音失敗しガードレールが
# バイパスされることが報告されている。安全のため、必ずワークスペースルートで agy を起動すること。
# 併用として ~/.gemini/antigravity-cli/settings.json 側の Deny ルールも設定することを推奨する(多層防御)。

set -euo pipefail

INPUT="$(cat)"

DENY_PATTERNS='rm -rf /|rm -rf ~|git push .*--force|git push .*-f |git reset --hard|git clean -fd|DROP TABLE|DROP DATABASE'

if echo "${INPUT}" | grep -Eiq "${DENY_PATTERNS}"; then
  printf '{"decision":"deny","reason":"破壊的なコマンドが検出されたため自動的にブロックしました(.agents/hooks/deny-destructive-commands.sh)。ユーザーの明示的な承認を得てから、手動で実行してください。"}\n'
  exit 0
fi

printf '{"decision":"allow"}\n'
exit 0
