# ARCHITECTURE: my-antigravity-harness-project

## 姉妹リポジトリとの関係

本プロジェクトは、以下の2リポジトリで培った「ハーネスエンジニアリング」の考え方を Antigravity CLI 向けに移植したものである。

| リポジトリ | 対象エージェント | 設計パターン |
| --- | --- | --- |
| [my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project) | Gemini CLI | 単一プロジェクトに直接埋め込む「常設ハーネス」 |
| [my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project) | Claude Code | 新規プロジェクトのたびにハーネス一式を生成する「テンプレート生成器」 |
| **my-antigravity-harness-project(本リポジトリ)** | Antigravity CLI (`agy`) | 生成器パターンを継承 + Antigravityが持つRules/Workflows/Skills/Subagents/Hooksをフル活用 |

生成器パターンを選んだ理由、および実際にこのパターンで生成された [EarthPulse](https://github.com/qack-dev/EarthPulse)(`my-claude-code-harness-project`から生成)から得た知見の反映内容は `docs/adr/0002-generator-not-embedded-harness.md` を参照。

## Antigravity CLIにおける「ハーネスの6層」

Antigravity CLIは、Gemini CLI/Claude Codeよりも多くのエージェント制御プリミティブをネイティブに持っている。本テンプレートは、それぞれを次のように対応付けている。

| 層 | Antigravityの機能 | 生成先のパス | 役割 |
| --- | --- | --- | --- |
| 1. Constitution(憲法) | ワークスペースルートのルールファイル | `AGENTS.md` | プロジェクト概要・技術スタック・開発コマンド・禁止事項などの最上位方針 |
| 2. Rules(ルール) | Rules(`Always On`/`Manual`/`Model Decision`/`Glob`) | `.agents/rules/*.md` | アーキテクチャ・テストなどドメイン別の制約。Globで対象ファイルを絞り込み可能 |
| 3. Workflows(定型手順) | Workflows(`/workflow-name`) | `.agents/workflows/*.md` | plan/verify/commitなど繰り返し作業を型化したスラッシュコマンド相当 |
| 4. Skills(自己検証) | Skills(`SKILL.md`、意味マッチングで自動ロード) | `.agents/skills/*/SKILL.md` | テスト・リントを実行し失敗ログを解析させる自己修正ループ |
| 5. Subagents(ペルソナ) | Subagents(`agent.md`、`invoke_subagent`) | `.agents/agents/*/agent.md` | TDD実装担当・レビュー担当などの役割分担 |
| 6. Hooks / Permissions(安全装置) | Hooks(`PreToolUse`等)、Permissions Engine | `.agents/hooks.json` | 破壊的コマンドの実行を機械的に`deny`する(詳細: `docs/adr/0003-guardrails-via-workspace-hooks-not-global-settings.md`) |

## 全体構成

実行コードを持たない、Markdown/JSONのテンプレート集。整合性チェックのみNode.js標準モジュールで実装する。

```text
my-antigravity-harness-project/
├── .agents/                 本リポジトリ保守用のRules/Workflows/Skills/Subagents/Hooks(自己適用)
├── .github/                 CI設定、Issue/PRテンプレート
├── docs/                    本リポジトリ自体のPRD/ARCHITECTURE/TASKS/ADR
├── templates/               配布物本体(汎用ハーネステンプレート、{{KEY}}プレースホルダ入り)
│   ├── questions.json       質問定義(唯一の"真実の源")
│   ├── PROJECT_BRIEF.md.template   生成先プロジェクトのルートに置く記入用紙
│   ├── AGENTS.md.template
│   ├── docs/*.template      PRD/ARCHITECTURE/TASKS/ADR
│   ├── agents/              生成先の .agents/ に1:1対応
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
| プロジェクトルートの憲法ファイルを`GEMINI.md`ではなく`AGENTS.md`という名前にする | 公式ドキュメント([`antigravity.google/docs/cli/best-practices`](https://antigravity.google/docs/cli/best-practices))に「Create a `GEMINI.md` or `AGENTS.md` file at your workspace root」と明記されており、両者は同等の選択肢として自動的に解析される。`AGENTS.md`はCursor/Claude Code等でも使われるクロスツールの慣習名であり、姉妹リポジトリ(Claude Code版)との命名一貫性も取れるため`AGENTS.md`を採用した | 本節・`docs/TASKS.md` |

## 既知の制約

- `npm run lint` は初回実行時に `npx` が `markdownlint-cli2` をネットワーク経由で取得するため、オフライン環境では失敗する `[要確認: 社内ネットワーク等オフライン運用が必要な場合は事前インストール方式への変更を検討]`
- 本リポジトリのAntigravity CLI固有部分(Rules/Workflows/Skills/Subagents/Hooksのファイル形式・保存パス)は、公開ドキュメントとコミュニティ記事の調査に基づいて作成しており、実機(`agy`)での動作確認は行っていない。2026-08-02時点の再調査で`.agents/hooks.json`の`matcher`値が実際のツール名(`run_command`)と一致していない不具合が見つかり修正した(詳細: `docs/adr/0003`の追記)。同種の不整合が他にも残っている可能性があるため、利用前に必ず実機で確認すること
- `.agents/hooks.json`の`command`に相対パスを指定した場合、`agy`をワークスペースルート以外のディレクトリから起動すると`exit 127`で無音失敗し、ガードレールがバイパスされることがコミュニティ記事で報告されている。恒久対応は未実装のため、`agy`は必ずワークスペースルートから起動すること(詳細: `docs/adr/0003`の追記)
- `AGENTS.md`と`GEMINI.md`(特にユーザーのホームディレクトリ配下`~/.gemini/GEMINI.md`にあるグローバルルール)が両方存在する場合の優先順位は、公式ドキュメントで明確な記載を確認できていない。実際に両者が同じ`~/.gemini/GEMINI.md`へ書き込み合って設定が混在する、という趣旨の報告(`github.com/google-gemini/gemini-cli` issue #16058)も見つかっており、一次情報源での裏付けが取れないまま`[要確認]`として扱う。競合が心配な場合は、Antigravity固有の上書き設定は`~/.gemini/GEMINI.md`側に、プロジェクト固有かつクロスツールなルールは`AGENTS.md`側に書き分けること
