import fs from "node:fs";
import ghactionsArtifact from "@actions/artifact";
import ghactionsCache from "@actions/cache";
import ghactionsCore from "@actions/core";
import ghactionsToolCache from "@actions/tool-cache";
const exchangeFilePath: string = process.argv[2];
const input = JSON.parse(fs.readFileSync(exchangeFilePath, { encoding: "utf-8" }));
function exchangeFileWrite(data: Record<string, unknown>): void {
	return fs.writeFileSync(exchangeFilePath, JSON.stringify(data), { encoding: "utf8" });
}
function resolveFail(reason: string | Error | RangeError | ReferenceError | SyntaxError | TypeError): void {
	const output: Record<string, unknown> = {
		isSuccess: false
	};
	if (typeof reason === "string") {
		output.reason = reason;
	} else {
		let message = `${reason.name}: ${reason.message}`;
		if (typeof reason.stack !== "undefined") {
			message += `\n${reason.stack}`;
		}
		output.reason = message;
	}
	return exchangeFileWrite(output);
}
function resolveSuccess(result: unknown): void {
	return exchangeFileWrite({
		isSuccess: true,
		result
	});
}
(async () => {
	switch (input.$name) {
		case "debug/fail":
			ghactionsCore.debug(input?.message ?? "");
			resolveFail("This is a fail.");
			break;
		case "debug/success":
			ghactionsCore.debug(input?.message ?? "");
			resolveSuccess("This is a success");
			break;
		case "artifact/download":
			try {
				const result = await ghactionsArtifact.downloadArtifact(input.id, {
					findBy: input.findBy,
					path: input.path
				});
				resolveSuccess({
					path: result.downloadPath
				});
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "artifact/get":
			try {
				const result = await ghactionsArtifact.getArtifact(input.name, { findBy: input.findBy });
				resolveSuccess(result.artifact);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "artifact/list":
			try {
				const result = await ghactionsArtifact.listArtifacts({
					findBy: input.findBy,
					latest: input.latest
				});
				resolveSuccess(result.artifacts);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "artifact/upload":
			try {
				const result = await ghactionsArtifact.uploadArtifact(input.name, input.items, input.rootDirectory, {
					compressionLevel: input.compressionLevel,
					retentionDays: input.retentionDays
				});
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "cache/restore":
			try {
				const result: string | undefined = await ghactionsCache.restoreCache(input.paths, input.primaryKey, input.restoreKeys, {
					concurrentBlobDownloads: input.concurrencyBlobDownload,
					downloadConcurrency: input.downloadConcurrency,
					lookupOnly: input.lookup,
					segmentTimeoutInMs: input.segmentTimeout,
					timeoutInMs: input.timeout,
					useAzureSdk: input.useAzureSdk
				});
				resolveSuccess(result ?? null);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "cache/save":
			try {
				const result: number = await ghactionsCache.saveCache(input.paths, input.key, {
					uploadChunkSize: input.uploadChunkSize,
					uploadConcurrency: input.uploadConcurrency
				});
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "open-id-connect/get-token":
			try {
				const result: string = await ghactionsCore.getIDToken(input.audience);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/cache-directory":
			try {
				const result: string = await ghactionsToolCache.cacheDir(input.source, input.name, input.version, input.architecture);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/cache-file":
			try {
				const result: string = await ghactionsToolCache.cacheFile(input.source, input.target, input.name, input.version, input.architecture);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/download-tool":
			try {
				const result: string = await ghactionsToolCache.downloadTool(input.url, input.destination, input.authorization, input.headers);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/extract-7z":
			try {
				const result: string = await ghactionsToolCache.extract7z(input.file, input.destination, input["7zrPath"]);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/extract-tar":
			try {
				const result: string = await ghactionsToolCache.extractTar(input.file, input.destination, input.flags);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/extract-xar":
			try {
				const result: string = await ghactionsToolCache.extractXar(input.file, input.destination, input.flags);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/extract-zip":
			try {
				const result: string = await ghactionsToolCache.extractZip(input.file, input.destination);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/find":
			try {
				const result: string = ghactionsToolCache.find(input.name, input.version, input.architecture);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		case "tool-cache/find-all-versions":
			try {
				const result: string[] = ghactionsToolCache.findAllVersions(input.name, input.architecture);
				resolveSuccess(result);
			} catch (error) {
				resolveFail(error);
			}
			break;
		default:
			resolveFail(`\`${input.wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
			break;
	}
})();
