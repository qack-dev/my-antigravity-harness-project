# my-antigravity-harness-project

> どんなプロジェクトでも、AIエージェントが最小限の質問だけで自走的に完遂できるようにする、[Google Antigravity CLI](https://antigravity.google/)(`agy`)向けの「ハーネス」(harness、AIが迷わず作業できるようリポジトリに文脈・規約・検証手段・ガードレールを埋め込む設計)テンプレート集。

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![CI](https://github.com/qack-dev/my-antigravity-harness-project/actions/workflows/ci.yml/badge.svg)](https://github.com/qack-dev/my-antigravity-harness-project/actions/workflows/ci.yml)
![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)
[![Agent: Antigravity](https://img.shields.io/badge/Agent-Antigravity_CLI-4285F4?style=flat-square&logo=google&logoColor=white)](https://antigravity.google/)

新しいプロジェクトを始めるたびに、AIエージェント向けの `AGENTS.md` や `docs/`、`.agents/` を毎回ゼロから書き起こすのは手間がかかります。本プロジェクトは、その「ハーネス」一式(行動指針・要件定義・タスク管理・検証ループ・ガードレール)を、プレースホルダ入りのテンプレートとして提供します。

新規プロジェクトのルートに `PROJECT_BRIEF.md`(プロジェクト詳細の記入用紙)を用意し、`agy`(Antigravity CLI)で `/init` と入力するだけで、そのプロジェクト用の `AGENTS.md` / `docs/*.md` / `.agents/*` が生成される状態を目指します。本リポジトリ自体は実行可能なアプリケーションコードを持たない、Markdown/JSONのテンプレート集です。

**このページには「本リポジトリのテンプレートを新規プロジェクトに使う」手順のみを載せています。** 設計の背景・姉妹リポジトリとの関係・リポジトリ構成は [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)、本リポジトリ自体の改修方法は [CONTRIBUTING.md](CONTRIBUTING.md)、ロードマップは [docs/TASKS.md](docs/TASKS.md)、個々の設計判断の記録は [docs/adr/](docs/adr/) を参照してください。

## ガードレールについての重要な注意

Antigravity CLIのガードレール設定(`settings.json`)は `~/.gemini/antigravity-cli/settings.json` というユーザーのホームディレクトリ配下(マシングローバル)に置かれ、リポジトリに同梱しても自動適用されません。そのため本テンプレートでは、リポジトリに同梱できる `.agents/hooks.json`(Hooks機構)で破壊的コマンドを`deny`する方式を採用しています(詳細: [docs/adr/0003](docs/adr/0003-guardrails-via-workspace-hooks-not-global-settings.md))。

> [!WARNING]
> Hooksの入出力契約は情報源によって表記が揺れており、実機での完全な動作確認ができていません。`.agents/hooks/deny-destructive-commands.sh` はベストエフォートの実装です。2026-08-02の再調査で、`matcher`の値が実際のツール名(`run_command`)と一致していない不具合を発見し修正済みですが、同種の不整合が残っている可能性は否定できません。また、`.agents/hooks.json`の`command`は相対パス指定のため、**`agy`を必ずワークスペースルートから起動してください**(サブディレクトリから起動すると`exit 127`でフックが無音失敗し、ガードレールがバイパスされることが報告されています)。安全性が重要な場面では、導入時に `agy inspect` や公式ドキュメントで実際の契約を確認し、`~/.gemini/antigravity-cli/settings.json` 側の `Deny` ルールも併用してください。

## 主な機能

- `templates/questions.json`: プロジェクト詳細の質問セット定義(唯一の"真実の源"。`PROJECT_BRIEF.md`や各`.template`の`{{KEY}}`は、すべてここで定義されたキーに対応する)
- `templates/PROJECT_BRIEF.md.template`: 新規プロジェクトのルートに置く、プロジェクト詳細の記入用紙の雛形
- `templates/workflows/init.md.template`: `PROJECT_BRIEF.md`から`AGENTS.md`/`docs/*.md`/`.agents/*`一式を生成する`/init`ワークフローの雛形(ユーザースコープのグローバルワークフローとして使う)
- `templates/AGENTS.md.template`: AIエージェントの行動指針(9項目)を含む汎用AGENTS.mdの雛形(`AGENTS.md`はAntigravity公式ドキュメントで`GEMINI.md`と同等の設定ファイルとして明記されている。詳細: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#主要な設計判断))
- `templates/docs/*.template`: PRD / ARCHITECTURE / TASKS / ADR の雛形
- `templates/agents/`: 生成先の `.agents/`(Rules / Workflows / Skills / Subagents / Hooks)一式の雛形

## ハーネスを新規プロジェクトに使う

### 初回セットアップ(開発者本人のマシンごとに1回だけ)

1. 本リポジトリをclone(未実施の場合)

   ```bash
   git clone https://github.com/qack-dev/my-antigravity-harness-project.git
   ```

2. `templates/workflows/init.md.template` を、**Antigravity CLIのグローバルワークフロー用ディレクトリ**へ `init.md` としてコピーする
   > [!NOTE]
   > グローバルワークフローの正確な保存先パスは、公式ドキュメントとコミュニティ記事とで記載が一致していません(`~/.gemini/antigravity/global_workflows/` という報告例あり)。コピー前に、お使いのバージョンの `agy` で `/workflow` のヘルプまたは公式ドキュメント(`https://antigravity.google/docs/`)を確認し、正しいパスに読み替えてください。`[要確認]`のままの場合は、後述の「代替手段」を使ってください。
3. コピーした`init.md`冒頭の `ハーネスリポジトリのローカルパス: [要確認: ...]` を、手順1でcloneした実際のローカルパスに書き換える

これで、以後どの新規プロジェクトでも `/init` が自動的に使えるようになります(プロジェクトごとの再セットアップは不要)。

**代替手段**: グローバルワークフローの配置場所が確認できない場合は、`templates/workflows/init.md.template` を新規プロジェクトごとに `.agents/workflows/init.md` としてコピーしても同じ処理が行えます(グローバル1回セットアップより手間は増えますが、確実に動作します)。

### 新規プロジェクトを始めるたび

1. 新規プロジェクトのルートに `templates/PROJECT_BRIEF.md.template` を `PROJECT_BRIEF.md` としてコピーし、分かる範囲で人の手で記入する(分からない項目は空欄のままでよい)
2. 新規プロジェクトのディレクトリで `agy` を起動し、`/init` と入力する
3. `/init` が `PROJECT_BRIEF.md` を読み、
   - 未記入の項目
   - 記入されていても、内容が曖昧・矛盾・情報不足だとAIが判断した項目

   についてだけ対話で確認し、揃ったら `AGENTS.md` / `docs/PRD.md` / `docs/ARCHITECTURE.md` / `docs/TASKS.md` / `docs/adr/0001-....md` / `.agents/rules/*.md` / `.agents/workflows/{plan,verify,commit}.md` / `.agents/skills/verify/SKILL.md` / `.agents/agents/*/agent.md` / `.agents/hooks.json` を生成する

出力例(`PROJECT_BRIEF.md`の「プロジェクトの目的」「想定ユーザー」を埋めた場合、`templates/AGENTS.md.template`の該当箇所がこう生成されます):

```markdown
## 1. プロジェクト概要

個人開発者が複数プロジェクトのTODOを1画面で横断管理できるようにする。

想定ユーザー: 個人開発者(自分自身)
```

生成後、`AGENTS.md`に残っている`[要確認: 内容]`(テスト/リント/ビルドコマンドなど、テンプレートが機械的に埋められない箇所)は、プロジェクトの実態に合わせて自分で埋めてください。

## トラブルシューティング

| 症状 | 原因と対処法 |
| --- | --- |
| `/init` を実行しても「初回セットアップが未完了」と言われる | ユーザースコープの`init.md`内の「ハーネスリポジトリのローカルパス」が`[要確認: ...]`のままです。「初回セットアップ」の手順3を実施してください |
| `/init` を実行しても `PROJECT_BRIEF.md` が見つからないと言われる | 新規プロジェクトのルートに `PROJECT_BRIEF.md` がありません。`templates/PROJECT_BRIEF.md.template` をコピーして配置してください |
| `/init` というスラッシュコマンドが見つからない | グローバルワークフローの配置場所を間違えている可能性があります。「代替手段」(プロジェクトごとに`.agents/workflows/init.md`をコピーする方法)を試してください |
| `.agents/hooks.json` を置いても危険なコマンドが実行されてしまう | まず `agy` をワークスペースルートから起動しているか確認してください(サブディレクトリから起動すると相対パス指定のフックが無音失敗します)。それでも機能しない場合、Hooksの入出力契約がお使いのバージョンと一致していない可能性があります。上記「ガードレールについての重要な注意」を参照し、`~/.gemini/antigravity-cli/settings.json` 側のDenyルールも併用してください |

本リポジトリ自体の開発に関するトラブルシューティングは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## ライセンス

[MIT License](LICENSE)。コントリビュートは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。
