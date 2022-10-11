import { argumentHandle } from "../handle.js";
import { findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
const {
	delimiter,
	Architecture,
	Name
} = argumentHandle();
const result = ghactionsToolCacheFindAllVersions(Name, Architecture);
console.log(delimiter);
console.log(JSON.stringify({ Paths: result }));
