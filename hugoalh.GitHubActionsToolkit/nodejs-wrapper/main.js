import { constants as fsConstants } from "node:fs";
import { open as fsOpen } from "node:fs/promises";
import { create as ghactionsArtifact } from "@actions/artifact";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
import { debug as ghactionsDebug, getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionsToolCacheDownloadTool, extract7z as ghactionsToolCacheExtract7z, extractTar as ghactionsToolCacheExtractTar, extractXar as ghactionsToolCacheExtractXar, extractZip as ghactionsToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
const exchangeFileHandle = await fsOpen(process.argv.slice(2)[0], fsConstants.O_RDWR | fsConstants.O_NOFOLLOW);
const input = JSON.parse(await exchangeFileHandle.readFile({ encoding: "utf8" }));
async function exchangeFileWrite(data) {
    await exchangeFileHandle.truncate(0);
    return exchangeFileHandle.writeFile(JSON.stringify(data), { encoding: "utf8" });
}
function resolveError(reason) {
    let output = {
        isSuccess: false
    };
    if (typeof reason === "string") {
        output.reason = reason;
    }
    else {
        let message = `${reason.name}: ${reason.message}`;
        if (typeof reason.stack !== "undefined") {
            message += `\n${reason.stack}`;
        }
        output.reason = message;
    }
    return exchangeFileWrite(output);
}
function resolveResult(result) {
    return exchangeFileWrite({
        isSuccess: true,
        result
    });
}
switch (input.wrapperName) {
    case "$fail":
        ghactionsDebug(input.message);
        await resolveError("Test");
        break;
    case "$success":
        ghactionsDebug(input.message);
        await resolveResult("Hello, world!");
        break;
    case "artifact/download":
        try {
            let result = await ghactionsArtifact().downloadArtifact(input.name, input.destination, { createArtifactFolder: input.createSubfolder });
            await resolveResult({
                name: result.artifactName,
                path: result.downloadPath
            });
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "artifact/download-all":
        try {
            let result = await ghactionsArtifact().downloadAllArtifacts(input.destination);
            await resolveResult(result.map((value) => {
                return {
                    name: value.artifactName,
                    path: value.downloadPath
                };
            }));
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "artifact/upload":
        try {
            let result = await ghactionsArtifact().uploadArtifact(input.name, input.items, input.rootDirectory, {
                continueOnError: input.continueOnError,
                retentionDays: input.retentionDays
            });
            await resolveResult({
                name: result.artifactName,
                items: result.artifactItems,
                size: result.size,
                failedItems: result.failedItems
            });
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "cache/restore":
        try {
            let result = await ghactionsCacheRestoreCache(input.paths, input.primaryKey, input.restoreKeys, {
                downloadConcurrency: input.downloadConcurrency,
                lookupOnly: input.lookup,
                segmentTimeoutInMs: input.segmentTimeout,
                timeoutInMs: input.timeout,
                useAzureSdk: input.useAzureSdk
            });
            await resolveResult(result ?? null);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "cache/save":
        try {
            let result = await ghactionsCacheSaveCache(input.paths, input.key, {
                uploadChunkSize: input.uploadChunkSize,
                uploadConcurrency: input.uploadConcurrency
            });
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "open-id-connect/get-token":
        try {
            let result = await ghactionsGetOpenIDConnectToken(input.audience);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/cache-directory":
        try {
            let result = await ghactionsToolCacheCacheDirectory(input.source, input.name, input.version, input.architecture);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/cache-file":
        try {
            let result = await ghactionsToolCacheCacheFile(input.source, input.target, input.name, input.version, input.architecture);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/download-tool":
        try {
            let result = await ghactionsToolCacheDownloadTool(input.url, input.destination, input.authorization, input.headers);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/extract-7z":
        try {
            let result = await ghactionsToolCacheExtract7z(input.file, input.destination, input["7zrPath"]);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/extract-tar":
        try {
            let result = await ghactionsToolCacheExtractTar(input.file, input.destination, input.flags);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/extract-xar":
        try {
            let result = await ghactionsToolCacheExtractXar(input.file, input.destination, input.flags);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/extract-zip":
        try {
            let result = await ghactionsToolCacheExtractZip(input.file, input.destination);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/find":
        try {
            let result = ghactionsToolCacheFind(input.name, input.version, input.architecture);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    case "tool-cache/find-all-versions":
        try {
            let result = ghactionsToolCacheFindAllVersions(input.name, input.architecture);
            await resolveResult(result);
        }
        catch (error) {
            await resolveError(error);
        }
        break;
    default:
        await resolveError(`\`${input.wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
        break;
}
await exchangeFileHandle.close();
