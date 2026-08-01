// templates/questions.json と templates/**/*.template の整合性を検証する。
// 外部パッケージに依存せず、Node.js標準モジュールのみを使用する。

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const rootDir = join(fileURLToPath(import.meta.url), "..", "..");
const templatesDir = join(rootDir, "templates");
const questionsPath = join(templatesDir, "questions.json");

const PLACEHOLDER_PATTERN = /\{\{([A-Z0-9_]+)\}\}/g;

function walk(dir) {
  const entries = readdirSync(dir);
  const files = [];
  for (const entry of entries) {
    const fullPath = join(dir, entry);
    if (statSync(fullPath).isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.endsWith(".template")) {
      files.push(fullPath);
    }
  }
  return files;
}

function main() {
  const errors = [];
  const warnings = [];

  let questionsRaw;
  try {
    questionsRaw = readFileSync(questionsPath, "utf8");
  } catch (err) {
    console.error(`❌ questions.json を読み込めませんでした: ${questionsPath}`);
    console.error(err.message);
    process.exit(1);
  }

  let questions;
  try {
    questions = JSON.parse(questionsRaw);
  } catch (err) {
    console.error(`❌ questions.json のJSONパースに失敗しました: ${err.message}`);
    process.exit(1);
  }

  if (!Array.isArray(questions.questions)) {
    console.error('❌ questions.json に "questions" 配列がありません');
    process.exit(1);
  }

  const definedKeys = new Set();
  for (const q of questions.questions) {
    if (!q.key || !/^[A-Z0-9_]+$/.test(q.key)) {
      errors.push(`questions.json 内のキーが不正です: ${JSON.stringify(q.key)}`);
      continue;
    }
    definedKeys.add(q.key);
  }

  const templateFiles = walk(templatesDir);
  if (templateFiles.length === 0) {
    errors.push("templates/ 配下に .template ファイルが1つも見つかりません");
  }

  const usedKeys = new Set();
  for (const file of templateFiles) {
    const content = readFileSync(file, "utf8");
    const relPath = relative(rootDir, file);
    let match;
    PLACEHOLDER_PATTERN.lastIndex = 0;
    while ((match = PLACEHOLDER_PATTERN.exec(content)) !== null) {
      const key = match[1];
      usedKeys.add(key);
      if (!definedKeys.has(key)) {
        errors.push(
          `${relPath} が未定義のプレースホルダ {{${key}}} を使用しています(questions.json に追加してください)`
        );
      }
    }
  }

  for (const key of definedKeys) {
    if (!usedKeys.has(key)) {
      warnings.push(`questions.json のキー "${key}" はどの .template ファイルからも使用されていません`);
    }
  }

  if (warnings.length > 0) {
    console.log("--- warnings ---");
    for (const w of warnings) console.log(`⚠️  ${w}`);
  }

  if (errors.length > 0) {
    console.log("--- errors ---");
    for (const e of errors) console.log(`❌ ${e}`);
    console.error(`\n${errors.length}件のエラーが見つかりました`);
    process.exit(1);
  }

  console.log(
    `✅ テンプレート整合性チェック: OK (${templateFiles.length}件の.templateファイル, ${definedKeys.size}件の質問キー)`
  );
}

main();
