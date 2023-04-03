import { existsSync as fsExistsSync } from "node:fs";
import { mkdir as fsMKDir, readdir as fsReadDir, readFile as fsReadFile, rm as fsRemove, writeFile as fsWriteFile } from "node:fs/promises";
import { dirname as pathDirName, join as pathJoin } from "node:path";
import { fileURLToPath } from "node:url";
import ncc from "@vercel/ncc";
const inputDirectoryPath = pathDirName(fileURLToPath(import.meta.url));
const packageFileName = "package.json"
const scriptFileName = "main.js";
const outputDirectoryPath = pathJoin(inputDirectoryPath, "../hugoalh.GitHubActionsToolkit/module/nodejs-wrapper");
async function getDirectoryItem(directoryPath) {
	try {
		return await fsReadDir(directoryPath, { withFileTypes: true });
	} catch {
		return [];
	}
}

/* Clean up or initialize output directory (need to await in order to prevent race conditions). */
if (fsExistsSync(outputDirectoryPath)) {
	for (const outputFile of await getDirectoryItem(outputDirectoryPath)) {
		await fsRemove(pathJoin(outputDirectoryPath, outputFile.name), { recursive: true });
	}
} else {
	await fsMKDir(outputDirectoryPath, { recursive: true });
}

/* Create bundle. */
let { code } = await ncc(pathJoin(inputDirectoryPath, scriptFileName), {
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
await fsWriteFile(pathJoin(outputDirectoryPath, scriptFileName), code, { encoding: "utf8" });
let packageMeta = JSON.parse(await fsReadFile(pathJoin(inputDirectoryPath, packageFileName), { encoding: "utf8" }));
delete packageMeta.scripts;
delete packageMeta.dependencies;
delete packageMeta.devDependencies;
await fsWriteFile(pathJoin(outputDirectoryPath, packageFileName), `${JSON.stringify(packageMeta, undefined, "\t")}\n`, { encoding: "utf8" });
