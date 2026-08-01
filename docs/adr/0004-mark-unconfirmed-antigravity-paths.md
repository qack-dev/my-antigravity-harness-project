# 0004. Antigravity CLIの未確認仕様は断定的に記載せず `[要確認]` で明示する

## ステータス

採用

## コンテキスト

本リポジトリを設計するにあたり、Antigravity CLIの公式ドキュメント(`antigravity.google/docs/`)およびコミュニティ記事を調査した。その結果、以下のように**情報源間で設定ファイルのパスや仕様の記載が一致しない**箇所が複数見つかった。

- Rulesのワークスペーススコープ: 公式ドキュメントでは `.agents/rules`(後方互換として`.agent/rules`)、一部のコミュニティ記事では `.agent/rules` が主表記
- Skillsのグローバルスコープ: 公式コードラボでは `~/.gemini/config/skills/`、コミュニティ記事では `~/.gemini/antigravity-cli/skills/` や `~/.gemini/skills/`(用途により使い分けとの説明)
- グローバルWorkflowsの保存先: 公式ドキュメントのfetchでは明示されず、コミュニティ記事でのみ `~/.gemini/antigravity/global_workflows/` という記載を確認
- Hooksの入出力契約: 概要(イベント種別、stdin/stdoutでJSONをやり取りする契約)は確認できたが、フィールド名を裏付ける一次情報(公式サンプルコード等)までは確認できていない

Antigravity CLIはリリースから間もない製品であり、ドキュメントが更新され続けている段階にあると考えられる。この状況で、確認できていない仕様を断定的に記載すると、本リポジトリの利用者が誤った設定ファイルを配置し、ハーネスが機能しないまま気づかないリスクがある。これは `AGENTS.md`(および`templates/AGENTS.md.template`)の禁止事項にある「実在しないライブラリ・APIを推測で使用しない」という既存の方針とも一致する。

## 決定

- Antigravity CLIの仕様のうち、単一の一次情報源(公式ドキュメント)で明確に確認できたものは、断定形で記載する
- 複数の情報源で記載が食い違う、または一次情報源で確認できなかったものは、`[要確認: 内容]` 記法で明示し、可能な限り観測した候補やドキュメントURLを併記する
- `[要確認]`が残っている箇所は `docs/TASKS.md` にタスクとして記録し、実機(`agy`)での検証が取れ次第、解消する
- レビュー時(`.agents/agents/template-reviewer/agent.md`)は、断定的な記載の中に未確認情報が紛れ込んでいないかを確認項目に含める

## 影響

- 本リポジトリの一部のドキュメント(特に`.agents/hooks.json`まわり、グローバルWorkflowsのパス)には`[要確認]`が残った状態でpublishされる。これは本リポジトリの品質を落とすためではなく、誤った断定を避けるための意図的な選択である
- `[要確認]`を解消するPRを歓迎する(`CONTRIBUTING.md`参照)。解消する際は、根拠となった一次情報源(URL、確認日、確認したAntigravity CLIのバージョン)をコミットメッセージまたはADRに残すこと

## 追記(2026-08-02): wide/deep searchによる再調査結果

コンテキストで列挙した項目について、追加調査(公式ドキュメント`antigravity.google/docs/`各ページの再取得、および複数の独立したコミュニティ記事の突き合わせ)を行った結果は以下の通り。

- **Rulesのワークスペーススコープ**: `antigravity.google/docs/cli/plugins`(公式)で「Create a directory named `.agents/skills/`」、およびプラグイン内ディレクトリ構造として`rules/`(複数形)が明記されていることを確認した。`.agents/rules`(複数形)を正、`.agent/rules`(単数形)を後方互換として扱う整理は、複数のコミュニティ記事とも整合するため、断定形に格上げしてよいと判断する
- **Skillsのグローバルスコープ**: 依然として情報源間で不一致(`antigravity.google/docs/cli/plugins`のfetchでは`~/.gemini/antigravity-cli/skills/`、`antigravity.google/docs/hooks`のfetchでは(hooksの文脈だが)`~/.gemini/config/`という別系統のパスが示唆された)。一次情報源同士でも表記揺れが残るため、`[要確認]`のまま維持する
- **グローバルWorkflowsの保存先**: `~/.gemini/antigravity/global_workflows/`という記載を、独立した2件のコミュニティ記事(検索結果の要約経由)で確認した。ただし`antigravity.google/docs/ide/workflows`の直接fetchでは保存先パスへの言及自体がなく、一次情報源での裏付けは取れていない。確信度は上がったが、本ADRの方針(一次情報源で確認できたもののみ断定)に従い`[要確認]`のまま維持し、候補パスとして明記するにとどめる
- **Hooksの入出力契約**: `antigravity.google/docs/hooks`(公式)で、イベント種別(PreToolUse/PostToolUse/PreInvocation/PostInvocation/Stop)、`decision`の値(`allow`/`deny`/`ask`/`force_ask`)、共通stdinフィールド(`conversationId`/`workspacePaths`/`transcriptPath`/`artifactDirectoryPath`)を確認できた。ツール呼び出しの詳細(`toolCall.name`/`toolCall.args.CommandLine`)は公式ページの要約には現れなかったが、独立した複数のコミュニティ記事が同一のJSON構造を示しており、実装上の参考値として採用した(詳細は`docs/adr/0003`の追記を参照)。この過程で、本リポジトリの`.agents/hooks.json`の`matcher`値が実際のツール名(`run_command`)と一致していない不具合が見つかり修正した

一次情報源のみで確定できない項目が依然として残るのは、Antigravity CLIがリリース後も継続的にドキュメントを更新している段階の製品であるためであり、本ADRが想定していた状況そのものである。今後も定期的な再調査を`docs/TASKS.md`に記録する。
