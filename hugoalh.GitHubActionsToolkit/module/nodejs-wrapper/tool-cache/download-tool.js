import { argumentHandle, errorHandle } from "../handle.js";
import { downloadTool as ghactionToolCacheDownloadTool } from "@actions/tool-cache";
const {
	delimiter,
	Authorization,
	Destination,
	Header,
	Uri
} = argumentHandle();
const result = await ghactionToolCacheDownloadTool(Uri, Destination, Authorization, Header).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
