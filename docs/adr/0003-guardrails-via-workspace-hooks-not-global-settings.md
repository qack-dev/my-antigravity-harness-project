# 0003. ガードレールをワークスペースの Hooks で実装し、ユーザーグローバルな settings.json には依存しない

## ステータス

採用

## コンテキスト

[my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project)(Gemini CLI版)は、`.gemini/settings.json`をリポジトリに同梱し、`denyCommands`(`rm -rf /`、`git push --force`等)でエージェントの破壊的操作を機械的にブロックしていた。この設定はリポジトリの一部としてバージョン管理され、チーム内の誰が使っても同じガードレールが有効になる。

Antigravity CLIの調査の結果、同等の設定ファイルである `settings.json` は `~/.gemini/antigravity-cli/settings.json` という**ユーザーのホームディレクトリ配下**に置かれることが公式ドキュメント(`/docs/cli/settings`, `/docs/cli/permissions`)で確認できた。この設定は「マシンごと・ユーザーごと」のグローバル設定であり、リポジトリに同梱してもAntigravity CLI自身が自動的に読み込む場所ではないため、Gemini CLI版と同じ方式(設定ファイルをリポジトリに同梱する)ではガードレールを配布できない。

一方、Antigravity CLIの Hooks機構(`.agents/hooks.json`)は、公式ドキュメント(`/docs/ide/hooks`)によれば `.agents/` 配下(ワークスペーススコープ)にも配置でき、`PreToolUse`イベントでツール実行を`allow`/`ask`/`deny`できる。これはリポジトリに同梱でき、バージョン管理もできる。

ただし、Hooksの入出力契約(stdinのJSONフィールド名、stdoutで返す`decision`の正確な値など)は、公式ドキュメントの要約以上の一次情報(実際のサンプルコードやスキーマ定義)を確認できておらず、実機での動作確認もできていない。

## 決定

- 本リポジトリのガードレールは、`~/.gemini/antigravity-cli/settings.json`(ユーザーグローバル、リポジトリに同梱不可)ではなく、`.agents/hooks.json`(ワークスペーススコープ、リポジトリに同梱可能)で実装する
- `.agents/hooks.json` は `PreToolUse` イベントで `command` ツールをフックし、`.agents/hooks/deny-destructive-commands.sh` が破壊的コマンド(`rm -rf /`、`git push --force`、`git reset --hard`等)を検出した場合に `deny` を返す
- Hooksの入出力契約が未確認であることをコード内コメントと `README.md` に明記し、`~/.gemini/antigravity-cli/settings.json` 側のDenyルール設定も併用することを推奨する(多層防御。詳細は`README.md`の「ガードレールについての重要な注意」を参照)
- `templates/agents/hooks.json.template` および `templates/agents/hooks/deny-destructive-commands.sh.template` として、生成先プロジェクトにも同じ仕組みを配布する

## 影響

- 本リポジトリを利用する開発者は、Hooksだけに安全性を委ねず、`~/.gemini/antigravity-cli/settings.json`側の設定も自分で行う必要がある(本リポジトリはユーザーグローバル設定を書き換えられないため)
- Hooksの入出力契約が実機で確認でき次第、`docs/TASKS.md`の該当タスクを完了させ、この ADR に追記または新規ADRで更新すること
- Gemini CLI版との対応関係: 「リポジトリ同梱の設定ファイルでコマンドをブロックする」という目的は同じだが、実現方式(settings.json vs hooks.json)がAntigravity CLIのアーキテクチャ上の制約により異なる
