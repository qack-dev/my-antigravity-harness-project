# AGENTS.md

このファイルは、AIエージェント(Antigravity CLI / `agy` 等)が本プロジェクトで作業する際の行動指針です。作業開始前に必ず読んでください。

## 1. プロジェクト概要

本プロジェクトは、どんなソフトウェアプロジェクトに対しても、Google Antigravity CLI(`agy`)を使うAIエージェントが最小限の質問だけで自律的に完遂できるようにする「ハーネス」(文脈・規約・検証手段・ガードレールをリポジトリ構造に埋め込む設計)一式を、テンプレートとして提供する。実行可能なアプリケーションコードは持たず、成果物は `templates/` 配下のMarkdown/JSONテンプレートである。

想定ユーザー: 複数の新規プロジェクトを頻繁に立ち上げる開発者(`qack-dev`)。

姉妹リポジトリ: [my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project)(Gemini CLI向け)、[my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project)(Claude Code向け)。本プロジェクトはそのAntigravity CLI版であり、`my-claude-code-harness-project` の「生成器(テンプレート集)」パターンを踏襲しつつ、実プロジェクト [EarthPulse](https://github.com/qack-dev/EarthPulse) を生成した際の知見(詳細: `docs/adr/0002-generator-not-embedded-harness.md`)を反映している。

## 2. 技術スタックとバージョン

- 実行コードなし。テンプレート本体はMarkdown/JSON
- 整合性チェック用: Node.js 18以上(手元ではv22.15.0で`npm run verify`の動作を確認済み。標準モジュールのみ使用、追加パッケージへの依存なし)
- Markdown Lint: `markdownlint-cli2` (`npx`経由で都度取得。バージョン固定はしていない)

## 3. ディレクトリ地図

| ディレクトリ | 役割 |
| --- | --- |
| `templates/` | 他プロジェクトへ展開する汎用ハーネス本体(`{{KEY}}`形式のプレースホルダを含む) |
| `templates/questions.json` | プロジェクト詳細の最小質問セットの定義(唯一の"真実の源") |
| `templates/PROJECT_BRIEF.md.template` | 生成先プロジェクトのルートに置く、プロジェクト詳細の記入用紙の雛形 |
| `templates/AGENTS.md.template` | 生成先プロジェクトの行動指針(AGENTS.md)の雛形 |
| `templates/docs/` | 生成先プロジェクトの PRD/ARCHITECTURE/TASKS/ADR の雛形 |
| `templates/agents/` | 生成先プロジェクトの `.agents/`(Rules/Workflows/Skills/Subagents/Hooks)の雛形 |
| `templates/workflows/init.md.template` | `PROJECT_BRIEF.md`からハーネス一式を生成する、ユーザースコープのグローバルワークフロー(`/init`)の雛形 |
| `docs/` | 本リポジトリ自体のPRD/ARCHITECTURE/TASKS/ADR |
| `.agents/` | 本リポジトリを保守する際のRules/Workflows/Skills/Subagents/Hooks(自己適用=ドッグフーディング) |
| `tests/` | テンプレート整合性チェックスクリプト |
| `.github/` | CI設定、Issue/PRテンプレート |

## 4. 開発コマンド(検証ループ)

```bash
# セットアップ(追加インストール不要。npxが初回にmarkdownlint-cli2を取得する)
npm install

# テスト(templates/内のプレースホルダとquestions.jsonの整合性チェック)
npm test

# リント(全Markdownファイルの構文チェック)
npm run lint

# テスト+リントをまとめて実行
npm run verify
```

ビルドステップは存在しない(静的なテンプレート集のため)。

AIエージェントは、`templates/` 配下を変更した後は必ず `npm run verify` を実行し、通過を確認してからタスク完了とすること(`.agents/skills/verify-templates/SKILL.md` からも同じ検証を呼び出せる)。

## 5. コーディング規約

- テンプレート内のプレースホルダは `{{KEY_NAME}}` (大文字スネークケース)で統一し、`templates/questions.json` の `key` と一致させる
- 「後で確認が必要な箇所」は `[要確認: 内容]` で表記し、`{{KEY}}` プレースホルダと混同しない
- 実在しないコマンド・API・ファイルパスを断定的に書かない。Antigravity CLIの仕様はドキュメント間で表記揺れ・変更が多いため、確信が持てない場合は必ず `[要確認: 内容]` と明記する(詳細: `docs/adr/0004-mark-unconfirmed-antigravity-paths.md`)
- 1つの `.template` ファイルは1つのドキュメント種別(AGENTS.md、PRDなど)のみを扱う。複数の関心事を1ファイルに混在させない
- `templates/agents/` 配下は、生成先の `.agents/` ディレクトリ構造とパスを1:1で対応させる(`templates/agents/rules/x.md.template` → `.agents/rules/x.md`)

## 6. 作業の進め方

1. 着手前に `docs/TASKS.md` を読み、着手するタスクと完了条件(Doneの定義)を確認する
2. `templates/` を変更する場合は、対応する `templates/questions.json` のキー定義も同時に見直す
3. 実装する
4. `npm run verify` を実行する
5. 通過を確認する(失敗した場合は原因を修正してから次に進む)
6. `docs/TASKS.md` の該当タスクにチェックを入れる

## 7. 禁止事項

- `templates/questions.json` に定義されていないキーを `.template` ファイル内で新規に使わない(使う場合は先に質問定義を追加する)
- 秘密情報(APIキー・パスワード等)をコードやドキュメントに直接書かない。`.env.example`にはダミー値のみを記載する
- `git push --force` や破壊的なgit操作を、ユーザーの明示的な承認なしに実行しない(`.agents/hooks.json` による機械的なガードレールも参照)
- `templates/` 配下のファイルに、特定プロジェクト固有の値をハードコードしない(必ず `{{KEY}}` 経由にする)
- Antigravity CLIの未確認の仕様(コマンド名、設定ファイルのパスなど)を断定的に記載しない

## 8. 用語集

| 用語 | 意味 |
| --- | --- |
| ハーネス (Harness) | AIエージェントが文脈・規約・検証手段・ガードレール・タスクをリポジトリ構造から自力で把握できるようにする設計手法 |
| プレースホルダ | `{{PROJECT_NAME}}` のように、テンプレート適用時に実際の値へ置き換えられる箇所 |
| `[要確認: ...]` | AIまたは人間が値を断定できず、確認が必要であることを示すマーカー(プレースホルダとは別概念) |
| 検証ループ (Verification Loop) | AIが自分の成果物を検証できる、実行可能なテスト/リント/ビルドコマンド一式 |
| Rules | Antigravityのエージェント向け制約定義(`.agents/rules/`)。Always On/Manual/Model Decision/Globの4種の起動方式を持つ |
| Workflows | Antigravityの定型作業手順(`.agents/workflows/`)。`/workflow-name`で起動するスラッシュコマンド相当 |
| Skills | Antigravityの宣言的スキル(`.agents/skills/<name>/SKILL.md`)。説明文への意味マッチングで自動的にコンテキストへロードされる |
| Subagents | Antigravityのペルソナ/サブエージェント定義(`.agents/agents/<name>/agent.md`)。`invoke_subagent`や`/agents`パネルから起動する |
| Hooks | Antigravityのイベントフック(`.agents/hooks.json`)。PreToolUse等でツール実行を`allow`/`ask`/`deny`できる機械的ガードレール |

## 9. このファイル自体の更新ルール

- `templates/` の構成やコマンドに変更が生じた場合は、変更と同じコミット内で本ファイルを更新すること
- 「4. 開発コマンド」に記載のコマンドは、常に実行して通ることを前提とする。古くなったコマンドを放置しない
