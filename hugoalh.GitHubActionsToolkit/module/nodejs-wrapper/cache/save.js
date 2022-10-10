import { saveCache as ghactionsCacheSaveCache } from "@actions/cache";
const [inputs, delimiter] = process.argv.slice(2);
const {
	Key,
	Path,
	UploadChunkSizes,
	UploadConcurrency
} = JSON.parse(inputs);
const result = await ghactionsCacheSaveCache(Path, Key, {
	uploadChunkSize: UploadChunkSizes,
	uploadConcurrency: UploadConcurrency
})
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(delimiter);
console.log(JSON.stringify({ CacheId: result }));
