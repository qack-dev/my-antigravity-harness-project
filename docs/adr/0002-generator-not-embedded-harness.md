# 0002. 常設埋め込み型ではなく「生成器(テンプレート集)」パターンを採用する

## ステータス

採用

## コンテキスト

姉妹リポジトリは2つの異なる設計パターンを取っている。

- [my-agent-harness-project](https://github.com/qack-dev/my-agent-harness-project)(Gemini CLI版): `.gemini/`配下にRules/Skills/Settings/Personasを直接埋め込んだ「常設ハーネス」。リポジトリ自体が1つのアプリケーションプロジェクトであることを前提に、ハーネスをそのプロジェクトに固定的に組み込む
- [my-claude-code-harness-project](https://github.com/qack-dev/my-claude-code-harness-project)(Claude Code版): `templates/`配下に`{{KEY}}`プレースホルダ入りの雛形を持ち、`PROJECT_BRIEF.md` + グローバル`/init`コマンドで新規プロジェクトごとにハーネス一式を生成する「生成器」。このパターンで実際に生成されたプロジェクトが [EarthPulse](https://github.com/qack-dev/EarthPulse) である

Antigravity CLI版を新規に作るにあたり、どちらのパターンを踏襲するかを決める必要があった。

EarthPulseでの実績から、生成器パターンについて以下が確認できている。

- `PROJECT_BRIEF.md`をAIとの対話の前に人間が記入し、AIは空欄・曖昧な項目だけを対話で埋める、という流れは実際に機能した(EarthPulseの`PROJECT_BRIEF.md`は主要機能欄が空欄のまま生成が進んでおり、対話補完が機能したことがうかがえる)
- 生成された`CLAUDE.md`(9項目)・`docs/PRD.md`・`docs/ARCHITECTURE.md`・`docs/TASKS.md`・`docs/adr/0001-...md`は、いずれもプレースホルダが解決され、プロジェクト固有の内容(FastAPI構成、2GBメモリ制約、データ出典など)に置き換わっている
- 一方で、`my-claude-code-harness-project`は運用中に3件のIssue(README分かりにくさ、対話開始タイミングの曖昧さ、生成後にLICENSE/READMEの重複が残る問題)を経て現在の形に改善されている。これらは「一発で完璧な生成器は作れない、運用しながら改善する」ことを示している

本プロジェクトの想定ユーザー(`qack-dev`)は、複数の新規プロジェクトを頻繁に立ち上げる開発者であり、Gemini CLI版のような「1つのプロジェクトに固定」よりも、Claude Code版のような「毎回新しいプロジェクトに展開できる」生成器パターンの恩恵の方が大きい。

## 決定

- 本リポジトリは `my-claude-code-harness-project` と同じ「生成器(テンプレート集)」パターンを採用する
- `templates/questions.json` の8質問キー(PROJECT_NAME/PROJECT_PURPOSE/TECH_STACK/MAIN_FEATURES/TARGET_USERS/GITHUB_ACCOUNT/VISIBILITY/LICENSE)は、姉妹リポジトリと同一の構成を維持する(姉妹リポジトリ間でのユーザー体験の一貫性を優先し、Antigravity固有の追加質問は現時点では設けない)
- `my-claude-code-harness-project`がIssue対応で得た3つの教訓を、初期実装の時点で反映する
  1. プロジェクト詳細の一次情報源は`PROJECT_BRIEF.md`とし、対話はAIが空欄/曖昧と判断した項目のみに限定する
  2. ハーネス生成コマンド(`/init`相当)は、新規プロジェクトごとにコピーするのではなく、ユーザースコープに1回だけセットアップする(Antigravity CLIではグローバルワークフローとして実装。詳細は`README.md`の「初回セットアップ」を参照)
  3. 生成時に、対象プロジェクトの既存`LICENSE`/`README.md`が残ってしまう問題を避けるため、`templates/workflows/init.md.template`の生成手順に確認付きの削除ステップを含める
- Gemini CLI版由来の要素(Rules・自己検証Skill・ガードレール・ペルソナ)は、生成器パターンの中で「生成先に配置するテンプレート」として取り込む(`templates/agents/`配下)

## 影響

- 本リポジトリ自体は実行可能なアプリケーションを持たず、`templates/`の整合性検証(`tests/validate-templates.mjs`)のみを持つ(ADR 0001と整合)
- 新規プロジェクトを立ち上げるたびに`PROJECT_BRIEF.md`をコピーする作業のみが必要で、コマンド/ワークフローファイルの個別コピーは(グローバルセットアップが有効な場合)発生しない
- 将来、Gemini CLI版のような常設埋め込み型が必要になった場合(例: 本リポジトリ自体をAntigravity CLIで日常的に保守する用途)は、`.agents/`(本リポジトリ保守用)がその役割を兼ねる
