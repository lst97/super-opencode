#!/usr/bin/env node

import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import chalk from "chalk";
import fs from "fs-extra";
import inquirer from "inquirer";

import ora from "ora";

// ESM replacement for __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const FRAMEWORK_DIR = path.join(__dirname, "..");

/**
 * Get the platform-specific global configuration directory for OpenCode
 * Follows XDG Base Directory Specification on Linux, standard locations on macOS and Windows
 */
function getGlobalConfigDir(): string {
	const platform = os.platform();
	const homeDir = os.homedir();

	// Check for OPENCODE_CONFIG_DIR environment variable first
	const envConfigDir = process.env.OPENCODE_CONFIG_DIR;
	if (envConfigDir) {
		return path.resolve(envConfigDir);
	}

	if (platform === "win32") {
		// Windows: %APPDATA%\opencode or %LOCALAPPDATA%\opencode
		const appData =
			process.env.APPDATA || path.join(homeDir, "AppData", "Roaming");
		return path.join(appData, "opencode");
	} else {
		// macOS and Linux: use ~/.config/opencode per spec
		const xdgConfigHome = process.env.XDG_CONFIG_HOME;
		if (xdgConfigHome) {
			return path.join(xdgConfigHome, "opencode");
		}
		// Default: ~/.config/opencode
		return path.join(homeDir, ".config", "opencode");
	}
}

/**
 * Get the framework installation directory
 * Returns the appropriate directory based on installation scope
 *
 * Note: According to OpenCode spec, framework files (agents, skills, commands)
 * should be in ~/.config/opencode/ alongside the opencode.json config file
 */
function getFrameworkInstallDir(scope: "global" | "project"): string {
	if (scope === "global") {
		// For global installations, use the config directory (NOT data directory)
		// This places agents/, skills/, commands/ alongside opencode.json
		return getGlobalConfigDir();
	}
	// For project installations, use current working directory
	return process.cwd();
}

/**
 * Get the path to the opencode.json configuration file
 */
function getConfigFilePath(
	scope: "global" | "project",
	targetDir: string,
): string {
	if (scope === "global") {
		return path.join(getGlobalConfigDir(), CONFIG_FILENAME);
	}
	return path.join(targetDir, CONFIG_FILENAME);
}

/**
 * Get the default allowed paths for Filesystem MCP based on platform
 */
function getDefaultFilesystemPaths(targetDir: string): string[] {
	const platform = os.platform();
	const homeDir = os.homedir();

	// Always include the target project directory
	const paths = [targetDir];

	if (platform === "win32") {
		// Windows: include Documents folder and home
		paths.push(path.join(homeDir, "Documents"));
	} else {
		// Unix-like: include home directory
		paths.push(homeDir);
	}

	return paths;
}

interface InstallerAnswers {
	scope: "global" | "project";
	proceed: boolean;
	modules: string[];
	overwrite: boolean;
	installMcp?: boolean;
	selectedServers?: string[];
	allowedPaths?: string;
}

interface McpServerConfig {
	type: "local";
	command: string[];
	environment?: Record<string, string>;
	enabled?: boolean;
}

interface Settings {
	mcp?: Record<string, McpServerConfig>;
	mcpServers?: Record<string, McpServerConfig>;
	[key: string]: unknown;
}

interface McpServerDefinition {
	name: string;
	value: string;
	env: Array<string | { name: string; optional: boolean }>;
	recommended: boolean;
}

const MCP_KEY = "mcp";
const MCP_SERVERS_KEY = "mcpServers";
const CONFIG_FILENAME = "opencode.json";
const FALLBACK_FILENAME = "mcp_settings.json";

function sanitizePaths(pathInput: string): string[] {
	const paths = pathInput
		.split(",")
		.map((p) => p.trim())
		.filter(Boolean);
	return paths.map((p) => {
		const resolved = path.resolve(p);
		return resolved;
	});
}

