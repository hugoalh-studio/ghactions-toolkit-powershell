import { getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
const [inputs, delimiter] = process.argv.slice(2);
const { Audience } = JSON.parse(inputs);
const result = await ghactionsGetOpenIDConnectToken(Audience)
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(delimiter);
console.log(JSON.stringify({ Token: result }));
