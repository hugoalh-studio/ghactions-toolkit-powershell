import { argumentHandle, errorHandle } from "../handle.js";
import { extractXar as ghactionToolCacheExtractXar } from "@actions/tool-cache";
const {
	delimiter,
	Destination,
	File,
	Flag
} = argumentHandle();
const result = await ghactionToolCacheExtractXar(File, Destination, Flag).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
