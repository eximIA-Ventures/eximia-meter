#!/usr/bin/env node

/**
 * exímIA Meter — Installer
 *
 * Usage: npx eximia-meter
 *
 * Downloads, builds and installs exímIA Meter on macOS.
 * Requires: macOS 14+, Xcode Command Line Tools (swift)
 */

import { execSync, spawn } from 'node:child_process';
import { existsSync, mkdtempSync, rmSync, cpSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const APP_NAME = 'exímIA Meter';
const REPO_URL = 'https://github.com/eximIA-Ventures/eximia-meter.git';
const INSTALL_PATH = '/Applications/exímIA Meter.app';

// ─── Colors ──────────────────────────────────────────
const c = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  amber: '\x1b[38;2;245;158;11m',
  green: '\x1b[38;2;16;185;129m',
  red: '\x1b[38;2;239;68;68m',
  white: '\x1b[37m',
  gray: '\x1b[90m',
};

function log(msg) { console.log(`  ${msg}`); }
function header(msg) { console.log(`\n  ${c.amber}${c.bold}${msg}${c.reset}`); }
function success(msg) { console.log(`  ${c.green}✓${c.reset} ${msg}`); }
function error(msg) { console.error(`  ${c.red}✗${c.reset} ${msg}`); }
function info(msg) { console.log(`  ${c.gray}${msg}${c.reset}`); }

function run(cmd, opts = {}) {
  return execSync(cmd, { encoding: 'utf-8', stdio: opts.silent ? 'pipe' : 'inherit', ...opts });
}

function runSilent(cmd) {
  return execSync(cmd, { encoding: 'utf-8', stdio: 'pipe' }).trim();
}

// ─── Checks ──────────────────────────────────────────

function checkPlatform() {
  if (process.platform !== 'darwin') {
    error('exímIA Meter is only available for macOS.');
    process.exit(1);
  }
}

function checkSwift() {
  try {
    const version = runSilent('swift --version');
    const match = version.match(/Swift version ([\d.]+)/);
    if (match) {
      success(`Swift ${match[1]} found`);
      return true;
    }
  } catch {
    // not found
  }

  error('Swift not found. Install Xcode Command Line Tools:');
  log(`  ${c.white}xcode-select --install${c.reset}`);
  process.exit(1);
}

function checkMacOSVersion() {
  try {
    const version = runSilent('sw_vers -productVersion');
    const major = parseInt(version.split('.')[0]);
    if (major < 14) {
      error(`macOS 14 (Sonoma) or later required. You have macOS ${version}.`);
      process.exit(1);
    }
    success(`macOS ${version}`);
  } catch {
    // ignore
  }
}

// ─── Main ────────────────────────────────────────────

