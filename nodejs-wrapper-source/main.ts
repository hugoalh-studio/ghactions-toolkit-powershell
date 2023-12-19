import { constants as fsConstants } from "node:fs";
import { open as fsOpen, type FileHandle } from "node:fs/promises";
import { DefaultArtifactClient as GitHubActionsArtifactClient, type ListArtifactsResponse as GitHubActionsArtifactListResponse, type DownloadArtifactResponse as GitHubActionsArtifactDownloadResponse, type UploadArtifactResponse as GitHubActionsArtifactUploadResponse, type GetArtifactResponse as GitHubActionsArtifactGetResponse } from "@actions/artifact";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
import { debug as ghactionsDebug, getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionsToolCacheDownloadTool, extract7z as ghactionsToolCacheExtract7z, extractTar as ghactionsToolCacheExtractTar, extractXar as ghactionsToolCacheExtractXar, extractZip as ghactionsToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
const exchangeFileHandle: FileHandle = await fsOpen(process.argv[2], fsConstants.O_RDWR | fsConstants.O_NOFOLLOW);
const input = JSON.parse(await exchangeFileHandle.readFile({ encoding: "utf8" }));
async function exchangeFileWrite(data: Record<string, unknown>): Promise<void> {
	await exchangeFileHandle.truncate(0);
	return exchangeFileHandle.writeFile(JSON.stringify(data), { encoding: "utf8" });
}
function resolveFail(reason: string | Error | RangeError | ReferenceError | SyntaxError | TypeError): Promise<void> {
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
function resolveSuccess(result: unknown): Promise<void> {
	return exchangeFileWrite({
		isSuccess: true,
		result
	});
}
switch (input.$name) {
	case "debug/fail":
		ghactionsDebug(input?.message ?? "");
		await resolveFail("This is a fail.");
		break;
	case "debug/success":
		ghactionsDebug(input?.message ?? "");
		await resolveSuccess("This is a success");
		break;
	case "artifact/download":
		try {
			const result: GitHubActionsArtifactDownloadResponse = await new GitHubActionsArtifactClient().downloadArtifact(input.id, {
				findBy: input.findBy,
				path: input.path
			});
			await resolveSuccess({
				path: result.downloadPath
			});
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "artifact/get":
		try {
			const result: GitHubActionsArtifactGetResponse = await new GitHubActionsArtifactClient().getArtifact(input.name, { findBy: input.findBy });
			await resolveSuccess(result.artifact);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "artifact/list":
		try {
			const result: GitHubActionsArtifactListResponse = await new GitHubActionsArtifactClient().listArtifacts({
				findBy: input.findBy,
				latest: true
			});
			await resolveSuccess(result.artifacts);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "artifact/upload":
		try {
			const result: GitHubActionsArtifactUploadResponse = await new GitHubActionsArtifactClient().uploadArtifact(input.name, input.items, input.rootDirectory, {
				compressionLevel: input.compressionLevel,
				retentionDays: input.retentionDays
			});
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "cache/restore":
		try {
			const result: string | undefined = await ghactionsCacheRestoreCache(input.paths, input.primaryKey, input.restoreKeys, {
				concurrentBlobDownloads: input.concurrencyBlobDownload,
				downloadConcurrency: input.downloadConcurrency,
				lookupOnly: input.lookup,
				segmentTimeoutInMs: input.segmentTimeout,
				timeoutInMs: input.timeout,
				useAzureSdk: input.useAzureSdk
			});
			await resolveSuccess(result ?? null);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "cache/save":
		try {
			const result: number = await ghactionsCacheSaveCache(input.paths, input.key, {
				uploadChunkSize: input.uploadChunkSize,
				uploadConcurrency: input.uploadConcurrency
			});
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "open-id-connect/get-token":
		try {
			const result: string = await ghactionsGetOpenIDConnectToken(input.audience);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/cache-directory":
		try {
			const result: string = await ghactionsToolCacheCacheDirectory(input.source, input.name, input.version, input.architecture);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/cache-file":
		try {
			const result: string = await ghactionsToolCacheCacheFile(input.source, input.target, input.name, input.version, input.architecture);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/download-tool":
		try {
			const result: string = await ghactionsToolCacheDownloadTool(input.url, input.destination, input.authorization, input.headers);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/extract-7z":
		try {
			const result: string = await ghactionsToolCacheExtract7z(input.file, input.destination, input["7zrPath"]);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/extract-tar":
		try {
			const result: string = await ghactionsToolCacheExtractTar(input.file, input.destination, input.flags);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/extract-xar":
		try {
			const result: string = await ghactionsToolCacheExtractXar(input.file, input.destination, input.flags);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/extract-zip":
		try {
			const result: string = await ghactionsToolCacheExtractZip(input.file, input.destination);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/find":
		try {
			const result: string = ghactionsToolCacheFind(input.name, input.version, input.architecture);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	case "tool-cache/find-all-versions":
		try {
			const result: string[] = ghactionsToolCacheFindAllVersions(input.name, input.architecture);
			await resolveSuccess(result);
		} catch (error) {
			await resolveFail(error);
		}
		break;
	default:
		await resolveFail(`\`${input.wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
		break;
}
await exchangeFileHandle.close();
