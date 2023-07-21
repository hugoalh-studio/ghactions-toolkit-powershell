import { execSync } from "node:child_process";
import { existsSync as fsExistsSync } from "node:fs";
import { mkdir as fsMkdir, readdir as fsReaddir, readFile as fsReadFile, rm as fsRm, writeFile as fsWriteFile } from "node:fs/promises";
import { dirname as pathDirname, join as pathJoin } from "node:path";
import { fileURLToPath } from "node:url";
import ncc from "@vercel/ncc";
const root = pathDirname(fileURLToPath(import.meta.url));
const packageFileName = "package.json";
const scriptEntryPointFileName = "main.js";
const inputDirectoryPath = pathJoin(root, "temp");
const inputFilePath = pathJoin(inputDirectoryPath, scriptEntryPointFileName);
const outputDirectoryPath = pathJoin(root, "hugoalh.GitHubActionsToolkit", "nodejs-wrapper");
const outputFilePath = pathJoin(outputDirectoryPath, scriptEntryPointFileName);
async function getDirectoryItem(directoryPath, relativeBasePath) {
	if (typeof relativeBasePath === "undefined") {
		relativeBasePath = directoryPath;
	}
	try {
		let result = [];
		for (let item of await fsReaddir(directoryPath, { withFileTypes: true })) {
			if (item.isDirectory()) {
				result.push(...await getDirectoryItem(pathJoin(directoryPath, item.name), relativeBasePath));
			} else {
				result.push(pathJoin(directoryPath, item.name).slice(relativeBasePath.length + 1).replace(/\\/gu, "/"));
			}
		}
		return result;
	} catch (error) {
		return [];
	}
}

/* Clean up or initialize output directory (need to await in order to prevent race conditions). */
if (fsExistsSync(outputDirectoryPath)) {
	for (let fileName of await getDirectoryItem(outputDirectoryPath)) {
		await fsRm(pathJoin(outputDirectoryPath, fileName), { recursive: true });
	}
} else {
	await fsMkdir(outputDirectoryPath, { recursive: true });
}

/* Create bundle. */
console.log(execSync(`"${pathJoin(root, "node_modules", ".bin", process.platform === "win32" ? "tsc.cmd" : "tsc")}" -p "${pathJoin(root, "tsconfig.json")}"`).toString("utf8"));
let { code } = await ncc(inputFilePath, {
	assetBuilds: false,
	cache: false,
	debugLog: false,
	license: "",
	minify: true,
	quiet: false,
	sourceMap: false,
	sourceMapRegister: false,
	target: "es2020",
	v8cache: false,
	watch: false
});
await fsWriteFile(outputFilePath, code, { encoding: "utf8" });
let packageMeta = JSON.parse(await fsReadFile(pathJoin(root, packageFileName), { encoding: "utf8" }));
delete packageMeta.scripts;
delete packageMeta.dependencies;
delete packageMeta.devDependencies;
await fsWriteFile(pathJoin(outputDirectoryPath, packageFileName), `${JSON.stringify(packageMeta, undefined, "\t")}\n`, { encoding: "utf8" });
