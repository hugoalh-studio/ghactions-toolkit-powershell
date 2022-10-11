import { argumentHandle, errorHandle } from "../handle.js";
import { saveCache as ghactionsCacheSaveCache } from "@actions/cache";
const {
	delimiter,
	Key,
	Path,
	UploadChunkSizes,
	UploadConcurrency
} = argumentHandle();
const result = await ghactionsCacheSaveCache(Path, Key, {
	uploadChunkSize: UploadChunkSizes,
	uploadConcurrency: UploadConcurrency
}).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ CacheId: result }));
