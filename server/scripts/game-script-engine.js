/**
 * GameScript Engine for SuperMaze
 * Allows dynamic scripting of game events, behaviors, and custom logic
 */

class GameScriptEngine {
  constructor() {
    this.scripts = new Map();
    this.events = new Map();
    this.hooks = new Map();
    this.variables = new Map();
  }

  /**
   * Register an event handler
   * @param {string} eventName - Event to listen for (e.g., 'player.move', 'maze.complete', 'collision')
   * @param {Function} callback - Handler function
   */
  on(eventName, callback) {
    if (!this.events.has(eventName)) {
      this.events.set(eventName, []);
    }
    this.events.get(eventName).push(callback);
  }

  /**
   * Emit an event with data
   * @param {string} eventName - Event name
   * @param {Object} data - Event data
   */
  emit(eventName, data = {}) {
    if (this.events.has(eventName)) {
      this.events.get(eventName).forEach(callback => {
        try {
          callback(data);
        } catch (e) {
          console.error(`Error in event handler for ${eventName}:`, e);
        }
      });
    }
  }

  /**
   * Define a hook (before/after interceptor)
   * @param {string} hookName - Hook name (e.g., 'beforeMove', 'afterVictory')
   * @param {Function} fn - Hook function
   */
  hook(hookName, fn) {
    if (!this.hooks.has(hookName)) {
      this.hooks.set(hookName, []);
    }
    this.hooks.get(hookName).push(fn);
  }

  /**
   * Execute a hook chain and get modified data
   * @param {string} hookName - Hook name
   * @param {Object} data - Initial data
   * @returns {Object} Modified data
   */
  async executeHook(hookName, data = {}) {
    if (!this.hooks.has(hookName)) return data;
    
    let result = data;
    for (const fn of this.hooks.get(hookName)) {
      try {
        result = await fn(result);
      } catch (e) {
        console.error(`Error in hook ${hookName}:`, e);
      }
    }
    return result;
  }

  /**
   * Set and get script variables
   */
  setVariable(name, value) {
    this.variables.set(name, value);
  }

  getVariable(name) {
    return this.variables.get(name);
  }

  /**
   * Load a script from JSON/Object
   * @param {string} name - Script name
   * @param {Object} scriptDef - Script definition
   */
  loadScript(name, scriptDef) {
    this.scripts.set(name, scriptDef);
  }

  /**
   * Load built-in script templates
   */
  loadBuiltIns() {
    // Teleporter script
    this.loadScript('teleporter', {
      name: 'Teleporter Logic',
      on: {
        'player.collision': function(data) {
          if (data.tile && data.tile.type === 'teleporter') {
            return { action: 'teleport', target: data.tile.target };
          }
        }
      }
    });

    // Speed boost
    this.loadScript('speedboost', {
      name: 'Speed Boost Tile',
      on: {
        'player.collision': function(data) {
          if (data.tile && data.tile.type === 'speedboost') {
            data.moveDelay = Math.max(10, data.moveDelay - 50);
            return { action: 'none', modifiedData: data };
          }
        }
      }
    });

    // Obstacle course
    this.loadScript('obstacles', {
      name: 'Obstacle Spawner',
      on: {
        'maze.start': function() {
          return { action: 'spawnObstacles', count: 5 };
        }
      }
    });
  }
}

module.exports = GameScriptEngine;