const AVAILABLE_MCP_SERVERS: McpServerDefinition[] = [
	{
		name: "Context7 (Recommended)",
		value: "context7",
		env: [],
		recommended: true,
	},
	{ name: "Serena (Recommended)", value: "serena", env: [], recommended: true },
	{
		name: "Tavily Search (Recommended)",
		value: "tavily",
		env: [{ name: "TAVILY_API_KEY", optional: true }],
		recommended: true,
	},
	{
		name: "Filesystem (Recommended)",
		value: "filesystem",
		env: [],
		recommended: true,
	},
	{
		name: "Sequential Thinking (Recommended)",
		value: "sequential-thinking",
		env: [],
		recommended: true,
	},
	{
		name: "GitHub",
		value: "github",
		env: [{ name: "GITHUB_PERSONAL_ACCESS_TOKEN", optional: false }],
		recommended: false,
	},
	{ name: "SQLite", value: "sqlite", env: [], recommended: false },
	{
		name: "Chrome DevTools",
		value: "chrome-devtools",
		env: [],
		recommended: false,
	},
	{ name: "Playwright", value: "playwright", env: [], recommended: false },
];

function getMcpServerConfig(
	serverId: string,
	envVars: Record<string, string>,
	targetDir: string,
): McpServerConfig {
	const configs: Record<string, McpServerConfig> = {
		context7: {
			type: "local",
			command: ["npx", "-y", "@upstash/context7-mcp"],
			environment: envVars,
		},
		serena: {
			type: "local",
			command: [
				"uvx",
				"--from",
				"git+https://github.com/oraios/serena",
				"serena",
				"start-mcp-server",
				"--context",
				"ide-assistant",
				"--enable-web-dashboard",
				"false",
				"--enable-gui-log-window",
				"false",
			],
			environment: envVars,
		},
		tavily: {
			type: "local",
			command: ["npx", "-y", "tavily-mcp@latest"],
			environment: envVars,
		},
		"sequential-thinking": {
			type: "local",
			command: [
				"npx",
				"-y",
				"@modelcontextprotocol/server-sequential-thinking",
			],
			environment: envVars,
		},
		github: {
			type: "local",
			command: ["npx", "-y", "@modelcontextprotocol/server-github"],
			environment: envVars,
		},
		sqlite: {
			type: "local",
			command: ["uvx", "mcp-server-sqlite", "--memory"],
		},
		"chrome-devtools": {
			type: "local",
			command: ["npx", "-y", "chrome-devtools-mcp@latest"],
		},
		playwright: {
			type: "local",
			command: ["npx", "-y", "@playwright/mcp@latest"],
		},
	};

	if (serverId === "filesystem") {
		const sanitizedPaths = [targetDir];
		return {
			type: "local",
			command: [
				"npx",
				"-y",
				"@modelcontextprotocol/server-filesystem",
				...sanitizedPaths,
			],
		};
	}

	return configs[serverId];
}

async function copyFile(
	src: string,
	dest: string,
	targetDir: string,
	overwrite: boolean,
): Promise<void> {
	const srcPath = path.join(FRAMEWORK_DIR, src);
	const destPath = path.join(targetDir, dest);

	// Only validate destination path (user-controlled)
	const resolvedDest = path.resolve(destPath);
	const resolvedTarget = path.resolve(targetDir);
	if (
		!resolvedDest.startsWith(resolvedTarget + path.sep) &&
		resolvedDest !== resolvedTarget
	) {
		throw new Error(
			`Path traversal detected: ${resolvedDest} is outside ${resolvedTarget}`,
		);
	}

	if (await fs.pathExists(srcPath)) {
		try {
			await fs.copy(srcPath, destPath, { overwrite });
		} catch (err) {
			if (!overwrite && (await fs.pathExists(destPath))) {
				return;
			}
			throw err;
		}
	}
}

