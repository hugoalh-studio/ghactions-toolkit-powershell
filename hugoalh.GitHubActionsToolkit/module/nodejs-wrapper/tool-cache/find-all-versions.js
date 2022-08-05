#!/usr/bin/env node
import { findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = ghactionsToolCacheFindAllVersions(input.Name, input.Architecture);
console.log(process.argv[3]);
console.log(JSON.stringify({ Paths: result }));
process.exit(0);
