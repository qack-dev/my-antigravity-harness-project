# TASKS: my-antigravity-harness-project

AIエージェントは着手前に必ずこのファイルを読み、着手するタスクと完了条件(Doneの定義)を確認すること。
タスク完了時は該当のチェックボックスに印を入れ、新たに判明した残タスクがあれば追記すること。

## 進行中

(なし)

## 未着手

- [ ] `templates/` を実際のAntigravity CLI(`agy`)で動作確認する(ドッグフーディング)
  - 完了条件: 適当なダミープロジェクトに対して`templates/questions.json`の質問に回答し、`templates/*.template`から実際に`AGENTS.md`/`docs/*.md`/`.agents/*`を生成できることを1回通しで確認する。あわせて`/init`ワークフローが実機で起動することを確認する
- [ ] グローバルワークフローの正確な配置パスを確定する
  - 完了条件: `agy`の公式ドキュメントまたは実機検証で正しいパスを確認し、`README.md`・`templates/workflows/init.md.template`の`[要確認]`を解消する
- [ ] `.agents/hooks.json` の入出力契約を実機で検証する
  - 完了条件: PreToolUseフックのstdin/stdoutの正確なJSONフィールド名を確認し、`.agents/hooks/deny-destructive-commands.sh`(および`templates/agents/hooks/`配下)を実際の契約に合わせて修正する。動作確認として、実際に破壊的コマンドがdenyされることを確認する
- [ ] オフライン環境向けに`markdownlint-cli2`を`devDependencies`として固定インストールする方式へ切り替えるか判断する
  - 完了条件: 判断結果を`docs/adr/`に新規ADRとして記録する(現状維持の場合もその理由を記録する)
- [ ] Antigravityの Plugin機構(`agy plugin install`)がWorkflowsのバンドルに対応しているか調査する
  - 完了条件: 対応していると確認できれば、配布方式をローカルパス参照からプラグイン配布へ移行するADRを作成する。対応していない、または確認できなければ、その旨を記録し現状維持とする
- [ ] `AGENTS.md`と`~/.gemini/GEMINI.md`(グローバルルール)が両方存在する場合の優先順位を確認する
  - 完了条件: 公式ドキュメントまたは実機検証で優先順位を確認し、`docs/ARCHITECTURE.md`の「既知の制約」にある該当`[要確認]`を解消する

## 完了

- [x] リポジトリの基盤ファイル一式(`.gitignore`/`.env.example`/`LICENSE`/`.editorconfig`/`.markdownlint.jsonc`/`package.json`/`AGENTS.md`/`README.md`/`CONTRIBUTING.md`)を作成
  - 完了条件: 各ファイルが存在し、秘密情報を含まない
- [x] 本リポジトリ保守用の `.agents/`(Rules/Workflows/Skills/Subagents/Hooks)を作成(自己適用によるドッグフーディング)
  - 完了条件: `.agents/rules/`, `.agents/workflows/{plan,verify,commit}.md`, `.agents/skills/verify-templates/`, `.agents/agents/template-reviewer/`, `.agents/hooks.json`が揃っている
- [x] 本リポジトリ用の`docs/`(PRD/ARCHITECTURE/TASKS/ADR)を作成
  - 完了条件: `docs/PRD.md`・`docs/ARCHITECTURE.md`にAntigravity CLI固有の設計判断(生成器パターン、hooksによるガードレール、`[要確認]`方針)が記載されている
- [x] `npm run verify`(lint + test)が通ることを確認し、Node.jsの動作確認済みバージョンを記載
  - 完了条件: Windows + Node.js v22.15.0で`npm run lint`・`npm test`がいずれも成功することを確認し、`AGENTS.md`・`README.md`・`docs/PRD.md`・`package.json`(`engines`フィールド)の該当`[要確認]`を解消した
- [x] Antigravity CLIがワークスペースルートの`AGENTS.md`を`GEMINI.md`と同等に自動解析するかを確認する
  - 完了条件: 公式ドキュメント(`antigravity.google/docs/cli/best-practices`)に「Create a `GEMINI.md` or `AGENTS.md` file at your workspace root」との記載があることを確認し、根拠を`docs/ARCHITECTURE.md`の「主要な設計判断」に追記した。ただし両ファイルが同時に存在する場合の優先順位は未確認のため別タスクとして残す
- [x] `README.md`を「リポジトリの使い方」のみに絞り、構造(`docs/ARCHITECTURE.md`)・開発方法(`CONTRIBUTING.md`)を分離
  - 完了条件: README.mdから「ハーネスの6層」表・姉妹リポジトリ比較表・プロジェクト構成ツリー・動作要件/クイックスタート/開発コマンドを移設し、リンクで参照する構造にした

## スコープ外(やらないこと)

`docs/PRD.md` の「スコープ外」を参照。
