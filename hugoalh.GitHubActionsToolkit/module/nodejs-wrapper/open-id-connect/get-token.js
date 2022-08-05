#!/usr/bin/env node
import { getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsGetOpenIDConnectToken(input.Audience).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({ Token: result }));
process.exit(0);
