# CONTRIBUTING

## 開発環境のセットアップ

```bash
git clone https://github.com/qack-dev/my-antigravity-harness-project.git
cd my-antigravity-harness-project
npm install
```

## 変更の進め方

1. `docs/TASKS.md` を確認し、着手するタスクを決める(未記載の作業であればタスクを追記する)
2. `templates/` を変更する場合は、`templates/questions.json` のキー定義との整合性を保つ(`{{KEY}}`は必ず`questions.json`に定義があること)
3. `templates/agents/` 配下を変更する場合は、生成先の `.agents/` ディレクトリ構造とパスが1:1で対応しているか確認する
4. 変更後、以下を実行して通過を確認する

   ```bash
   npm run verify
   ```

5. `docs/TASKS.md` を更新する(該当タスクにチェックを入れる、または新規に判明したタスクを追記する)
6. Pull Requestを作成する(`.github/PULL_REQUEST_TEMPLATE.md` のチェックリストに従う)

## Antigravity CLIの仕様について

Antigravity CLIはリリース間もなく、ドキュメント間で設定ファイルのパスや仕様の記載が揺れていることがあります。実機で確認できていない仕様を断定的に書かないでください。確信が持てない場合は `[要確認: 内容]` と明記してください(詳細: `docs/adr/0004-mark-unconfirmed-antigravity-paths.md`)。実機で確認が取れた場合は、該当箇所の `[要確認]` を解消するPRを歓迎します。

## コミットメッセージ

「何を変更したか」ではなく「なぜ変更したか」を意識して、簡潔に記載してください。

## 行動規範

節度を持ち、Issue/PRでは技術的な議論に集中してください。
