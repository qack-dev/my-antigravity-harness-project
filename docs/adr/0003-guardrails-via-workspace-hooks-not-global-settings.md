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

## 追記(2026-08-02): 公式ドキュメント調査により判明した2件の実装ミスを修正

Google Antigravityの仕様についてwide/deep searchを実施した結果、`antigravity.google/docs/hooks` (一次情報源)と、それを補完する複数の独立したコミュニティ記事(Kanshi Tanaike氏、Mete Atamel氏の記事等)から、当時「未確認」としていたHooksの入出力契約についてより具体的な情報が得られた。その過程で、本リポジトリの実装に2件の具体的な不整合が見つかったため修正した。

1. **`matcher`の値が誤っていた**: `.agents/hooks.json`(および`templates/agents/hooks.json.template`)は`"matcher": "command"`としていたが、確認できた複数の一致するサンプル(`antigravity.google/docs/hooks`の要約、およびコミュニティ記事2件)はいずれも、シェルコマンド実行ツールの名前は`run_command`であり、`matcher`はコマンド文字列ではなく**ツール名**にマッチすると説明している。`"command"`という値はどのツール名にも一致しないため、このHookは(仕様通りに動作するAntigravity CLIであれば)一度も発火しない可能性が高かった。`"matcher": "run_command"`に修正した
2. **`command`の相対パス指定にリスクがある**: コミュニティ記事(Kanshi Tanaike氏の記事)によれば、`hooks.json`の`command`は絶対パスを要求され、相対パスは「`agy`を起動したディレクトリ」を基準に解決される。ワークスペースルート以外のサブディレクトリから`agy`を起動した場合、相対パス指定のフックスクリプトは`exit status 127 (command not found)`で失敗し、**ガードレールが無音でバイパスされる**。この失敗モードは重大(セキュリティ機能が壊れたことに気づけない)なため、フックスクリプトのコメントおよび`README.md`に明記した。恒久対応(環境変数展開や生成時の絶対パス埋め込みなど)は実機での挙動確認が取れていないため見送り、当面は「`agy`は必ずワークスペースルートから起動する」という運用上の注意喚起にとどめている

上記1件目は確信度が高いため断定的に修正したが、2件目の根本解決(絶対パス化の具体的な実装方式)は一次情報源で裏付けが取れていないため、`docs/TASKS.md`に検証タスクとして残す。

参考にした情報源:

- `antigravity.google/docs/hooks`(公式。イベント種別・`decision`値・共通stdinフィールドを確認)
- `antigravity.google/docs/cli/plugins`(公式。hooks.jsonの配置場所・`.agents/`が複数形であることを確認)
- Kanshi Tanaike, "A Developer's Guide to Agent Hooks in Antigravity CLI" (Medium, 2026-06) — `toolCall.name`/`toolCall.args.CommandLine`のJSON例、`matcher: run_command`の例、絶対パス制約の具体的な失敗モード(exit 127)
- Mete Atamel, "Where does Antigravity look for Hooks?" (atamel.dev, 2026-07-16) — `hooks.json`の探索順序(`.agents/hooks.json` → `~/.gemini/config/hooks.json`)
- `github.com/manaflow-ai/cmux` issue #5358 — サードパーティ統合における`PreToolUse`フックの`invalid_args`報告。公式プラグイン(vibe-island)は`PreToolUse`を使わず`PreInvocation`/`PostToolUse`/`PostInvocation`/`Stop`のみを使う設計になっているとの言及があり、`PreToolUse`によるツール承認ゲートは実運用でまだ枯れていない可能性を示唆する傍証として記録する
