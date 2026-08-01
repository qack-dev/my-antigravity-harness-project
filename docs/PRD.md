# PRD: my-antigravity-harness-project

## 目的

どんなソフトウェアプロジェクトでも、Google Antigravity CLI(`agy`)のようなAIエージェントが最小限の質問だけで自律的に完遂できるよう、文脈・規約・検証ループ・タスク・ガードレールの5条件を満たす「ハーネス」一式(`AGENTS.md`・`docs/`・`.agents/`のテンプレート)を提供する。

## 想定ユーザー

複数の新規プロジェクトを頻繁に立ち上げる開発者(`qack-dev`本人)。案件ごとにハーネス整備をゼロから作り直さずに済ませたい人。すでに [my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project)(Gemini CLI版)・[my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project)(Claude Code版)を運用しており、Antigravity CLIでも同じ体験を求めるユーザー。

## 機能要件

- `templates/questions.json` による、プロジェクト詳細の最小質問セット定義
  - 受け入れ条件: 8つの質問キー(PROJECT_NAME/PROJECT_PURPOSE/TECH_STACK/MAIN_FEATURES/TARGET_USERS/GITHUB_ACCOUNT/VISIBILITY/LICENSE)が定義されている(`my-claude-code-harness-project`と同一のキー構成を踏襲し、姉妹リポジトリ間の互換性を保つ)
- `templates/PROJECT_BRIEF.md.template` による、プロジェクト詳細の記入用紙の提供
  - 受け入れ条件: `questions.json`の8質問すべてに対応する記入欄を含む
  - 前提: プロジェクト詳細の一次情報源は対話ではなくこのファイルであり、AIエージェント(`/init`)は空欄または内容が曖昧・矛盾・情報不足と判断した項目についてのみ対話で確認する
- `templates/workflows/init.md.template` による、`PROJECT_BRIEF.md`からハーネス一式を生成する`/init`ワークフローの提供
  - 受け入れ条件: ユーザースコープのグローバルワークフローとして1回セットアップすれば、以後どの新規プロジェクトでも再セットアップなしに使える(代替として、プロジェクトごとの`.agents/workflows/`への個別配置にも対応する)
- `templates/AGENTS.md.template` による、汎用AGENTS.mdの雛形提供
  - 受け入れ条件: 元の指示にある9項目すべての見出しを含む
- `templates/docs/*.template` による、PRD/ARCHITECTURE/TASKS/ADRの雛形提供
  - 受け入れ条件: 4種のテンプレートファイルが存在し、`{{KEY}}`プレースホルダが`questions.json`のキーと一致する
- `templates/agents/` による、生成先の `.agents/`(Rules/Workflows/Skills/Subagents/Hooks)一式の雛形提供
  - 受け入れ条件: Rules 2種、Workflows 3種(plan/verify/commit)、Skills 1種(検証)、Subagents 2種(TDD実装/レビュー)、Hooks 1種(破壊的コマンドdeny)が揃っている
- テンプレートの整合性を自動検証する仕組み
  - 受け入れ条件: `npm test`が実際に実行でき、パスする

## 非機能要件

- パフォーマンス: 該当なし(静的ファイル集のため)
- セキュリティ: 秘密情報を一切含まない。`.env.example`はダミー値のみ。Antigravity CLIの実際のガードレール(Permissions Engine、Terminal Sandbox)を無効化するような設定例は記載しない
- 可用性/対象環境: Node.js 18以上(v22.15.0で動作確認済み)が動作するOS全般。Windowsで動作確認済み、macOS/Linuxは`[要確認: 未確認]`

## スコープ外

- 実際に対象プロジェクトへテンプレートを自動展開するCLIツールの実装(現時点では手動/AIエージェントによるコピー&置換を前提とする)
- 特定言語・フレームワーク向けの実装コード生成
- Antigravity CLIの未確認仕様(Hooksの正確な入出力契約、グローバルワークフローの正確な配置パスなど)を断定的に実装すること。これらは`[要確認]`として明示し、実機での検証を待つ(詳細: `docs/adr/0004-mark-unconfirmed-antigravity-paths.md`)

## 公開・ライセンス

- GitHubアカウント: qack-dev
- 公開範囲: private
- ライセンス: MIT
