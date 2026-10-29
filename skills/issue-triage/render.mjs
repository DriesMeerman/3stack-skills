#!/usr/bin/env node
// Build the triage page from a triage JSON file.
// Usage: node render.mjs <triage.json> [out.html]
import { readFileSync, writeFileSync } from 'node:fs';
import { basename, resolve } from 'node:path';

const [input, explicitOutput] = process.argv.slice(2);
const output = input && (explicitOutput ?? input.replace(/\.json$/, '.html'));
if (!input || output === input) {
  console.error('Usage: node render.mjs <triage.json> [out.html]');
  process.exit(2);
}

const VERDICTS = ['ready', 'decide', 'split', 'close', 'priority', 'keep'];
const VERBS = {
  label: ['issue', 'add', 'remove'],
  close: ['issue', 'reason'],
  milestone: ['issue', 'milestone'],
  create: ['title', 'body', 'labels', 'milestone'],
  comment: ['issue', 'body'],
  body: ['issue', 'add'],
};

const data = JSON.parse(readFileSync(input, 'utf8'));
const problems = [];
const checkOptions = (at, q) => {
  if (!Array.isArray(q.options) || q.options.length < 2) return problems.push(`${at} needs at least two options`);
  if (new Set(q.options.map((o) => o.label)).size !== q.options.length) problems.push(`${at} has duplicate option labels`);
  if (q.default && !q.options.some((o) => o.label === q.default)) problems.push(`${at}.default is not one of its option labels`);
};
if (!data.repo) problems.push('repo is missing');
if (!Array.isArray(data.items) || data.items.length === 0) problems.push('items is empty');
for (const [i, item] of (data.items || []).entries()) {
  const at = `items[${i}]`;
  if (!['issue', 'pr'].includes(item.kind)) problems.push(`${at}.kind must be issue or pr`);
  if (!Number.isInteger(item.number)) problems.push(`${at}.number must be an integer`);
  if (!item.title || !item.url) problems.push(`${at} needs title and url`);
  if (!VERDICTS.includes(item.verdict)) problems.push(`${at}.verdict must be one of ${VERDICTS.join(', ')}`);
  const actions = item.actions || [];
  const questions = item.questions || [];
  if (!actions.length && !questions.length) problems.push(`${at} needs at least one action or question`);
  for (const [j, a] of actions.entries()) {
    const aat = `${at}.actions[${j}]`;
    if (!a.title) problems.push(`${aat}.title is missing`);
    if (!Array.isArray(a.do) || a.do.length === 0) problems.push(`${aat}.do is empty`);
    for (const [k, step] of (a.do || []).entries()) {
      const sat = `${aat}.do[${k}]`;
      const fields = VERBS[step.verb];
      if (!fields) { problems.push(`${sat}.verb must be one of ${Object.keys(VERBS).join(', ')}`); continue; }
      for (const key of Object.keys(step)) if (key !== 'verb' && !fields.includes(key)) problems.push(`${sat} has unknown field ${key}`);
      if (fields.includes('issue') && !Number.isInteger(step.issue)) problems.push(`${sat}.issue must be an integer`);
      if (step.verb === 'create' && !step.title) problems.push(`${sat}.title is missing`);
      if (['comment', 'body'].includes(step.verb) && !(step.body || step.add)) problems.push(`${sat} needs text`);
      for (const label of [...(step.add && step.verb === 'label' ? step.add : []), ...(step.remove || []), ...(step.labels || [])]) {
        if (String(label).includes(',')) problems.push(`${sat} label "${label}" holds a comma`);
      }
    }
  }
  for (const [j, q] of questions.entries()) {
    const qat = `${at}.questions[${j}]`;
    if (!q.prompt) problems.push(`${qat}.prompt is missing`);
    if (q.kind === 'chore') {
      if (q.stepsFor) checkOptions(qat, q);
      else if (!Array.isArray(q.steps) || q.steps.length === 0) problems.push(`${qat} chore needs steps or stepsFor`);
      continue;
    }
    if (q.kind && q.kind !== 'decision') problems.push(`${qat}.kind must be decision or chore (cleanups go in actions)`);
    if (q.type === 'text') continue;
    if (q.type !== 'choice') problems.push(`${qat}.type must be choice or text`);
    else checkOptions(qat, q);
    if (q.style && !['cards', 'radio'].includes(q.style)) problems.push(`${qat}.style must be cards or radio`);
  }
}
if (problems.length) {
  console.error(problems.join('\n'));
  process.exit(1);
}

data.file = resolve(input);
data.generated ||= new Date().toISOString().slice(0, 10);
const template = readFileSync(new URL('./page.html', import.meta.url), 'utf8');
const json = JSON.stringify(data).replace(/</g, '\\u003c');
writeFileSync(output, template.replace('/*DATA*/', () => json));
const count = (key) => data.items.reduce((n, item) => n + (item[key] || []).length, 0);
console.log(`${output}: ${data.items.length} items, ${count('actions')} actions, ${count('questions')} questions (${basename(input)})`);
