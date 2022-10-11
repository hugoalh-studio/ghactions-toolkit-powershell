import { argumentHandle, errorHandle } from "../handle.js";
import { restoreCache as ghactionsCacheRestoreCache } from "@actions/cache";
const {
	delimiter,
	DownloadConcurrency,
	Path,
	PrimaryKey,
	RestoreKey,
	Timeout,
	UseAzureSdk
} = argumentHandle();
const result = await ghactionsCacheRestoreCache(Path, PrimaryKey, RestoreKey, {
	downloadConcurrency: DownloadConcurrency,
	timeoutInMs: Timeout,
	useAzureSdk: UseAzureSdk
}).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ CacheKey: result }));