async function installModules(
	modules: string[],
	targetDir: string,
	overwrite: boolean,
	scope: "global" | "project",
): Promise<void> {
	// For global installs, copy directly to targetDir/agents (no .opencode wrapper)
	// For project installs, copy to targetDir/.opencode/agents
	const agentsDest = scope === "global" ? "agents" : ".opencode/agents";
	const commandsDest = scope === "global" ? "commands" : ".opencode/commands";
	const skillsDest = scope === "global" ? "skills" : ".opencode/skills";

	const moduleMap: Record<string, [string, string]> = {
		core: ["README.md", "README.md"],
		agents: [".opencode/agents", agentsDest],
		commands: [".opencode/commands", commandsDest],
		skills: [".opencode/skills", skillsDest],
	};

	for (const module of modules) {
		const [src, dest] = moduleMap[module] || [];
		if (src && dest) {
			await copyFile(src, dest, targetDir, overwrite);
			if (module === "core") {
				await fs.ensureDir(path.join(targetDir, ".opencode"));
				await copyFile("AGENTS.md", "AGENTS.md", targetDir, overwrite);
				await copyFile("LICENSE", "LICENSE", targetDir, overwrite);
			}
		}
	}
}

async function promptForMcpServers(): Promise<{
	installMcp: boolean;
	selectedServers: string[];
}> {
	const { installMcp } = await inquirer.prompt([
		{
			type: "confirm",
			name: "installMcp",
			message: "Would you like to configure MCP Servers?",
			default: false,
		},
	]);

	if (!installMcp) {
		return { installMcp: false, selectedServers: [] };
	}

	const { selectedServers } = await inquirer.prompt([
		{
			type: "checkbox",
			name: "selectedServers",
			message: "Select MCP components to install:",
			choices: AVAILABLE_MCP_SERVERS.map((s) => ({
				name: s.name,
				value: s.value,
				checked: s.recommended,
			})),
			pageSize: 15,
		},
	]);

	return { installMcp: true, selectedServers };
}

async function collectEnvVars(
	serverDef: McpServerDefinition,
): Promise<Record<string, string>> {
	const envVars: Record<string, string> = {};

	for (const envDef of serverDef.env) {
		const envName = typeof envDef === "string" ? envDef : envDef.name;
		const isOptional = typeof envDef === "string" ? false : envDef.optional;

		const { value } = await inquirer.prompt([
			{
				type: "input",
				name: "value",
				message: `Enter ${envName} for ${serverDef.name}${isOptional ? " (Optional)" : ""}:`,
				validate: (input) => {
					if (isOptional) return true;
					return input.length > 0 ? true : `${envName} is required`;
				},
			},
		]);

		if (value || !isOptional) {
			envVars[envName] = value;
		}
	}

	return envVars;
}

async function configureFilesystemMcp(
	targetDir: string,
): Promise<McpServerConfig> {
	const defaultPaths = getDefaultFilesystemPaths(targetDir);
	const { allowedPaths: pathsInput } = await inquirer.prompt([
		{
			type: "input",
			name: "allowedPaths",
			message: "Enter absolute paths for Filesystem MCP (comma separated):",
			default: defaultPaths.join(", "),
		},
	]);
	const sanitizedPaths = sanitizePaths(pathsInput);

	// Validate that paths exist and are accessible
	const validPaths: string[] = [];
	for (const p of sanitizedPaths) {
		try {
			const stats = await fs.stat(p);
			if (stats.isDirectory()) {
				validPaths.push(p);
			} else {
				console.warn(chalk.yellow(`⚠️  Skipping non-directory path: ${p}`));
			}
		} catch {
			console.warn(
				chalk.yellow(`⚠️  Path does not exist or is not accessible: ${p}`),
			);
		}
	}

	if (validPaths.length === 0) {
		console.warn(
			chalk.yellow("⚠️  No valid paths provided. Using target directory only."),
		);
		validPaths.push(targetDir);
	}

	return {
		type: "local",
		command: [
			"npx",
			"-y",
			"@modelcontextprotocol/server-filesystem",
			...validPaths,
		],
	};
}

