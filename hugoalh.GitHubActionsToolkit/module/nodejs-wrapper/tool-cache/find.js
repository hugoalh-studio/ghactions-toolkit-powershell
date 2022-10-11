import { argumentHandle } from "../handle.js";
import { find as ghactionsToolCacheFind } from "@actions/tool-cache";
const {
	delimiter,
	Architecture,
	Name,
	Version
} = argumentHandle();
const result = ghactionsToolCacheFind(Name, Version, Architecture);
console.log(delimiter);
console.log(JSON.stringify({ Path: result }));
