---
name: verify-templates
description: templates/配下を変更した後、lintとテンプレート整合性チェックを実行して自己検証する。「テンプレートを検証して」「npm run verifyして」「整合性チェック」のような依頼で使う
---

## Goal

`templates/questions.json` と `templates/**/*.template` の整合性、および全Markdownファイルの構文を機械的に検証し、失敗があれば自己修正ループを回す。

## Instructions

1. `scripts/run-verify.sh` を実行する
2. 終了コードが0でなければ、標準出力に出力されたエラーメッセージを読み、該当ファイルを特定する
3. 典型的な失敗パターン:
   - `.template`ファイルが未定義の`{{KEY}}`を使っている → `templates/questions.json`にキーを追加するか、タイプミスを修正する
   - Markdown構文エラー → 該当行を修正する
4. 修正後、再度 `scripts/run-verify.sh` を実行し、通過するまで繰り返す
5. 通過したら、実行結果を簡潔に報告する

## Examples

- 依頼: 「templates/AGENTS.md.templateを直したので検証して」→ `scripts/run-verify.sh` を実行し、結果を報告
- 依頼: 「npm run verifyが通るか確認して」→ 同上

## Constraints

- `templates/questions.json` のキーを、検証を通すためだけの目的で無断で削除しない
- 検証ログに含まれるファイルパス以外を推測で修正しない
