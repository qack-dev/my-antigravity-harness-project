`AGENTS.md` の「4. 開発コマンド(検証ループ)」に記載されたコマンドを順に実行し、結果を報告する。

1. `npm run lint` を実行する(全Markdownファイルの構文チェック)
2. `npm test` を実行する(`templates/questions.json`と`.template`ファイルの整合性チェック)
3. 失敗があれば、原因と該当ファイルを特定し、修正方針を提示する(無断で`templates/questions.json`のキーを削除しない)
4. すべて通過したら、実行したコマンドと結果を簡潔に一覧で報告する
