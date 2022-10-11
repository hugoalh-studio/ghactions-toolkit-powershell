import { argumentHandle, errorHandle } from "../handle.js";
import { extract7z as ghactionToolCacheExtract7z } from "@actions/tool-cache";
const {
	delimiter,
	Destination,
	File,
	...inputRemain
} = argumentHandle();
const result = await ghactionToolCacheExtract7z(File, Destination, inputRemain["7zrPath"]).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
