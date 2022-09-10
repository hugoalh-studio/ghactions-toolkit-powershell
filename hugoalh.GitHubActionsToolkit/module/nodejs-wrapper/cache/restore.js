#!/usr/bin/env node
import { restoreCache as ghactionsCacheRestoreCache } from "@actions/cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsCacheRestoreCache(input.Path, input.PrimaryKey, input.RestoreKey, {
	downloadConcurrency: input.DownloadConcurrency,
	timeoutInMs: input.Timeout,
	useAzureSdk: input.UseAzureSdk
})
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(process.argv[3]);
console.log(JSON.stringify({ CacheKey: result }));
process.exit(0);
