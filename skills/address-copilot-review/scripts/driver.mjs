#!/usr/bin/env node
// driver.mjs — drive GitHub Copilot PR review threads via the `gh` CLI.
//
// This is the harness behind the `address-copilot-review` skill. It wraps the
// GitHub GraphQL/REST API (through `gh api`) so an agent can:
//   - list   : enumerate Copilot review threads on the current branch's PR
//   - show   : print one thread's full comment chain (Copilot note + replies)
//   - reply  : post an accept/reject rationale reply to a thread
//   - resolve / unresolve : flip a thread's resolved state
//
// Repo + PR are auto-detected from the current branch. Override with --pr N
// (or COPILOT_PR env). Copilot author is matched case-insensitively on login
// containing "copilot" (covers `copilot-pull-request-reviewer`).
//
// Requires: `gh` authenticated with `repo` scope. No npm deps.

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";

const COPILOT_RE = /copilot/i;

function gh(args, input) {
  return execFileSync("gh", args, {
    encoding: "utf8",
    input,
    maxBuffer: 64 * 1024 * 1024,
    stdio: ["pipe", "pipe", "pipe"],
  });
}

function ghJson(args, input) {
  return JSON.parse(gh(args, input));
}

function repoSlug() {
  if (process.env.COPILOT_REPO) {
    const [owner, name] = process.env.COPILOT_REPO.split("/");
    return { owner, name };
  }
  const r = ghJson(["repo", "view", "--json", "owner,name"]);
  return { owner: r.owner.login, name: r.name };
}

function prNumber(flagPr) {
  const n = flagPr || process.env.COPILOT_PR;
  if (n) return Number(n);
  // current branch's PR
  const r = ghJson(["pr", "view", "--json", "number"]);
  return r.number;
}

const THREADS_QUERY = `
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      url
      reviewThreads(first:100){
        nodes{
          id isResolved isOutdated
          comments(first:50){
            nodes{ author{login} body path line databaseId createdAt }
          }
        }
      }
    }
  }
}`;

function fetchThreads(ctx) {
  const data = ghJson([
    "api",
    "graphql",
    "-f",
    `query=${THREADS_QUERY}`,
    "-F",
    `owner=${ctx.owner}`,
    "-F",
    `repo=${ctx.name}`,
    "-F",
    `pr=${ctx.pr}`,
  ]);
  const pr = data.data.repository.pullRequest;
  const all = pr.reviewThreads.nodes;
  // A "Copilot thread" is one whose FIRST (root) comment is by Copilot.
  const copilot = all.filter(
    (t) =>
      t.comments.nodes[0] &&
      COPILOT_RE.test(t.comments.nodes[0].author?.login || ""),
  );
  return { url: pr.url, threads: copilot };
}

function resolveThreadId(ctx, idOrIndex) {
  // Accept a full thread node id (PRRT_...) or a 1-based index from `list`.
  if (/^PRRT_/.test(idOrIndex)) return idOrIndex;
  const idx = Number(idOrIndex);
  if (!Number.isInteger(idx)) {
    throw new Error(`Not a thread id or index: ${idOrIndex}`);
  }
  const { threads } = fetchThreads(ctx);
  const t = threads[idx - 1];
  if (!t)
    throw new Error(
      `No Copilot thread at index ${idx} (have ${threads.length})`,
    );
  return t.id;
}

function truncate(s, n) {
  const one = s.replace(/\s+/g, " ").trim();
  return one.length > n ? one.slice(0, n - 1) + "…" : one;
}

// ---- commands -------------------------------------------------------------

function cmdList(ctx) {
  const { url, threads } = fetchThreads(ctx);
  const open = threads.filter((t) => !t.isResolved);
  console.log(`PR #${ctx.pr}  ${url}`);
  console.log(
    `${threads.length} Copilot thread(s), ${open.length} unresolved\n`,
  );
  threads.forEach((t, i) => {
    const root = t.comments.nodes[0];
    const status = t.isResolved ? "RESOLVED" : "OPEN    ";
    const out = t.isOutdated ? " (outdated)" : "";
    const loc = `${root.path}:${root.line ?? "?"}`;
    console.log(`#${i + 1} [${status}]${out} ${loc}`);
    console.log(`    ${t.id}`);
    console.log(`    ${truncate(root.body, 140)}`);
    if (t.comments.nodes.length > 1) {
      console.log(
        `    └─ ${t.comments.nodes.length - 1} repl${t.comments.nodes.length === 2 ? "y" : "ies"}`,
      );
    }
    console.log("");
  });
}

