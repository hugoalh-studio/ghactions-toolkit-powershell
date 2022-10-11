import { argumentHandle, errorHandle } from "../handle.js";
import { extractZip as ghactionToolCacheExtractZip } from "@actions/tool-cache";
const {
	delimiter,
	Destination,
	File
} = argumentHandle();
const result = await ghactionToolCacheExtractZip(File, Destination).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
