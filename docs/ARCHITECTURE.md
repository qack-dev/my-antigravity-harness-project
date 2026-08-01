# ARCHITECTURE: my-antigravity-harness-project

## 全体構成

実行コードを持たない、Markdown/JSONのテンプレート集。整合性チェックのみNode.js標準モジュールで実装する。

```text
templates/                         配布物本体(汎用・プレースホルダ入り)
├── questions.json                 質問定義(唯一の"真実の源")
├── PROJECT_BRIEF.md.template      生成先プロジェクトのルートに置く記入用紙
├── AGENTS.md.template
├── docs/*.template                PRD/ARCHITECTURE/TASKS/ADR
├── agents/                        生成先の .agents/ に1:1対応
│   ├── rules/*.template
│   ├── workflows/{plan,verify,commit}.md.template
│   ├── skills/verify/SKILL.md.template
│   ├── agents/{tdd-engineer,code-reviewer}/agent.md.template
│   └── hooks.json.template + hooks/*.sh.template
└── workflows/
    └── init.md.template           グローバルワークフロー(生成処理本体)

tests/validate-templates.mjs       questions.json と *.template の整合性を検証
  ↓ 参照
templates/questions.json ── keys ──→ *.template 内の {{KEY}} と突き合わせ
```

## データの流れ

1. 開発者はマシンごとに1回だけ、`templates/workflows/init.md.template` をAntigravity CLIのグローバルワークフロー用ディレクトリへ `init.md` としてコピーし、本ハーネスリポジトリのローカルパスを書き込む(初回セットアップ)。グローバルディレクトリの正確なパスが確認できない場合は、プロジェクトごとに `.agents/workflows/init.md` へ個別コピーする代替手段を使う
2. 新規プロジェクトを始めるたびに、`templates/PROJECT_BRIEF.md.template` を対象プロジェクトの `PROJECT_BRIEF.md` としてコピーし、分かる範囲で人が手で記入する
3. 対象プロジェクトで `agy` を起動し `/init` と入力すると、`init.md` が `PROJECT_BRIEF.md` を読み、`questions.json` の各キーについて (a) 空欄、または (b) 記入されているが曖昧・矛盾・情報不足とAIが判断したもの、だけを対話で確認する
4. 全キーが揃ったら、`init.md` に書かれたローカルパスから `templates/AGENTS.md.template` / `templates/docs/*.template` / `templates/agents/**/*.template` を読み込み、`{{KEY}}` を回答で置換して対象プロジェクトの `AGENTS.md` / `docs/*.md` / `.agents/*` として配置する
5. 本リポジトリ自体では、`tests/validate-templates.mjs` が `questions.json` のキー集合と、全 `.template` ファイル中に出現する `{{KEY}}` の集合を突き合わせ、未定義キーの使用がないかを検証する(`PROJECT_BRIEF.md.template` や `init.md.template` 内の `[要確認: 内容]` は人が手で埋める箇所であり、この検証の対象外)

## 主要な設計判断

重要な意思決定は本ファイルに要約を書き、詳細は `docs/adr/` に ADR(Architecture Decision Record、意思決定記録)として残すこと。

| 決定 | 理由 | 詳細 |
| --- | --- | --- |
| 実行可能なCLIツールではなく、静的テンプレート集として構成する | 対象プロジェクトの技術スタックを本リポジトリ側で先に決め打ちしないため。技術スタックの決定は各プロジェクト立ち上げ時の質問(`TECH_STACK`)に委ねる | `docs/adr/0001-record-architecture-decisions.md` |
| `my-claude-code-harness-project`と同じ「生成器(テンプレート集)」パターンを採用する(Gemini CLI版のような常設埋め込み型ではなく) | 生成器パターンで実際に [EarthPulse](https://github.com/qack-dev/EarthPulse) を生成した実績があり、複数プロジェクトを頻繁に立ち上げる利用者に適していると検証済みのため | `docs/adr/0002-generator-not-embedded-harness.md` |
| ガードレール(破壊的コマンド拒否)を、ユーザーグローバルな`settings.json`ではなく、リポジトリに同梱できる`.agents/hooks.json`で実装する | Antigravity CLIの`settings.json`はホームディレクトリ配下のマシングローバル設定であり、リポジトリに同梱してもチーム内で共有できないため | `docs/adr/0003-guardrails-via-workspace-hooks-not-global-settings.md` |
| Antigravity CLIの未確認仕様は断定的に書かず`[要確認]`で明示する | 複数の情報源(公式ドキュメント・コミュニティ記事)間で設定ファイルパスや入出力契約の記載が食い違っており、断定するとハルシネーションのリスクがあるため | `docs/adr/0004-mark-unconfirmed-antigravity-paths.md` |

## 既知の制約

- `npm run lint` は初回実行時に `npx` が `markdownlint-cli2` をネットワーク経由で取得するため、オフライン環境では失敗する `[要確認: 社内ネットワーク等オフライン運用が必要な場合は事前インストール方式への変更を検討]`
- 本リポジトリのAntigravity CLI固有部分(Rules/Workflows/Skills/Subagents/Hooksのファイル形式・保存パス)は、公開ドキュメントとコミュニティ記事の調査に基づいて作成しており、実機(`agy`)での動作確認は行っていない。特に `.agents/hooks.json` の入出力契約は情報源間で記載が揺れているため、利用前に必ず実機で確認すること
