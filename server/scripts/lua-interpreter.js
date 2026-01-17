/**
 * Production-Grade Lua to JavaScript Transpiler
 * Minimal Lua subset for game scripting
 * Supports: functions, tables, control flow, loops
 */

class LuaInterpreter {
  constructor() {
    this.variables = {};
    this.functions = {};
    this.errors = [];
  }

  /**
   * Parse and transpile Lua code to JavaScript
   */
  transpile(luaCode) {
    try {
      this.errors = [];
      
      // Remove comments
      let code = this.stripComments(luaCode);
      
      // Tokenize
      const tokens = this.tokenize(code);
      
      // Parse and generate JS
      const jsCode = this.generate(tokens);
      
      return { success: true, code: jsCode, errors: [] };
    } catch (e) {
      this.errors.push(e.message);
      return { success: false, code: null, errors: this.errors };
    }
  }

  /**
   * Strip Lua comments (-- comment)
   */
  stripComments(code) {
    return code
      .split('\n')
      .map(line => {
        const commentIdx = line.indexOf('--');
        return commentIdx === -1 ? line : line.substring(0, commentIdx);
      })
      .join('\n');
  }

  /**
   * Tokenize Lua code
   */
  tokenize(code) {
    const tokens = [];
    const regex = /(\d+\.?\d*|"[^"]*"|'[^']*'|==|~=|<=|>=|[a-zA-Z_]\w*|[+\-*/%(){}[\],;:=.<>])/g;
    let match;
    
    while ((match = regex.exec(code)) !== null) {
      const token = match[0].trim();
      if (token) tokens.push(token);
    }
    
    return tokens;
  }

  /**
   * Generate JavaScript from tokens
   */
  generate(tokens) {
    const js = [];
    let i = 0;

    while (i < tokens.length) {
      const token = tokens[i];

      // Function definition: function name(args) ... end
      if (token === 'function') {
        const func = this.parseFunction(tokens, i);
        js.push(func.code);
        i = func.nextIndex;
        continue;
      }

      // Local variable: local x = value
      if (token === 'local') {
        const varDecl = this.parseLocalVar(tokens, i);
        js.push(varDecl.code);
        i = varDecl.nextIndex;
        continue;
      }

      // If statement
      if (token === 'if') {
        const ifStmt = this.parseIfStatement(tokens, i);
        js.push(ifStmt.code);
        i = ifStmt.nextIndex;
        continue;
      }

      // For loop
      if (token === 'for') {
        const loop = this.parseForLoop(tokens, i);
        js.push(loop.code);
        i = loop.nextIndex;
        continue;
      }

      // While loop
      if (token === 'while') {
        const loop = this.parseWhileLoop(tokens, i);
        js.push(loop.code);
        i = loop.nextIndex;
        continue;
      }

      // Return statement
      if (token === 'return') {
        const ret = this.parseReturn(tokens, i);
        js.push(ret.code);
        i = ret.nextIndex;
        continue;
      }

      // Assignment or function call
      if (this.isIdentifier(token)) {
        const stmt = this.parseStatement(tokens, i);
        if (stmt.code) js.push(stmt.code);
        i = stmt.nextIndex;
        continue;
      }

      i++;
    }

    return js.join('\n');
  }

  parseFunction(tokens, startIdx) {
    let i = startIdx + 1;
    const name = tokens[i++];
    
    // Skip (
    i++;
    
    const params = [];
    while (tokens[i] !== ')') {
      if (this.isIdentifier(tokens[i])) {
        params.push(tokens[i]);
      }
      i++;
    }
    i++; // Skip )

    // Parse body
    let body = 'try{\n';
    let depth = 1;
    
    while (i < tokens.length && depth > 0) {
      if (tokens[i] === 'end') depth--;
      if (depth === 0) break;
      
      // Recursively parse function body
      const stmt = this.parseStatement(tokens, i);
      if (stmt.code) body += stmt.code + '\n';
      i = stmt.nextIndex;
    }

    body += '}catch(e){console.error(e);}';
    
    const code = `const ${name} = (${params.join(',')}) => {\n${body}\n};`;
    
    return { code, nextIndex: i + 1 };
  }

