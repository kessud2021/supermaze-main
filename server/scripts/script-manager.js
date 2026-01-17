/**
 * Script Manager
 * Manages loading, saving, and executing game scripts
 */

const fs = require('fs');
const path = require('path');

class ScriptManager {
  constructor(scriptsDir = './scripts') {
    this.scriptsDir = scriptsDir;
    this.loadedScripts = new Map();
    this.ensureScriptsDir();
  }

  ensureScriptsDir() {
    if (!fs.existsSync(this.scriptsDir)) {
      fs.mkdirSync(this.scriptsDir, { recursive: true });
    }
  }

  /**
    * Save a script to file
    * @param {string} name - Script name
    * @param {string} code - Script code
    */
  saveScript(name, code) {
    const filePath = path.join(this.scriptsDir, `${name}.lua`);
    fs.writeFileSync(filePath, code, 'utf8');
    return { success: true, path: filePath };
  }

  /**
    * Load a script from file
    * @param {string} name - Script name
    */
  loadScript(name) {
    const filePath = path.join(this.scriptsDir, `${name}.lua`);
    if (fs.existsSync(filePath)) {
      const code = fs.readFileSync(filePath, 'utf8');
      this.loadedScripts.set(name, code);
      return { code };
    }
    return null;
  }

  /**
    * List all available scripts
    */
  listScripts() {
    const files = fs.readdirSync(this.scriptsDir);
    return files
      .filter(f => f.endsWith('.lua'))
      .map(f => f.replace('.lua', ''));
  }

  /**
    * Delete a script
    */
  deleteScript(name) {
    const filePath = path.join(this.scriptsDir, `${name}.lua`);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      this.loadedScripts.delete(name);
      return { success: true };
    }
    return { success: false, error: 'Script not found' };
  }

  /**
   * Create a new script from template
   */
  createScriptFromTemplate(name, type = 'event') {
    const templates = {
      event: {
        name: name,
        type: 'event',
        triggers: [],
        actions: []
      },
      timer: {
        name: name,
        type: 'timer',
        interval: 1000,
        callback: ''
      },
      condition: {
        name: name,
        type: 'condition',
        checks: [],
        onTrue: [],
        onFalse: []
      }
    };
    return templates[type] || templates.event;
  }
}

module.exports = ScriptManager;
