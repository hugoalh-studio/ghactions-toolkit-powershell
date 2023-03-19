import { copyFile as fsCopyFile, readFile as fsReadFile, writeFile as fsWriteFile } from "node:fs/promises";
import { dirname as pathDirName, join as pathJoin } from "node:path";
import { existsSync as fsExistsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import ncc from "@vercel/ncc";
const packageFileName = "package.json"
const packageLockFileName = "pnpm-lock.yaml";
const inputDirectoryPath = pathDirName(fileURLToPath(import.meta.url));
const inputScriptFileName = "main.js";
const outputDirectoryPath = pathJoin(inputDirectoryPath, "../hugoalh.GitHubActionsToolkit/module/nodejs-wrapper");
const outputBundledFileName = "bundled.js";
const outputUnbundledFileName = "unbundled.js";
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
let { code } = await ncc(pathJoin(inputDirectoryPath, inputScriptFileName), {
	assetBuilds: false,
	cache: false,
	debugLog: false,
	license: "",
	minify: true,
	quiet: false,
	sourceMap: false,
	sourceMapRegister: false,
	target: "es2022",
	v8cache: false,
	watch: false
});
await fsWriteFile(pathJoin(outputDirectoryPath, outputBundledFileName), code, { encoding: "utf8" });
await fsCopyFile(pathJoin(inputDirectoryPath, inputScriptFileName), pathJoin(outputDirectoryPath, outputUnbundledFileName))
await fsCopyFile(pathJoin(inputDirectoryPath, packageLockFileName), pathJoin(outputDirectoryPath, packageLockFileName))
let packageMeta = JSON.parse(await fsReadFile(pathJoin(inputDirectoryPath, packageFileName), { encoding: "utf8" }));
delete packageMeta.scripts;
delete packageMeta.devDependencies;
packageMeta.name = `${packageMeta.name}-distribution`;
await fsWriteFile(pathJoin(outputDirectoryPath, packageFileName), `${JSON.stringify(packageMeta, undefined, "\t")}\n`, { encoding: "utf8" });
