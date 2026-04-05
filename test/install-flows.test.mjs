import test from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const repoRoot = process.cwd();
const installScript = path.join(repoRoot, "install.sh");

function run(command, args, options = {}) {
  return execFileSync(command, args, {
    encoding: "utf8",
    ...options,
  });
}

function npmRun(args, options = {}) {
  const npmCacheDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-npm-cache-"));
  return run("npm", args, {
    env: {
      ...process.env,
      npm_config_cache: npmCacheDir,
      ...options.env,
    },
    ...options,
  });
}

function parseJson(command, args, options = {}) {
  return JSON.parse(run(command, args, options));
}

function makeTempRoot(prefix, t) {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), prefix));
  t.after(() => {
    fs.rmSync(tempRoot, { recursive: true, force: true });
  });
  return tempRoot;
}

function copyRepoForInstall(tempRoot) {
  const repoCopy = path.join(tempRoot, "repo-copy");
  fs.cpSync(repoRoot, repoCopy, {
    recursive: true,
    filter(source) {
      const relative = path.relative(repoRoot, source);
      if (!relative) {
        return true;
      }
      const topLevel = relative.split(path.sep)[0];
      return topLevel !== ".git" && topLevel !== "node_modules";
    },
  });
  return repoCopy;
}

function initGitRepo(repoDir) {
  fs.mkdirSync(repoDir, { recursive: true });
  run("git", ["init"], { cwd: repoDir });
  fs.writeFileSync(
    path.join(repoDir, "package.json"),
    '{"name":"sample-repo","private":true}\n',
  );
}

function assertExists(targetPath) {
  assert.ok(fs.existsSync(targetPath), `Expected path to exist: ${targetPath}`);
}

function assertMissing(targetPath) {
  assert.ok(!fs.existsSync(targetPath), `Expected path to be missing: ${targetPath}`);
}

test("copy-folder install provisions claude and codex targets", (t) => {
  const tempRoot = makeTempRoot("skills-install-copy-", t);
  const repoCopy = copyRepoForInstall(tempRoot);
  const claudeTarget = path.join(tempRoot, "claude-home", ".claude");
  const codexTarget = path.join(tempRoot, "codex-home", ".codex");

  run("sh", [path.join(repoCopy, "install.sh"), `--target=${claudeTarget}`, "--lang=en"]);
  run("sh", [path.join(repoCopy, "install.sh"), `--target=${codexTarget}`, "--lang=en"]);

  assertExists(path.join(claudeTarget, "skills", "0-emperor", "SKILL.md"));
  assertExists(path.join(codexTarget, "skills", "0-emperor", "SKILL.md"));
  assertExists(path.join(claudeTarget, "settings.json"));
  assertExists(path.join(claudeTarget, "skills", ".cache", "user-config.json"));
  assertExists(path.join(codexTarget, "skills", ".cache", "user-config.json"));
  assertExists(path.join(tempRoot, "claude-home", ".harness"));
  assertExists(path.join(tempRoot, "codex-home", ".harness"));
  assertMissing(path.join(codexTarget, "settings.json"));

  const settings = fs.readFileSync(path.join(claudeTarget, "settings.json"), "utf8");
  assert.match(settings, new RegExp(`${claudeTarget.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}/skills/hooks`));
});

test("installed codex pack bootstraps a fresh repo and reports machine-readable status", (t) => {
  const tempRoot = makeTempRoot("skills-installed-pack-", t);
  const codexTarget = path.join(tempRoot, "codex-home", ".codex");
  const repoDir = path.join(tempRoot, "sample-repo");
  const setupScript = path.join(codexTarget, "skills", "hooks", "setup.sh");
  const workflowReportScript = path.join(codexTarget, "skills", "runtime", "bin", "workflow-report.sh");
  const evalReportScript = path.join(codexTarget, "skills", "evals", "bin", "eval-report.sh");
  const packReportScript = path.join(codexTarget, "skills", "registry", "bin", "pack-report.sh");
  const skillsReportScript = path.join(codexTarget, "skills", "runtime", "bin", "skills-report.sh");
  const platformAuditScript = path.join(codexTarget, "skills", "harness", "bin", "harness-platform-audit.sh");
  const harnessReportScript = path.join(codexTarget, "skills", "harness", "bin", "harness-report.sh");

  run("sh", [installScript, `--target=${codexTarget}`, "--lang=en"], { cwd: repoRoot });
  initGitRepo(repoDir);
  run("sh", [setupScript, `--project-root=${repoDir}`, "--default", "--lang=en"]);

  assertExists(path.join(repoDir, ".harness"));
  assertExists(path.join(repoDir, "PROJECT_CONFIG.md"));
  assertExists(path.join(repoDir, ".cache", ".project-info.json"));
  assertExists(path.join(repoDir, ".cache", "shared", "repo-map.md"));
  assertExists(path.join(repoDir, ".cache", "shared", "repo-index.json"));

  const hooksPath = run("git", ["config", "--get", "core.hooksPath"], { cwd: repoDir }).trim();
  assert.equal(hooksPath, ".harness/git-hooks");

  const workflowReport = parseJson("sh", [workflowReportScript, `--project-root=${repoDir}`, "--json"]);
  const evalReport = parseJson("sh", [evalReportScript, `--project-root=${repoDir}`, "--json"]);
  const packReport = parseJson("sh", [packReportScript, `--target=${codexTarget}`, "--json"]);
  const skillsReport = parseJson("sh", [skillsReportScript, `--project-root=${repoDir}`, `--target=${codexTarget}`, "--json"]);
  const platformAudit = parseJson("sh", [platformAuditScript, `--project-root=${repoDir}`, "--json"]);
  const harnessReport = parseJson("sh", [harnessReportScript, `--project-root=${repoDir}`, "--json"]);

  assert.equal(workflowReport.status, "no_workflow_state");
  assert.equal(evalReport.status, "no_eval_activity");
  assert.equal(packReport.status, "no_pack_activity");
  assert.equal(skillsReport.overall_status, "ok");
  assert.equal(platformAudit.hooks_path, ".harness/git-hooks");
  assert.ok(platformAudit.current_branch.length > 0);
  assert.ok(!platformAudit.current_branch.includes("\n"));
  assert.equal(harnessReport.status, "ok");
});

test("global skills binary can install a usable target", (t) => {
  const tempRoot = makeTempRoot("skills-global-install-", t);
  const prefixDir = path.join(tempRoot, "prefix");
  const targetDir = path.join(tempRoot, "npm-home", ".codex");
  const reportScript = path.join(targetDir, "skills", "registry", "bin", "pack-report.sh");

  npmRun(["install", "--global", "--prefix", prefixDir, repoRoot], { cwd: repoRoot });

  const binary = process.platform === "win32"
    ? path.join(prefixDir, "skills.cmd")
    : path.join(prefixDir, "bin", "skills");

  run(binary, ["install", `--target=${targetDir}`, "--lang=en"], { cwd: repoRoot });

  assertExists(path.join(targetDir, "skills", "0-emperor", "SKILL.md"));
  assertExists(path.join(targetDir, "skills", ".cache", "user-config.json"));
  assertMissing(path.join(targetDir, "settings.json"));

  const packReport = parseJson("sh", [reportScript, `--target=${targetDir}`, "--json"]);
  assert.equal(packReport.status, "no_pack_activity");
});
