---
name: template-consistency
description: templates/ 配下を編集するときに適用する検証ルール
trigger: glob
glob: "templates/**"
---
<!-- [要確認: globトリガーのfrontmatterキー名は未確認です。実際の仕様に合わせて読み替えてください] -->

# Template Consistency Rules

## 1. 変更後は必ず検証する

`templates/` 配下を変更したら、コミット前に必ず以下を実行し、通過を確認すること。

```bash
npm run verify
```

## 2. .template ファイルの一貫性

- 1つの `.template` ファイルは1つのドキュメント種別のみを扱う(複数の関心事を混在させない)
- `templates/docs/*.template` と `templates/AGENTS.md.template` は `{{KEY}}` を使う。`templates/agents/` 配下の Rules/Workflows/Skills/Subagents/Hooks テンプレートは、原則として汎用的な内容とし、`{{KEY}}` を増やしすぎない(生成先プロジェクトの実態に合わせて手動で `[要確認]` を埋める設計を維持する)
