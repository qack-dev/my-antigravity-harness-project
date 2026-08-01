# CONTRIBUTING

`templates/`配下のテンプレートそのものを改修する場合の手順です。「本リポジトリのテンプレートを新規プロジェクトに使う」手順(利用者向け)は [README.md](README.md) を参照してください。目的が異なります。

## 動作要件

- OS: Windows(動作確認済み)/ macOS / Linux(`[要確認: 未確認。標準モジュールのみ使用しているため動作すると想定]`)
- Node.js: 18以上(v22.15.0で`npm run verify`の動作確認済み)
- インターネット接続: `npm run lint` の初回実行時に `markdownlint-cli2` を取得するため必要

Node.js/npmは、**本リポジトリ自身(テンプレート集)の整合性チェックとMarkdown lintのためだけ**に使われています。生成先の新規プロジェクトの技術スタックとは無関係で、生成物である`AGENTS.md`/`docs/*.md`/`.agents/*`自体はどんな言語・フレームワークのプロジェクトにも使えます。

## クイックスタート

```bash
git clone https://github.com/qack-dev/my-antigravity-harness-project.git
cd my-antigravity-harness-project
npm install
npm run verify
```

`npm run verify` が成功すれば、セットアップは完了です。

## 開発コマンド

```bash
npm install       # セットアップ(追加依存パッケージなし)
npm run lint       # 全Markdownファイルの構文チェック
npm test           # templates/questions.json と *.template の整合性チェック
npm run verify      # lint + test をまとめて実行
```

新しい質問キーを追加する場合は、`templates/questions.json` にキーを追加したうえで、対応する `.template` ファイルに `{{KEY}}` を追記してください。`npm test` が両者の整合性(未定義キーの使用・未使用キーの検出)をチェックします。`PROJECT_BRIEF.md.template`や`init.md.template`のように、人が手で埋める箇所は`{{KEY}}`ではなく`[要確認: 内容]`記法を使ってください(この記法は`npm test`の対象外です)。

リポジトリ構成の詳細は [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) を参照してください。

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

## トラブルシューティング(開発時)

| 症状 | 原因と対処法 |
| --- | --- |
| `npm run lint` がネットワークエラーで失敗する | `npx markdownlint-cli2` が初回にパッケージを取得できていません。インターネット接続を確認するか、オフライン運用が必要な場合は `devDependencies` としての固定インストールに切り替えてください(`docs/TASKS.md` 参照) |
| `npm test` が「未定義のプレースホルダ」エラーを出す | `.template` ファイル内で使った `{{KEY}}` が `templates/questions.json` に定義されていません。質問定義を追加するか、タイプミスを修正してください |

利用者向け(生成先プロジェクトでの`/init`関連)のトラブルシューティングは [README.md](README.md) を参照してください。

## コミットメッセージ

「何を変更したか」ではなく「なぜ変更したか」を意識して、簡潔に記載してください。

## 行動規範

節度を持ち、Issue/PRでは技術的な議論に集中してください。