async function main() {
  console.log('');
  console.log(`  ${c.amber}${c.bold}┌──────────────────────────────────────┐${c.reset}`);
  console.log(`  ${c.amber}${c.bold}│${c.reset}   ${c.white}${c.bold}exímIA Meter${c.reset}  ${c.dim}Installer${c.reset}           ${c.amber}${c.bold}│${c.reset}`);
  console.log(`  ${c.amber}${c.bold}│${c.reset}   ${c.gray}Claude Code Usage Monitor${c.reset}          ${c.amber}${c.bold}│${c.reset}`);
  console.log(`  ${c.amber}${c.bold}└──────────────────────────────────────┘${c.reset}`);

  // ─── Pre-flight checks
  header('Pre-flight checks');
  checkPlatform();
  checkMacOSVersion();
  checkSwift();

  // ─── Check if already installed
  if (existsSync(INSTALL_PATH)) {
    info(`Existing installation found at ${INSTALL_PATH}`);
    info('Will be replaced with the new build.');
  }

  // ─── Clone or use local
  header('Downloading source...');

  const tmpDir = mkdtempSync(join(tmpdir(), 'eximia-meter-'));
  const srcDir = join(tmpDir, 'eximia-meter');

  try {
    run(`git clone --depth 1 ${REPO_URL} "${srcDir}"`, { silent: true });
    success('Source downloaded');
  } catch (e) {
    error('Failed to clone repository.');
    info('Check your internet connection and try again.');
    rmSync(tmpDir, { recursive: true, force: true });
    process.exit(1);
  }

  // ─── Build
  header('Building (this may take a minute)...');

  try {
    const buildOutput = execSync(`cd "${srcDir}" && swift build -c release 2>&1`, { encoding: 'utf-8', stdio: 'pipe' });
    success('Build complete');
  } catch (e) {
    error('Build failed:');
    if (e.stdout) console.log(e.stdout.split('\n').slice(-10).join('\n'));
    if (e.stderr) console.log(e.stderr.split('\n').slice(-10).join('\n'));
    info('Make sure Xcode Command Line Tools are properly installed:');
    log(`  ${c.white}xcode-select --install${c.reset}`);
    rmSync(tmpDir, { recursive: true, force: true });
    process.exit(1);
  }

  // ─── Create .app bundle
  header('Creating app bundle...');

  const binary = join(srcDir, '.build/release/EximiaMeter');
  const appBundle = join(tmpDir, `${APP_NAME}.app`);

  if (!existsSync(binary)) {
    error('Binary not found after build.');
    rmSync(tmpDir, { recursive: true, force: true });
    process.exit(1);
  }

  // Create bundle structure
  const contentsDir = join(appBundle, 'Contents');
  const macOSDir = join(contentsDir, 'MacOS');
  const resourcesDir = join(contentsDir, 'Resources');

  mkdtempSync; // just to use node:fs
  execSync(`mkdir -p "${macOSDir}" "${resourcesDir}"`);

  // Copy binary
  cpSync(binary, join(macOSDir, 'EximiaMeter'));
  execSync(`chmod +x "${join(macOSDir, 'EximiaMeter')}"`);

  // Copy Info.plist
  const plistSrc = join(srcDir, 'Info.plist');
  if (existsSync(plistSrc)) {
    cpSync(plistSrc, join(contentsDir, 'Info.plist'));
  }

  // PkgInfo
  execSync(`echo -n "APPL????" > "${join(contentsDir, 'PkgInfo')}"`);

  success('App bundle created');

  // ─── Install
  header('Installing...');

  try {
    // Remove old version if exists
    if (existsSync(INSTALL_PATH)) {
      rmSync(INSTALL_PATH, { recursive: true, force: true });
    }

    // Copy to Applications
    cpSync(appBundle, INSTALL_PATH, { recursive: true });
    success(`Installed to ${INSTALL_PATH}`);
  } catch (e) {
    error('Failed to install to /Applications.');
    info('Trying with sudo...');
    try {
      run(`sudo cp -R "${appBundle}" "/Applications/"`, { silent: true });
      success('Installed with elevated permissions');
    } catch {
      error('Installation failed. Try manually:');
      log(`  ${c.white}cp -R "${appBundle}" /Applications/${c.reset}`);
      rmSync(tmpDir, { recursive: true, force: true });
      process.exit(1);
    }
  }

  // ─── Cleanup
  rmSync(tmpDir, { recursive: true, force: true });
  success('Cleaned up temp files');

  // ─── Launch
  header('Launching exímIA Meter...');

  try {
    execSync(`open "${INSTALL_PATH}"`);
    success('App launched!');
  } catch {
    info('Could not auto-launch. Open manually from Applications.');
  }

  // ─── Done
  console.log('');
  console.log(`  ${c.amber}${c.bold}════════════════════════════════════════${c.reset}`);
  console.log(`  ${c.green}${c.bold}  exímIA Meter installed successfully!${c.reset}`);
  console.log(`  ${c.amber}${c.bold}════════════════════════════════════════${c.reset}`);
  console.log('');
  console.log(`  ${c.gray}The app appears in your menu bar (top right).${c.reset}`);
  console.log(`  ${c.gray}Look for the exímIA logo icon.${c.reset}`);
  console.log('');
  console.log(`  ${c.dim}To uninstall:${c.reset}`);
  console.log(`  ${c.white}rm -rf "${INSTALL_PATH}"${c.reset}`);
  console.log('');
}

main().catch((e) => {
  error(`Unexpected error: ${e.message}`);
  process.exit(1);
});
