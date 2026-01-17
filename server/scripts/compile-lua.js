#!/usr/bin/env node
/**
 * Lua to JavaScript Compiler CLI
 * Usage: node compile-lua.js <input.lua> [output.js]
 * If no output specified, prints to stdout
 */

const fs = require('fs');
const path = require('path');
const LuaInterpreter = require('./lua-interpreter');

const args = process.argv.slice(2);

if (args.length === 0) {
    console.error('Usage: node compile-lua.js <input.lua> [output.js]');
    process.exit(1);
}

const inputFile = args[0];
const outputFile = args[1];

// Check if input file exists
if (!fs.existsSync(inputFile)) {
    console.error(`Error: File not found: ${inputFile}`);
    process.exit(1);
}

// Read Lua code
const luaCode = fs.readFileSync(inputFile, 'utf8');

// Compile
const interpreter = new LuaInterpreter();
const result = interpreter.transpile(luaCode);

if (!result.success) {
    console.error('Compilation failed:');
    result.errors.forEach(err => console.error(`  - ${err}`));
    process.exit(1);
}

// Output
if (outputFile) {
    fs.writeFileSync(outputFile, result.code, 'utf8');
    console.log(`✓ Compiled: ${inputFile} → ${outputFile}`);
} else {
    console.log(result.code);
}
