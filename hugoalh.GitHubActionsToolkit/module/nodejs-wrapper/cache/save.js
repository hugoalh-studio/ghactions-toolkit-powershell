#!/usr/bin/env node
import { saveCache as ghactionsCacheSaveCache } from "@actions/cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsCacheSaveCache(input.Path, input.Key, {
	uploadChunkSize: input.UploadChunkSizes,
	uploadConcurrency: input.UploadConcurrency
}).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({
	CacheId: result
}));
process.exit(0);
