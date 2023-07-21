import { execSync } from "node:child_process";
import { existsSync as fsExistsSync } from "node:fs";
import { mkdir as fsMkdir, readdir as fsReaddir, readFile as fsReadFile, rm as fsRm, writeFile as fsWriteFile } from "node:fs/promises";
import { dirname as pathDirname, join as pathJoin } from "node:path";
import { fileURLToPath } from "node:url";
const root = pathDirname(fileURLToPath(import.meta.url));
const packageFileName = "package.json";
const scriptEntryPointFileName = "main.js";
const inputDirectoryPath = pathJoin(root, "temp");
const inputFilePath = pathJoin(inputDirectoryPath, scriptEntryPointFileName);
const outputDirectoryPath = pathJoin(root, "hugoalh.GitHubActionsToolkit", "nodejs-wrapper");
const outputFilePath = pathJoin(outputDirectoryPath, scriptEntryPointFileName);
export default {
	entry: inputFilePath,
	mode: "none",
	optimization: {
		usedExports: true
	},
	output: {
		path: outputDirectoryPath,
		filename: scriptEntryPointFileName
	},
	target: "node14.15"
};