async function collectMcpServerConfigs(
	selectedServers: string[],
	targetDir: string,
): Promise<Record<string, McpServerConfig>> {
	const mcpServers: Record<string, McpServerConfig> = {};

	for (const serverId of selectedServers) {
		const serverDef = AVAILABLE_MCP_SERVERS.find((s) => s.value === serverId);
		if (!serverDef) continue;

		if (serverId === "filesystem") {
			mcpServers.filesystem = await configureFilesystemMcp(targetDir);
		} else {
			const envVars = await collectEnvVars(serverDef);
			const config = getMcpServerConfig(serverId, envVars, targetDir);
			if (config) {
				mcpServers[serverId] = config;
			}
		}
	}

	return mcpServers;
}

async function writeMcpConfiguration(
	mcpServers: Record<string, McpServerConfig>,
	scope: "global" | "project",
	targetDir: string,
): Promise<void> {
	const configPath = getConfigFilePath(scope, targetDir);

	let finalSettings: Settings = {};
	let writeTarget = configPath;

	if (scope === "global") {
		await fs.ensureDir(path.dirname(configPath));
	}

	if (await fs.pathExists(configPath)) {
		try {
			finalSettings = await fs.readJson(configPath);
			console.log(
				chalk.blue(
					`ℹ️  Found existing configuration at ${configPath}, merging...`,
				),
			);
		} catch {
			console.warn(
				chalk.yellow(
					`⚠️  Could not parse existing ${configPath} (might contain comments), writing to ${FALLBACK_FILENAME} instead to avoid data loss.`,
				),
			);
			writeTarget = path.join(targetDir, FALLBACK_FILENAME);
			finalSettings = { mcpServers: {} };
		}
	}

	const isMainConfig = writeTarget.endsWith(CONFIG_FILENAME);
	const mcpKey = isMainConfig ? MCP_KEY : MCP_SERVERS_KEY;

	if (!finalSettings[mcpKey]) {
		finalSettings[mcpKey] = {};
	}

	finalSettings[mcpKey] = {
		...finalSettings[mcpKey],
		...mcpServers,
	};

	await fs.writeJson(writeTarget, finalSettings, { spaces: 2 });

	if (writeTarget !== configPath) {
		console.log(chalk.green(`✅ MCP configuration saved to ${writeTarget}`));
		console.log(
			chalk.yellow(
				`👉 Please manually copy the contents of '${MCP_SERVERS_KEY}' into the '${MCP_KEY}' section of your ${configPath}`,
			),
		);
	} else {
		console.log(
			chalk.green(`✅ OpenCode configuration updated at ${writeTarget}`),
		);
	}
}

async function handleMcpInstallation(
	scope: "global" | "project",
	targetDir: string,
): Promise<void> {
	const { installMcp, selectedServers } = await promptForMcpServers();

	if (!installMcp || selectedServers.length === 0) {
		return;
	}

	const mcpServers = await collectMcpServerConfigs(selectedServers, targetDir);

	if (Object.keys(mcpServers).length > 0) {
		await writeMcpConfiguration(mcpServers, scope, targetDir);
	}
}

