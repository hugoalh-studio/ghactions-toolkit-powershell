import { argumentHandle, errorHandle } from "../handle.js";
import { extractTar as ghactionToolCacheExtractTar } from "@actions/tool-cache";
const {
	delimiter,
	Destination,
	File,
	Flag
} = argumentHandle();
const result = await ghactionToolCacheExtractTar(File, Destination, Flag).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