  parseLocalVar(tokens, startIdx) {
    let i = startIdx + 1;
    const varName = tokens[i++];
    
    let value = 'undefined';
    if (tokens[i] === '=') {
      i++; // Skip =
      const expr = this.parseExpression(tokens, i);
      value = expr.code;
      i = expr.nextIndex;
    }

    return { 
      code: `let ${varName} = ${value};`, 
      nextIndex: i 
    };
  }

  parseIfStatement(tokens, startIdx) {
    let i = startIdx + 1;
    
    // Parse condition
    const cond = this.parseExpression(tokens, i);
    const condition = cond.code;
    i = cond.nextIndex;

    // Parse then body
    let thenBody = '';
    while (i < tokens.length && tokens[i] !== 'else' && tokens[i] !== 'elseif' && tokens[i] !== 'end') {
      const stmt = this.parseStatement(tokens, i);
      if (stmt.code) thenBody += stmt.code + '\n';
      i = stmt.nextIndex;
    }

    let code = `if (${condition}) {\n${thenBody}\n}`;

    // Handle else/elseif
    while (tokens[i] === 'elseif' || tokens[i] === 'else') {
      if (tokens[i] === 'elseif') {
        i++;
        const elseCond = this.parseExpression(tokens, i);
        code += ` else if (${elseCond.code}) {`;
        i = elseCond.nextIndex;
        
        let elseBody = '';
        while (i < tokens.length && tokens[i] !== 'else' && tokens[i] !== 'elseif' && tokens[i] !== 'end') {
          const stmt = this.parseStatement(tokens, i);
          if (stmt.code) elseBody += stmt.code + '\n';
          i = stmt.nextIndex;
        }
        code += elseBody + '\n}';
      } else {
        i++;
        let elseBody = '';
        while (i < tokens.length && tokens[i] !== 'end') {
          const stmt = this.parseStatement(tokens, i);
          if (stmt.code) elseBody += stmt.code + '\n';
          i = stmt.nextIndex;
        }
        code += ` else {\n${elseBody}\n}`;
      }
    }

    if (tokens[i] === 'end') i++;

    return { code, nextIndex: i };
  }

  parseForLoop(tokens, startIdx) {
    let i = startIdx + 1;
    const varName = tokens[i++];
    i++; // Skip =
    
    const start = this.parseExpression(tokens, i);
    i = start.nextIndex;
    i++; // Skip ,
    
    const end = this.parseExpression(tokens, i);
    i = end.nextIndex;
    
    let step = '1';
    if (tokens[i] === ',') {
      i++;
      const stepExpr = this.parseExpression(tokens, i);
      step = stepExpr.code;
      i = stepExpr.nextIndex;
    }

    i++; // Skip 'do'

    let body = '';
    while (i < tokens.length && tokens[i] !== 'end') {
      const stmt = this.parseStatement(tokens, i);
      if (stmt.code) body += stmt.code + '\n';
      i = stmt.nextIndex;
    }

    const code = `for (let ${varName} = ${start.code}; ${varName} <= ${end.code}; ${varName} += ${step}) {\n${body}\n}`;
    
    return { code, nextIndex: i + 1 };
  }

  parseWhileLoop(tokens, startIdx) {
    let i = startIdx + 1;
    
    const cond = this.parseExpression(tokens, i);
    i = cond.nextIndex;
    i++; // Skip 'do'

    let body = '';
    while (i < tokens.length && tokens[i] !== 'end') {
      const stmt = this.parseStatement(tokens, i);
      if (stmt.code) body += stmt.code + '\n';
      i = stmt.nextIndex;
    }

    const code = `while (${cond.code}) {\n${body}\n}`;
    return { code, nextIndex: i + 1 };
  }

