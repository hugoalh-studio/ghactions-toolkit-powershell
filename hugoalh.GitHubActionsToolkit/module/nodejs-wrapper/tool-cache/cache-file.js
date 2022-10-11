import { argumentHandle, errorHandle } from "../handle.js";
import { cacheFile as ghactionsToolCacheCacheFile } from "@actions/tool-cache";
const {
	delimiter,
	Architecture,
	Name,
	Source,
	Target,
	Version
} = argumentHandle()
const result = await ghactionsToolCacheCacheFile(Source, Target, Name, Version, Architecture).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
