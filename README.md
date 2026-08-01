# my-antigravity-harness-project

> どんなプロジェクトでも、AIエージェントが最小限の質問だけで自走的に完遂できるようにする、[Google Antigravity CLI](https://antigravity.google/)(`agy`)向けの「ハーネス」(harness、AIが迷わず作業できるようリポジトリに文脈・規約・検証手段・ガードレールを埋め込む設計)テンプレート集。

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![CI](https://github.com/qack-dev/my-antigravity-harness-project/actions/workflows/ci.yml/badge.svg)](https://github.com/qack-dev/my-antigravity-harness-project/actions/workflows/ci.yml)
![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)
[![Agent: Antigravity](https://img.shields.io/badge/Agent-Antigravity_CLI-4285F4?style=flat-square&logo=google&logoColor=white)](https://antigravity.google/)

## 概要

新しいプロジェクトを始めるたびに、AIエージェント向けの `AGENTS.md` や `docs/`、`.agents/` を毎回ゼロから書き起こすのは手間がかかります。本プロジェクトは、その「ハーネス」一式(行動指針・要件定義・タスク管理・検証ループ・ガードレール)を、プレースホルダ入りのテンプレートとして提供します。

新規プロジェクトのルートに `PROJECT_BRIEF.md`(プロジェクト詳細の記入用紙)を用意し、Antigravity CLIで `/init` と入力するだけで、そのプロジェクト用の `AGENTS.md` / `docs/*.md` / `.agents/*` が生成される状態を目指します。

本リポジトリ自体は実行可能なアプリケーションコードを持たない、Markdown/JSONのテンプレート集です。

### 姉妹リポジトリとの関係

本プロジェクトは、以下の2リポジトリで培った「ハーネスエンジニアリング」の考え方を Antigravity CLI 向けに移植したものです。

| リポジトリ | 対象エージェント | 設計パターン |
| --- | --- | --- |
| [my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project) | Gemini CLI | 単一プロジェクトに直接埋め込む「常設ハーネス」 |
| [my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project) | Claude Code | 新規プロジェクトのたびにハーネス一式を生成する「テンプレート生成器」 |
| **my-antigravity-harness-project(本リポジトリ)** | Antigravity CLI (`agy`) | 生成器パターンを継承 + Antigravityが持つRules/Workflows/Skills/Subagents/Hooksをフル活用 |

生成器パターンを選んだ理由、および実際にこのパターンで生成された [EarthPulse](https://github.com/qack-dev/EarthPulse)(`my-claude-code-harness-project`から生成)から得た知見の反映内容は `docs/adr/0002-generator-not-embedded-harness.md` を参照してください。

**このREADMEには、性質の異なる2種類の使い方が出てきます。混同しないよう区別してください。**

| | 対象 | 誰が読むか |
| --- | --- | --- |
| [ハーネスを新規プロジェクトに使う](#ハーネスを新規プロジェクトに使う) | 本リポジトリの**外側**にある、これから作る別のプロジェクト | 本リポジトリのテンプレートを利用したい人(メインの使い方) |
| [本リポジトリ自体を開発する](#本リポジトリ自体を開発する) | 本リポジトリ**自身**(`templates/`の中身を直す) | 本リポジトリのテンプレートを改修したい人 |

## Antigravity CLIにおける「ハーネスの6層」

Antigravity CLIは、Gemini CLI/Claude Codeよりも多くのエージェント制御プリミティブをネイティブに持っています。本テンプレートは、それぞれを次のように対応付けています。

| 層 | Antigravityの機能 | 生成先のパス | 役割 |
| --- | --- | --- | --- |
| 1. Constitution(憲法) | — | `AGENTS.md` | プロジェクト概要・技術スタック・開発コマンド・禁止事項などの最上位方針 |
| 2. Rules(ルール) | Rules(`Always On`/`Manual`/`Model Decision`/`Glob`) | `.agents/rules/*.md` | アーキテクチャ・テストなどドメイン別の制約。Globで対象ファイルを絞り込み可能 |
| 3. Workflows(定型手順) | Workflows(`/workflow-name`) | `.agents/workflows/*.md` | plan/verify/commitなど繰り返し作業を型化したスラッシュコマンド相当 |
| 4. Skills(自己検証) | Skills(`SKILL.md`、意味マッチングで自動ロード) | `.agents/skills/*/SKILL.md` | テスト・リントを実行し失敗ログを解析させる自己修正ループ |
| 5. Subagents(ペルソナ) | Subagents(`agent.md`、`invoke_subagent`) | `.agents/agents/*/agent.md` | TDD実装担当・レビュー担当などの役割分担 |
| 6. Hooks / Permissions(安全装置) | Hooks(`PreToolUse`等)、Permissions Engine | `.agents/hooks.json` | 破壊的コマンドの実行を機械的に`deny`する。詳細は次項 |

## ガードレールについての重要な注意

Gemini CLI版(`my-agent-harness-project`)は `.gemini/settings.json` を**リポジトリに同梱**して破壊的コマンドを拒否していました。Antigravity CLIの相当設定である `settings.json` は `~/.gemini/antigravity-cli/settings.json` という**ユーザーのホームディレクトリ配下(マシングローバル)**に置かれるため、リポジトリに同梱してもエージェントには適用されません。

そのため本テンプレートでは、**ワークスペースに同梱できる `.agents/hooks.json`(Hooks機構)を使って`PreToolUse`イベントで破壊的コマンドを`deny`する**方式を採用しています。この判断の詳細は `docs/adr/0003-guardrails-via-workspace-hooks-not-global-settings.md` を参照してください。

> [!WARNING]
> Hooksの入出力契約(stdinで受け取るJSONのフィールド名、stdoutで返す`decision`の正確な値など)は、執筆時点で参照した複数の情報源の間でも表記が揺れており、実機での完全な動作確認ができていません。`.agents/hooks/deny-destructive-commands.sh` はベストエフォートの実装です。安全性が重要な場面では、`agy inspect` や利用中のバージョンの公式ドキュメントで実際の契約を確認し、`~/.gemini/antigravity-cli/settings.json` 側の `Deny` ルール(`command`の正規表現指定)も併用してください。

## 主な機能

- `templates/questions.json`: プロジェクト詳細の質問セット定義(唯一の"真実の源"。`PROJECT_BRIEF.md`や各`.template`の`{{KEY}}`は、すべてここで定義されたキーに対応する)
- `templates/PROJECT_BRIEF.md.template`: 新規プロジェクトのルートに置く、プロジェクト詳細の記入用紙の雛形
- `templates/workflows/init.md.template`: `PROJECT_BRIEF.md`から`AGENTS.md`/`docs/*.md`/`.agents/*`一式を生成する`/init`ワークフローの雛形(ユーザースコープのグローバルワークフローとして使う)
- `templates/AGENTS.md.template`: AIエージェントの行動指針(9項目)を含む汎用AGENTS.mdの雛形
- `templates/docs/*.template`: PRD / ARCHITECTURE / TASKS / ADR の雛形
- `templates/agents/`: 生成先の `.agents/`(Rules / Workflows / Skills / Subagents / Hooks)一式の雛形
- `tests/validate-templates.mjs`: テンプレートのプレースホルダと質問定義の整合性を検証するスクリプト(本リポジトリの保守用)
- `.github/`: 本リポジトリのCI設定、Issue/PRテンプレートの雛形

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

## 本リポジトリ自体を開発する

`templates/`配下のテンプレートそのものを改修する場合の手順です。上記の「ハーネスを新規プロジェクトに使う」とは目的が異なります。

### 動作要件

- OS: Windows(動作確認済み)/ macOS / Linux(`[要確認: 未確認。標準モジュールのみ使用しているため動作すると想定]`)
- Node.js: 18以上(v22.15.0で`npm run verify`の動作確認済み)
- インターネット接続: `npm run lint` の初回実行時に `markdownlint-cli2` を取得するため必要

Node.js/npmは、**本リポジトリ自身(テンプレート集)の整合性チェックとMarkdown lintのためだけ**に使われています。生成先の新規プロジェクトの技術スタックとは無関係で、生成物である`AGENTS.md`/`docs/*.md`/`.agents/*`自体はどんな言語・フレームワークのプロジェクトにも使えます。

### クイックスタート

```bash
cd my-antigravity-harness-project
npm install
npm run verify
```

`npm run verify` が成功すれば、セットアップは完了です。

### 開発コマンド

```bash
npm install       # セットアップ(追加依存パッケージなし)
npm run lint       # 全Markdownファイルの構文チェック
npm test           # templates/questions.json と *.template の整合性チェック
npm run verify      # lint + test をまとめて実行
```

新しい質問キーを追加する場合は、`templates/questions.json` にキーを追加したうえで、対応する `.template` ファイルに `{{KEY}}` を追記してください。`npm test` が両者の整合性(未定義キーの使用・未使用キーの検出)をチェックします。`PROJECT_BRIEF.md.template`や`init.md.template`のように、人が手で埋める箇所は`{{KEY}}`ではなく`[要確認: 内容]`記法を使ってください(この記法は`npm test`の対象外です)。

### プロジェクト構成

```text
my-antigravity-harness-project/
├── .agents/                 本リポジトリ保守用のRules/Workflows/Skills/Subagents/Hooks(自己適用)
├── .github/                 CI設定、Issue/PRテンプレート
├── docs/                    本リポジトリ自体のPRD/ARCHITECTURE/TASKS/ADR
├── templates/               配布物本体(汎用ハーネステンプレート、{{KEY}}プレースホルダ入り)
│   ├── questions.json       質問セット定義(唯一の"真実の源")
│   ├── PROJECT_BRIEF.md.template   生成先プロジェクトのルートに置く記入用紙
│   ├── AGENTS.md.template
│   ├── docs/*.template
│   ├── agents/              生成先の .agents/ に1:1対応するテンプレート
│   │   ├── rules/*.template
│   │   ├── workflows/{plan,verify,commit}.md.template
│   │   ├── skills/verify/SKILL.md.template
│   │   ├── agents/{tdd-engineer,code-reviewer}/agent.md.template
│   │   └── hooks.json.template + hooks/*.sh.template
│   └── workflows/
│       └── init.md.template  ユーザースコープのグローバルワークフロー(生成処理本体)
├── tests/                   テンプレート整合性チェックスクリプト
├── AGENTS.md                本リポジトリ用のAI行動指針
└── CONTRIBUTING.md
```

## トラブルシューティング

| 症状 | 原因と対処法 |
| --- | --- |
| `/init` を実行しても「初回セットアップが未完了」と言われる | ユーザースコープの`init.md`内の「ハーネスリポジトリのローカルパス」が`[要確認: ...]`のままです。「初回セットアップ」の手順3を実施してください |
| `/init` を実行しても `PROJECT_BRIEF.md` が見つからないと言われる | 新規プロジェクトのルートに `PROJECT_BRIEF.md` がありません。`templates/PROJECT_BRIEF.md.template` をコピーして配置してください |
| `/init` というスラッシュコマンドが見つからない | グローバルワークフローの配置場所を間違えている可能性があります。「代替手段」(プロジェクトごとに`.agents/workflows/init.md`をコピーする方法)を試してください |
| `.agents/hooks.json` を置いても危険なコマンドが実行されてしまう | Hooksの入出力契約はドキュメント間で表記揺れがあり、本テンプレートの実装がお使いのバージョンと一致していない可能性があります。上記「ガードレールについての重要な注意」を参照し、`~/.gemini/antigravity-cli/settings.json` 側のDenyルールも併用してください |
| `npm run lint` がネットワークエラーで失敗する | `npx markdownlint-cli2` が初回にパッケージを取得できていません。インターネット接続を確認するか、オフライン運用が必要な場合は `devDependencies` としての固定インストールに切り替えてください(`docs/TASKS.md` 参照) |
| `npm test` が「未定義のプレースホルダ」エラーを出す | `.template` ファイル内で使った `{{KEY}}` が `templates/questions.json` に定義されていません。質問定義を追加するか、タイプミスを修正してください |

## ロードマップ

- [ ] `templates/` を実プロジェクトへ適用する動作確認(実機の`agy`でのドッグフーディング。現時点では未実施)
- [ ] グローバルワークフローの正確な配置パスの確定(公式ドキュメントの更新を待つか、実機で確認する)
- [ ] `.agents/hooks.json` の入出力契約を実機で検証し、`deny-destructive-commands.sh` を実際の契約に合わせて修正する
- [ ] Node.jsの動作確認済みバージョンの確定
- [ ] Antigravityの Plugin機構(`agy plugin install`)がWorkflowsのバンドルに対応していると確認できた場合、配布方式をローカルパス参照からプラグイン配布へ移行するか検討する

詳細は [docs/TASKS.md](docs/TASKS.md) を参照してください。

## コントリビュート・ライセンス・謝辞

コントリビュート方法は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

本プロジェクトは [MIT License](LICENSE) のもとで公開されています。

このハーネス設計は、AIエージェントに文脈・規約・検証ループ・ガードレール・タスクをリポジトリ構造そのもので伝えるという考え方に基づいており、[my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project)・[my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project)・そこから生まれた [EarthPulse](https://github.com/qack-dev/EarthPulse) での知見を引き継いでいます。
