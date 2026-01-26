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

/**
 * Validates that a resolved path is within the allowed base directory
 * @throws Error if path traversal is detected
 */
function resolveSafePath(baseDir: string, targetPath: string): string {
	const resolvedBase = path.resolve(baseDir);
	const resolvedTarget = path.resolve(targetPath);

	if (
		!resolvedTarget.startsWith(resolvedBase + path.sep) &&
		resolvedTarget !== resolvedBase
	) {
		throw new Error(
			`Path traversal detected: ${resolvedTarget} is outside ${resolvedBase}`,
		);
	}

	return resolvedTarget;
}

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
	const srcPath = resolveSafePath(FRAMEWORK_DIR, path.join(FRAMEWORK_DIR, src));
	const destPath = resolveSafePath(targetDir, path.join(targetDir, dest));

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
): Promise<void> {
	const moduleMap: Record<string, [string, string]> = {
		core: ["README.md", "README.md"],
		agents: [".opencode/agents", ".opencode/agents"],
		commands: [".opencode/commands", ".opencode/commands"],
		skills: [".opencode/skills", ".opencode/skills"],
	};

	for (const module of modules) {
		const [src, dest] = moduleMap[module] || [];
		if (src && dest) {
			await copyFile(src, dest, targetDir, overwrite);
			if (module === "core") {
				await fs.ensureDir(path.join(targetDir, ".opencode"));
				await copyFile("AGENTS.md", "AGENTS.md", targetDir, overwrite);
				await copyFile("LICENSE", "LICENSE", targetDir, overwrite);
				await copyFile(
					".opencode/settings.json",
					".opencode/settings.json",
					targetDir,
					overwrite,
				);
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
	const { allowedPaths: pathsInput } = await inquirer.prompt([
		{
			type: "input",
			name: "allowedPaths",
			message: "Enter absolute paths for Filesystem MCP (comma separated):",
			default: targetDir,
		},
	]);
	const sanitizedPaths = sanitizePaths(pathsInput);

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
	const configPath =
		scope === "global"
			? path.join(os.homedir(), ".config", "opencode", CONFIG_FILENAME)
			: path.join(process.cwd(), CONFIG_FILENAME);

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

	const scopeAnswer = await inquirer.prompt([
		{
			type: "list",
			name: "scope",
			message: "Where would you like to install Super-OpenCode?",
			choices: [
				{ name: "Global (Recommended for User-wide access)", value: "global" },
				{ name: "Project (Current Directory)", value: "project" },
			],
			default: "global",
		},
	]);

	const targetDir =
		scopeAnswer.scope === "global"
			? path.join(os.homedir(), ".opencode")
			: process.cwd();

	const questions = [
		{
			type: "confirm",
			name: "proceed",
			message: `Install Super-OpenCode to ${chalk.yellow(targetDir)}?`,
			default: true,
		},
		{
			type: "checkbox",
			name: "modules",
			message: "Select components to install:",
			choices: [
				{
					name: "Core (README, LICENSE, AGENTS.md, settings.json)",
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

	const answers = await inquirer.prompt<InstallerAnswers>(questions as any);

	if (!answers.proceed) {
		console.log(chalk.yellow("Installation cancelled."));
		return;
	}

	const spinner = ora("Installing Super-OpenCode...").start();

	try {
		const { modules, overwrite } = answers;
		await installModules(modules, targetDir, overwrite);

		spinner.stop();

		await handleMcpInstallation(scopeAnswer.scope, targetDir);

		spinner.start();
		spinner.succeed(chalk.green("Installation complete!"));

		console.log("\nNext steps:");
		if (scopeAnswer.scope === "global") {
			console.log(
				chalk.white(`1. Framework installed to: ${chalk.cyan(targetDir)}`),
			);
			console.log(
				chalk.white(
					`2. Configuration updated at: ${chalk.cyan(path.join(os.homedir(), ".config", "opencode", "opencode.json"))}`,
				),
			);
		} else {
			console.log(chalk.white("1. Read AGENTS.md to understand the workflow."));
			console.log(chalk.white("2. Configuration updated in ./opencode.json"));
		}
	} catch (error) {
		spinner.fail(chalk.red("Installation failed."));
		console.error(error);
	}
}

main().catch(console.error);
