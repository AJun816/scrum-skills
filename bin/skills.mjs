#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const isWindows = process.platform === "win32";
const args = process.argv.slice(2);

function runResult(command, commandArgs) {
  return spawnSync(command, commandArgs, {
    cwd: process.cwd(),
    stdio: "inherit",
    env: process.env,
  });
}

function run(command, commandArgs) {
  const result = runResult(command, commandArgs);
  if (typeof result.status === "number") {
    process.exit(result.status);
  }
  process.exit(1);
}

function runShellScript(relativePath, passthroughArgs = []) {
  run("sh", [path.join(packageRoot, relativePath), ...passthroughArgs]);
}

function runInstall(passthroughArgs = []) {
  if (isWindows) {
    run("powershell", [
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      path.join(packageRoot, "install.ps1"),
      ...passthroughArgs,
    ]);
    return;
  }
  runShellScript("install.sh", passthroughArgs);
}

function printHelp() {
  console.log(`Usage:
  skills install [install.sh args...]
  skills setup [setup.sh args...]
  skills harness <init|check|fix|gate|worktree|checkpoint|repo-map|repo-index|selfcheck> [args...]
  skills workflow <start|status|resume|approve|reject|abort|reset|selfcheck> [args...]
  skills pack <list|doctor|install|update|selfcheck> [args...]
  skills doctor

Examples:
  skills install --agent=codex
  skills setup --project-root=/path/to/repo
  skills harness init --project-root=/path/to/repo
  skills workflow selfcheck
  skills pack list
  skills doctor`);
}

if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
  printHelp();
  process.exit(0);
}

const [group, ...rest] = args;

switch (group) {
  case "install":
    runInstall(rest);
    break;
  case "setup":
    runShellScript("skills/hooks/setup.sh", rest);
    break;
  case "harness": {
    const [subcommand, ...subArgs] = rest;
    const scriptMap = {
      init: "skills/harness/bin/harness-init.sh",
      check: "skills/harness/bin/harness-check.sh",
      fix: "skills/harness/bin/harness-fix.sh",
      gate: "skills/harness/bin/harness-gate.sh",
      worktree: "skills/harness/bin/harness-worktree.sh",
      checkpoint: "skills/harness/bin/harness-checkpoint.sh",
      "repo-map": "skills/harness/bin/harness-repo-map.sh",
      "repo-index": "skills/harness/bin/harness-repo-index.sh",
      selfcheck: "skills/harness/bin/harness-selfcheck.sh",
    };
    if (!subcommand || !scriptMap[subcommand]) {
      printHelp();
      process.exit(subcommand ? 1 : 0);
    }
    runShellScript(scriptMap[subcommand], subArgs);
    break;
  }
  case "workflow": {
    const [subcommand, ...subArgs] = rest;
    if (!subcommand) {
      printHelp();
      process.exit(1);
    }
    if (subcommand === "selfcheck") {
      runShellScript("skills/runtime/bin/workflow-selfcheck.sh", subArgs);
      break;
    }
    runShellScript("skills/runtime/bin/workflow.sh", [subcommand, ...subArgs]);
    break;
  }
  case "pack":
  case "registry": {
    const [subcommand, ...subArgs] = rest;
    const scriptMap = {
      list: "skills/registry/bin/pack-list.sh",
      doctor: "skills/registry/bin/pack-doctor.sh",
      install: "skills/registry/bin/pack-install.sh",
      update: "skills/registry/bin/pack-update.sh",
      selfcheck: "skills/registry/bin/pack-selfcheck.sh",
    };
    if (!subcommand || !scriptMap[subcommand]) {
      printHelp();
      process.exit(subcommand ? 1 : 0);
    }
    runShellScript(scriptMap[subcommand], subArgs);
    break;
  }
  case "doctor":
    for (const script of [
      "skills/harness/bin/harness-selfcheck.sh",
      "skills/runtime/bin/workflow-selfcheck.sh",
      "skills/registry/bin/pack-selfcheck.sh",
    ]) {
      const result = runResult("sh", [path.join(packageRoot, script)]);
      if (result.status !== 0) {
        process.exit(result.status ?? 1);
      }
    }
    break;
  default:
    printHelp();
    process.exit(1);
}