function cmdShow(ctx, idOrIndex) {
  const id = resolveThreadId(ctx, idOrIndex);
  const { threads } = fetchThreads(ctx);
  const t = threads.find((x) => x.id === id);
  if (!t) throw new Error(`Thread not found: ${id}`);
  const root = t.comments.nodes[0];
  console.log(
    `Thread ${t.id}  [${t.isResolved ? "RESOLVED" : "OPEN"}]${t.isOutdated ? " (outdated)" : ""}`,
  );
  console.log(`${root.path}:${root.line ?? "?"}\n`);
  for (const c of t.comments.nodes) {
    console.log(`── @${c.author?.login} ── ${c.createdAt}`);
    console.log(c.body.trim());
    console.log("");
  }
}

function cmdReply(ctx, idOrIndex, body) {
  if (!body || !body.trim())
    throw new Error("Empty reply body. Pass --body or pipe via stdin.");
  const id = resolveThreadId(ctx, idOrIndex);
  const q = `mutation($t:ID!,$b:String!){
    addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$t,body:$b}){
      comment{ id databaseId url }
    }
  }`;
  const res = ghJson([
    "api",
    "graphql",
    "-f",
    `query=${q}`,
    "-F",
    `t=${id}`,
    "-f",
    `b=${body}`,
  ]);
  const c = res.data.addPullRequestReviewThreadReply.comment;
  console.log(`replied → ${c.url}  (databaseId ${c.databaseId})`);
}

function cmdSetResolved(ctx, idOrIndex, resolved) {
  const id = resolveThreadId(ctx, idOrIndex);
  const field = resolved ? "resolveReviewThread" : "unresolveReviewThread";
  const q = `mutation($t:ID!){
    ${field}(input:{threadId:$t}){ thread{ id isResolved } }
  }`;
  const res = ghJson(["api", "graphql", "-f", `query=${q}`, "-F", `t=${id}`]);
  const th = res.data[field].thread;
  console.log(`${id} → isResolved=${th.isResolved}`);
}

// ---- arg parsing ----------------------------------------------------------

function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--pr") out.pr = argv[++i];
    else if (a === "--body") out.body = argv[++i];
    else if (a === "--body-file") out.body = readFileSync(argv[++i], "utf8");
    else out._.push(a);
  }
  return out;
}

function readStdin() {
  try {
    return readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function main() {
  const a = parseArgs(process.argv.slice(2));
  const cmd = a._[0];
  if (!cmd || cmd === "help" || cmd === "-h" || cmd === "--help") {
    console.log(`Usage: node driver.mjs <command> [--pr N]

  list                       List Copilot review threads on the current PR
  show   <threadId|#index>   Print one thread's full comment chain
  reply  <threadId|#index>   Post a reply (--body "...", --body-file f, or stdin)
  resolve   <threadId|#index>
  unresolve <threadId|#index>

threadId looks like PRRT_...; #index is the 1-based number from \`list\`.
Repo/PR auto-detected from the current branch; override with --pr or COPILOT_PR.`);
    process.exit(cmd ? 0 : 1);
  }

  const { owner, name } = repoSlug();
  const ctx = { owner, name, pr: prNumber(a.pr) };
  const target = a._[1];

  switch (cmd) {
    case "list":
      return cmdList(ctx);
    case "show":
      return cmdShow(ctx, target);
    case "reply":
      return cmdReply(ctx, target, a.body ?? readStdin());
    case "resolve":
      return cmdSetResolved(ctx, target, true);
    case "unresolve":
      return cmdSetResolved(ctx, target, false);
    default:
      console.error(`Unknown command: ${cmd}`);
      process.exit(1);
  }
}

try {
  main();
} catch (err) {
  // gh failures surface their stderr on err.stderr; otherwise show the message.
  const detail = err.stderr ? String(err.stderr).trim() : err.message;
  console.error(`error: ${detail}`);
  process.exit(1);
}
