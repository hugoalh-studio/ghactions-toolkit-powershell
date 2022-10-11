import { argumentHandle, errorHandle } from "../handle.js";
import { cacheDir as ghactionsToolCacheCacheDirectory } from "@actions/tool-cache";
const {
	delimiter,
	Architecture,
	Name,
	Source,
	Version
} = argumentHandle();
const result = await ghactionsToolCacheCacheDirectory(Source, Name, Version, Architecture).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
