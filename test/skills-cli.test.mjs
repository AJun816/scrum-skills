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
