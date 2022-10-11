import { argumentHandle, errorHandle } from "../handle.js";
import { getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
const {
	delimiter,
	Audience
} = argumentHandle();
const result = await ghactionsGetOpenIDConnectToken(Audience).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({ Token: result }));
