import test from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const repoRoot = process.cwd();
const cliPath = path.join(repoRoot, "bin", "skills.mjs");

function run(command, args, options = {}) {
  return execFileSync(command, args, {
    cwd: repoRoot,
    encoding: "utf8",
    ...options,
  });
}

function npmRun(args, options = {}) {
  const npmCacheDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-npm-cache-"));
  return run("npm", args, {
    ...options,
    env: {
      ...process.env,
      npm_config_cache: npmCacheDir,
      ...options.env,
    },
  });
}

test("skills help is available", () => {
  const output = run("node", [cliPath, "--help"]);
  assert.match(output, /skills install/);
  assert.match(output, /skills doctor/);
});

test("skills pack list works via node entry", () => {
  const output = run("node", [cliPath, "pack", "list"]);
  assert.match(output, /gstack/);
  assert.match(output, /find-community/);
});

test("skills eval list works via node entry", () => {
  const output = run("node", [cliPath, "eval", "list"]);
  assert.match(output, /skills-help/);
  assert.match(output, /skills-doctor/);
});

test("skills eval report returns machine-readable no-activity output", () => {
  const emptyProjectDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-eval-empty-"));
  const output = run("node", [
    cliPath,
    "eval",
    "report",
    `--project-root=${emptyProjectDir}`,
    "--json",
  ]);
  assert.match(output, /"status": "no_eval_activity"/);
  assert.match(output, /"project_root":/);
});

test("skills pack report returns machine-readable no-activity output", () => {
  const emptyTarget = fs.mkdtempSync(path.join(os.tmpdir(), "skills-pack-empty-"));
  const output = run("node", [
    cliPath,
    "pack",
    "report",
    `--target=${emptyTarget}`,
    "--json",
  ]);
  assert.match(output, /"status": "no_pack_activity"/);
  assert.match(output, /"target_root":/);
});

test("skills harness platform-audit works via node entry", () => {
  const output = run("node", [cliPath, "harness", "platform-audit", "--json"]);
  assert.match(output, /"overall_status":/);
  assert.match(output, /"local_checks":/);
});

test("skills harness report returns machine-readable no-activity output", () => {
  const emptyProjectDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-harness-empty-"));
  const output = run("node", [
    cliPath,
    "harness",
    "report",
    `--project-root=${emptyProjectDir}`,
    "--json",
  ]);
  assert.match(output, /"status": "no_harness_activity"/);
  assert.match(output, /"project_root":/);
});

test("skills workflow report returns machine-readable no-state output", () => {
  const emptyProjectDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-workflow-empty-"));
  const output = run("node", [
    cliPath,
    "workflow",
    "report",
    `--project-root=${emptyProjectDir}`,
    "--json",
  ]);
  assert.match(output, /"status": "no_workflow_state"/);
  assert.match(output, /"project_root":/);
});

test("skills report returns machine-readable empty overview", () => {
  const emptyProjectDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-report-empty-"));
  const output = run("node", [
    cliPath,
    "report",
    "--recent=3",
    `--project-root=${emptyProjectDir}`,
    `--target=${emptyProjectDir}`,
    "--json",
  ]);
  assert.match(output, /"overall_status": "empty"/);
  assert.match(output, /"recent_window": 3/);
  assert.match(output, /"recent_attention":/);
  assert.match(output, /"workflow":/);
  assert.match(output, /"harness":/);
  assert.match(output, /"eval":/);
  assert.match(output, /"pack":/);
});

test("npm global install exposes skills binary", () => {
  const prefixDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-prefix-"));
  npmRun(["install", "--global", "--prefix", prefixDir, repoRoot]);
  const binDir = path.join(prefixDir, process.platform === "win32" ? "" : "bin");
  const binary = process.platform === "win32"
    ? path.join(prefixDir, "skills.cmd")
    : path.join(binDir, "skills");
  const output = run(binary, ["--help"]);
  assert.match(output, /skills workflow/);
});

test("npm exec can run packaged skills binary", () => {
  const output = npmRun([
    "exec",
    "--yes",
    "--package",
    `file:${repoRoot}`,
    "--",
    "skills",
    "--help",
  ]);
  assert.match(output, /skills harness/);
});