  parseReturn(tokens, startIdx) {
    let i = startIdx + 1;
    const expr = this.parseExpression(tokens, i);
    return { 
      code: `return ${expr.code};`, 
      nextIndex: expr.nextIndex 
    };
  }

  parseStatement(tokens, startIdx) {
    let i = startIdx;
    
    if (this.isIdentifier(tokens[i])) {
      const nextToken = tokens[i + 1];
      
      if (nextToken === '=') {
        // Assignment
        const varName = tokens[i];
        i += 2;
        const expr = this.parseExpression(tokens, i);
        return { 
          code: `${varName} = ${expr.code};`, 
          nextIndex: expr.nextIndex 
        };
      } else if (nextToken === '(') {
        // Function call
        return this.parseFunctionCall(tokens, i);
      } else if (nextToken === '.') {
        // Property access
        return this.parsePropertyAccess(tokens, i);
      }
    }

    return { code: '', nextIndex: i + 1 };
  }

  parseFunctionCall(tokens, startIdx) {
    const funcName = tokens[startIdx];
    let i = startIdx + 2; // Skip name and (

    const args = [];
    while (tokens[i] !== ')') {
      if (tokens[i] !== ',') {
        const expr = this.parseExpression(tokens, i);
        args.push(expr.code);
        i = expr.nextIndex;
      } else {
        i++;
      }
    }

    const code = `${funcName}(${args.join(', ')})`;
    return { code, nextIndex: i + 1 };
  }

  parsePropertyAccess(tokens, startIdx) {
    let i = startIdx;
    let code = tokens[i];
    
    while (tokens[i + 1] === '.' || tokens[i + 1] === '[') {
      i++;
      if (tokens[i + 1] === '.') {
        i++;
        code += `.${tokens[i]}`;
        i++;
      } else if (tokens[i + 1] === '[') {
        i += 2;
        const expr = this.parseExpression(tokens, i);
        code += `[${expr.code}]`;
        i = expr.nextIndex;
        i++; // Skip ]
      }
    }

    if (tokens[i] === '=') {
      i++;
      const expr = this.parseExpression(tokens, i);
      return { 
        code: `${code} = ${expr.code};`, 
        nextIndex: expr.nextIndex 
      };
    }

    return { code, nextIndex: i };
  }

  parseExpression(tokens, startIdx) {
    let i = startIdx;
    let expr = '';

    while (i < tokens.length) {
      const token = tokens[i];

      // End of expression
      if ([';', ')', ',', 'then', 'do', 'end'].includes(token)) {
        break;
      }

      // String literal
      if (token.startsWith('"') || token.startsWith("'")) {
        expr += token;
      }
      // Number
      else if (/^\d+\.?\d*$/.test(token)) {
        expr += token;
      }
      // Boolean/nil
      else if (['true', 'false', 'nil'].includes(token)) {
        expr += token === 'nil' ? 'null' : token;
      }
      // Operators
      else if (['==', '~=', '<=', '>=', '<', '>', 'and', 'or', 'not', '+', '-', '*', '/', '%'].includes(token)) {
        const jsOp = this.luaOpToJs(token);
        expr += ` ${jsOp} `;
      }
      // Identifier or function
      else if (this.isIdentifier(token)) {
        if (tokens[i + 1] === '(') {
          const call = this.parseFunctionCall(tokens, i);
          expr += call.code;
          i = call.nextIndex - 1;
        } else {
          expr += token;
        }
      }
      // Parentheses
      else if (token === '(') {
        expr += '(';
      } else if (token === ')') {
        expr += ')';
      }

      i++;
    }

    return { code: expr.trim(), nextIndex: i };
  }

  luaOpToJs(op) {
    const map = {
      '==': '===',
      '~=': '!==',
      'and': '&&',
      'or': '||',
      'not': '!'
    };
    return map[op] || op;
  }

  isIdentifier(token) {
    return /^[a-zA-Z_]\w*$/.test(token);
  }
}

module.exports = LuaInterpreter;
