---
name: harness-maintenance
description: 本リポジトリ(テンプレート集)を保守する際に常に適用する制約
trigger: always_on
---
<!-- [要確認: frontmatterのキー名(trigger等)はAntigravity CLIの実際の仕様と異なる可能性があります。お使いのバージョンで `agy inspect` 等により実際のスキーマを確認してください] -->

# Harness Maintenance Rules

## 1. テンプレートとプレースホルダの整合性

- `templates/` 配下の `.template` ファイル内で新しい `{{KEY}}` を使う場合は、必ず `templates/questions.json` に対応するキー定義を先に追加すること
- `[要確認: 内容]` はプレースホルダとは別概念。人間/AIの判断が必要な箇所にのみ使う

## 2. ディレクトリ構造の対応関係

- `templates/agents/` 配下は、生成先の `.agents/` ディレクトリと1:1でパスが対応する(`templates/agents/rules/x.md.template` → `.agents/rules/x.md`)
- 生成先固有の値をハードコードしない。プロジェクト固有の情報は必ず `{{KEY}}` 経由にする

## 3. Antigravity CLI仕様の扱い

- Antigravity CLIの設定ファイルパスやコマンド仕様は情報源によって表記が揺れている(詳細: `docs/adr/0004-mark-unconfirmed-antigravity-paths.md`)
- 実機で確認していない仕様を断定的に記載しない。確信が持てない場合は `[要確認: 内容]` と明記する
