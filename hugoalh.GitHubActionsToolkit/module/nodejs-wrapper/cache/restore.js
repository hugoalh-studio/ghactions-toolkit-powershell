import { restoreCache as ghactionsCacheRestoreCache } from "@actions/cache";
const [inputs, delimiter] = process.argv.slice(2);
const {
	DownloadConcurrency,
	Path,
	PrimaryKey,
	RestoreKey,
	Timeout,
	UseAzureSdk
} = JSON.parse(inputs);
const result = await ghactionsCacheRestoreCache(Path, PrimaryKey, RestoreKey, {
	downloadConcurrency: DownloadConcurrency,
	timeoutInMs: Timeout,
	useAzureSdk: UseAzureSdk
})
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(delimiter);
console.log(JSON.stringify({ CacheKey: result }));