async function main(): Promise<void> {
	console.log(chalk.cyan.bold("\n🚀 Welcome to Super-OpenCode Installer\n"));

	// Show platform info
	const platform = os.platform();
	const homeDir = os.homedir();
	console.log(chalk.gray(`Platform: ${platform} | Home: ${homeDir}\n`));

	// Display installation options info before selection
	console.log(chalk.cyan("📦 Installation Options:\n"));
	console.log(chalk.white("🌍 Global Install (Recommended)"));
	console.log(chalk.gray(`   Framework: ${getGlobalConfigDir()}`));
	console.log(
		chalk.gray(
			`   Config: ${path.join(getGlobalConfigDir(), "opencode.json")}`,
		),
	);
	console.log(chalk.gray(`   Available for all projects\n`));
	console.log(chalk.white("📁 Project Install (Current Directory)"));
	console.log(chalk.gray(`   Framework: ${process.cwd()}`));
	console.log(
		chalk.gray(`   Config: ${path.join(process.cwd(), "opencode.json")}`),
	);
	console.log(chalk.gray(`   Project-specific only\n`));

	const scopeAnswer = await inquirer.prompt([
		{
			type: "list",
			name: "scope",
			message: "Where would you like to install Super-OpenCode?",
			choices: [
				{ name: "🌍 Global (Recommended)", value: "global" },
				{ name: "📁 Project (Current Directory)", value: "project" },
			],
			default: "global",
		},
	]);

	const targetDir = getFrameworkInstallDir(
		scopeAnswer.scope as "global" | "project",
	);

	const questions = [
		{
			type: "confirm",
			name: "proceed",
			message: `\n📦 Ready to install to:\n   ${chalk.cyan(targetDir)}\n\n   ${chalk.gray("This will create:")}\n   ${chalk.gray("• Framework files (agents, commands, skills)")}\n   ${chalk.gray("• Configuration file (opencode.json)")}\n\nProceed with installation?`,
			default: true,
		},
		{
			type: "checkbox",
			name: "modules",
			message: "Select components to install:",
			choices: [
				{
					name: "Core (README, LICENSE, AGENTS.md)",
					value: "core",
					checked: true,
				},
				{
					name: "Agents (Specialized Personas)",
					value: "agents",
					checked: true,
				},
				{ name: "Commands (Slash Commands)", value: "commands", checked: true },
				{ name: "Skills (capabilities)", value: "skills", checked: true },
			],
			when: (answers: InstallerAnswers) => answers.proceed,
		},
		{
			type: "confirm",
			name: "overwrite",
			message: "Overwrite existing files if found?",
			default: false,
			when: (answers: InstallerAnswers) => answers.proceed,
		},
	];

	// biome-ignore lint/suspicious/noExplicitAny: inquirer types are complex, using any for compatibility
	const answers = await inquirer.prompt<InstallerAnswers>(questions as any);

	if (!answers.proceed) {
		console.log(chalk.yellow("Installation cancelled."));
		return;
	}

	const spinner = ora("Installing Super-OpenCode...").start();

	try {
		const { modules, overwrite } = answers;
		await installModules(modules, targetDir, overwrite, scopeAnswer.scope);

		spinner.stop();

		await handleMcpInstallation(scopeAnswer.scope, targetDir);

		spinner.start();
		spinner.succeed(chalk.green("Installation complete!"));

		console.log(chalk.green.bold("\n✨ Installation Summary\n"));
		console.log(chalk.white(`📦 Framework: ${chalk.cyan(targetDir)}`));
		console.log(
			chalk.white(
				`⚙️  Config: ${chalk.cyan(getConfigFilePath(scopeAnswer.scope as "global" | "project", targetDir))}\n`,
			),
		);

		console.log(chalk.yellow.bold("Next Steps:\n"));
		console.log(chalk.white("1. 📖 Read AGENTS.md for workflow guidelines"));
		console.log(chalk.white("2. 🔧 Configure MCP servers if needed"));
		console.log(chalk.white("3. 🚀 Start using: super-opencode --help\n"));

		if (scopeAnswer.scope === "global") {
			console.log(chalk.gray("💡 The framework is now available globally"));
			console.log(
				chalk.gray("   Use 'super-opencode' command from any project\n"),
			);
		} else {
			console.log(
				chalk.gray(
					"💡 The framework is installed in the current project only\n",
				),
			);
		}
	} catch (error) {
		spinner.fail(chalk.red("Installation failed."));
		console.error(error);
	}
}

main().catch(console.error);
