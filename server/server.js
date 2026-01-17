// --- SuperMaze Server v2.1 (Map Loading Fixed) ---
const express = require("express");
const fs = require("fs");
const path = require("path");
const WebSocket = require("ws");
const yaml = require("js-yaml");
const mysql = require("mysql2/promise");
const cookieParser = require("cookie-parser");
const { v4: uuidv4 } = require("uuid");
const ScriptManager = require("./scripts/script-manager");
const LuaInterpreter = require("./scripts/lua-interpreter");
const { AuthManager, authMiddleware } = require("./middleware/auth");

const app = express();
const PORT = 3000;
const scriptManager = new ScriptManager(path.join(__dirname, 'scripts'));
const luaInterpreter = new LuaInterpreter();

// --- 1. System Initialization ---
const DIRS = ['data', 'scripts', 'public', 'public/worlds', 'middleware'];
DIRS.forEach(dir => { if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true }); });

// Load config
const CONFIG_PATH = path.join(__dirname, 'config.yml');
const DEFAULT_CONFIG = `
server:
  name: "SuperMaze Official"
  port: 3000
  max_players: 50

auth:
  admin_password: "changethis"
  token_expiry_ms: 3600000

scripting:
  enabled: true
  engine: "lua"
  max_script_size: 100000
  execution_timeout: 5000

database:
  type: "json"
  mysql:
    host: "localhost"
    user: "root"
    password: ""
    database: "supermaze"
`;

if (!fs.existsSync(CONFIG_PATH)) fs.writeFileSync(CONFIG_PATH, DEFAULT_CONFIG);
const config = yaml.load(fs.readFileSync(CONFIG_PATH, 'utf8'));
const authManager = new AuthManager(config.auth || {});

// Create default hub.json if it doesn't exist
const HUB_PATH = path.join(__dirname, 'public/worlds/hub.json');
if (!fs.existsSync(HUB_PATH)) {
    const defaultHub = {
        size: 15,
        grid: Array(15).fill().map(() => Array(15).fill(0))
    };
    defaultHub.grid[5][5] = 1; 
    defaultHub.grid[5][6] = 1;
    defaultHub.grid[5][7] = 1;
    fs.writeFileSync(HUB_PATH, JSON.stringify(defaultHub));
    console.log("✅ Created default public/worlds/hub.json");
}

// --- 2. Data Layer ---
const PLAYERS_FILE = path.join(__dirname, 'data/alltime.json');
if (!fs.existsSync(PLAYERS_FILE)) fs.writeFileSync(PLAYERS_FILE, '[]');

let dbPool = null;
if (config.database.use_mysql) {
    dbPool = mysql.createPool({
        host: config.database.host,
        user: config.database.user,
        password: config.database.password,
        database: config.database.db_name
    });
}

function getLocalPlayers() { return JSON.parse(fs.readFileSync(PLAYERS_FILE)); }
function saveLocalPlayers(data) { fs.writeFileSync(PLAYERS_FILE, JSON.stringify(data, null, 2)); }

// --- 3. Express Routes ---
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
app.use(cookieParser());

app.post("/api/auth", (req, res) => {
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Username required" });

    let players = getLocalPlayers();
    let user = players.find(p => p.username === username);

    if (user) {
        res.cookie("sm_token", user.token, { httpOnly: true });
        return res.json({ success: true, token: user.token });
    } else {
        const token = uuidv4();
        players.push({ username, token, joined: new Date(), banned: false });
        saveLocalPlayers(players);
        res.cookie("sm_token", token, { httpOnly: true });
        res.json({ success: true, token });
    }
});

// Save World (Requires Editor Auth)
app.post("/api/worlds", (req, res) => {
    const { name, data, editorToken } = req.body;
    
    // Check if editor auth token is valid
    if (!editorToken || editorToken !== "editor_authed") {
        return res.status(401).json({ success: false, error: "Unauthorized" });
    }
    
    // data should be { size: 15, grid: [[...]] }
    fs.writeFileSync(path.join(__dirname, `public/worlds/${name}.json`), JSON.stringify(data));
    res.json({ success: true });
});

// GUI API
const GUIS_DIR = path.join(__dirname, 'data/guis');
if (!fs.existsSync(GUIS_DIR)) fs.mkdirSync(GUIS_DIR, { recursive: true });

app.post("/api/gui", (req, res) => {
    const { name, components, html, functions, triggers } = req.body;
    if(!name) return res.status(400).json({ error: "Name required" });
    
    const guiData = { name, components, html, functions, triggers };
    fs.writeFileSync(path.join(GUIS_DIR, `${name}.json`), JSON.stringify(guiData, null, 2));
    res.json({ success: true });
});

app.get("/api/gui", (req, res) => {
    const files = fs.readdirSync(GUIS_DIR);
    const guiNames = files.filter(f => f.endsWith('.json')).map(f => f.replace('.json', ''));
    res.json(guiNames);
});

app.get("/api/gui/:name", (req, res) => {
    const filePath = path.join(GUIS_DIR, `${req.params.name}.json`);
    if(!fs.existsSync(filePath)) return res.status(404).json({ error: "GUI not found" });
    
    const gui = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    res.json(gui);
});

app.delete("/api/gui/:name", (req, res) => {
    const filePath = path.join(GUIS_DIR, `${req.params.name}.json`);
    if(!fs.existsSync(filePath)) return res.status(404).json({ error: "GUI not found" });
    
    fs.unlinkSync(filePath);
    res.json({ success: true });
});

app.get("/api/worlds", (req, res) => {
    fs.readdir(path.join(__dirname, 'public/worlds'), (err, files) => {
        if(err) return res.json([]);
        res.json(files.filter(f => f.endsWith('.json')).map(f => f.replace('.json', '')));
    });
});

// --- Script Management API ---
app.post("/api/scripts", (req, res) => {
    const { name, script } = req.body;
    if (!name || !script) {
        return res.status(400).json({ error: "name and script required" });
    }
    const result = scriptManager.saveScript(name, script);
    res.json(result);
});

app.get("/api/scripts", (req, res) => {
    const scripts = scriptManager.listScripts();
    res.json(scripts);
});

app.get("/api/scripts/:name", (req, res) => {
    const script = scriptManager.loadScript(req.params.name);
    if (!script) {
        return res.status(404).json({ error: "Script not found" });
    }
    res.json(script);
});

app.delete("/api/scripts/:name", (req, res) => {
    const result = scriptManager.deleteScript(req.params.name);
    res.json(result);
});

// --- Authentication API (Map Editor) ---
app.post("/api/editor/auth", (req, res) => {
    const { password } = req.body;
    if (!password) {
        return res.status(400).json({ error: "Password required" });
    }

    const editorPassword = config.auth?.admin_password || "changethis";
    if (password !== editorPassword) {
        return res.status(401).json({ success: false, error: "Invalid password" });
    }
    
    res.json({ success: true });
});

// --- Authentication API (Maze Game) ---
app.post("/api/auth/maze", (req, res) => {
    const { password } = req.body;
    if (!password) {
        return res.status(400).json({ error: "Password required" });
    }

    const mazePassword = config.auth?.maze_password || "changethis";
    const hashedInput = authManager.hashPassword(password);
    const hashedStored = authManager.hashPassword(mazePassword);

    if (hashedInput !== hashedStored) {
        return res.status(401).json({ success: false, error: "Invalid password" });
    }

    const token = authManager.generateToken();
    const expiresAt = Date.now() + (config.auth?.token_expiry_ms || 3600000);
    authManager.sessions.set(token, {
        createdAt: Date.now(),
        expiresAt,
        lastActivity: Date.now()
    });

    res.json({ 
        success: true, 
        token,
        expiresAt
    });
});

app.post("/api/auth/logout", (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (token) {
        authManager.revokeToken(token);
    }
    res.json({ success: true });
});

// --- Lua Scripting API ---
app.post("/api/lua/execute", authMiddleware(authManager), (req, res) => {
    const { code } = req.body;
    
    if (!code) {
        return res.status(400).json({ error: "No code provided" });
    }

    if (code.length > (config.scripting?.max_script_size || 100000)) {
        return res.status(400).json({ error: "Script too large" });
    }

    try {
        // Transpile Lua to JavaScript
        const transpilation = luaInterpreter.transpile(code);
        
        if (!transpilation.success) {
            return res.json({ 
                success: false, 
                error: "Transpilation failed",
                errors: transpilation.errors 
            });
        }

        // Execute with timeout
        const timeout = config.scripting?.execution_timeout || 5000;
        const output = [];
        const originalLog = console.log;
        
        // Capture console output
        console.log = (...args) => {
            output.push(args.map(a => String(a)).join(' '));
        };

        const timeoutPromise = new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Execution timeout')), timeout)
        );

        const executionPromise = new Promise((resolve) => {
            try {
                eval(transpilation.code);
                resolve();
            } catch (e) {
                output.push('Error: ' + e.message);
                resolve();
            }
        });

        Promise.race([executionPromise, timeoutPromise])
            .catch(e => output.push('Error: ' + e.message))
            .finally(() => {
                console.log = originalLog;
                res.json({ 
                    success: true, 
                    output 
                });
            });

    } catch (e) {
        res.status(500).json({ 
            success: false, 
            error: e.message 
        });
    }
});

app.post("/api/lua/scripts", authMiddleware(authManager), (req, res) => {
    const { name, code } = req.body;
    
    if (!name || !code) {
        return res.status(400).json({ error: "name and code required" });
    }

    try {
        const filePath = path.join(__dirname, 'scripts', `${name}.lua`);
        fs.writeFileSync(filePath, code);
        res.json({ success: true, message: `Script ${name} saved` });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.get("/api/lua/scripts", authMiddleware(authManager), (req, res) => {
    try {
        const scriptsDir = path.join(__dirname, 'scripts');
        const files = fs.readdirSync(scriptsDir);
        const luaFiles = files
            .filter(f => f.endsWith('.lua'))
            .map(f => f.replace('.lua', ''));
        res.json(luaFiles);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.get("/api/lua/scripts/:name", authMiddleware(authManager), (req, res) => {
    try {
        const filePath = path.join(__dirname, 'scripts', `${req.params.name}.lua`);
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: "Script not found" });
        }
        const code = fs.readFileSync(filePath, 'utf8');
        res.json({ code });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.delete("/api/lua/scripts/:name", authMiddleware(authManager), (req, res) => {
    try {
        const filePath = path.join(__dirname, 'scripts', `${req.params.name}.lua`);
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: "Script not found" });
        }
        fs.unlinkSync(filePath);
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

const server = app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📝 Lua Editor: http://localhost:${PORT}/editor.html`);
});

// --- 4. WebSocket ---
const wss = new WebSocket.Server({ server });
const worlds = { "hub": {} };

wss.on("connection", (ws) => {
    const id = uuidv4();
    let currentWorld = "hub";
    let username = "Guest";

    // Helper to load and send map data
    const sendMapData = (worldName) => {
        const filePath = path.join(__dirname, `public/worlds/${worldName}.json`);
        if (fs.existsSync(filePath)) {
            try {
                const mapData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                ws.send(JSON.stringify({ 
                    type: "map_data", 
                    world: worldName, 
                    data: mapData 
                }));
            } catch (e) {
                console.error("Error reading map:", e);
            }
        } else {
            // If world doesn't exist, send empty default
            ws.send(JSON.stringify({ 
                type: "map_data", 
                world: worldName, 
                data: { size: 15, grid: Array(15).fill().map(()=>Array(15).fill(0)) } 
            }));
        }
    };

    const broadcastWorld = () => {
        if (!worlds[currentWorld]) return;
        const payload = JSON.stringify({
            type: "world_update",
            world: currentWorld,
            players: worlds[currentWorld]
        });
        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) client.send(payload);
        });
    };

    ws.on("message", (msg) => {
        try {
            const data = JSON.parse(msg);

            if (data.type === "join") {
                username = data.username;
                if (!worlds[currentWorld]) worlds[currentWorld] = {};
                worlds[currentWorld][id] = { username, x: 1, y: 1 };
                
                // 1. Send the Map Data for the Hub
                sendMapData('hub');
                // 2. Broadcast presence
                broadcastWorld();
            }

            if (data.type === "move") {
                if (worlds[currentWorld] && worlds[currentWorld][id]) {
                    worlds[currentWorld][id].x = data.x;
                    worlds[currentWorld][id].y = data.y;
                    broadcastWorld();
                }
            }

            if (data.type === "teleport") {
                // Remove from old
                if (worlds[currentWorld][id]) delete worlds[currentWorld][id];
                broadcastWorld(); // Notify old world

                // Switch
                currentWorld = data.toWorld;
                if (!worlds[currentWorld]) worlds[currentWorld] = {};
                worlds[currentWorld][id] = { username, x: 1, y: 1 };

                // Send new map data
                sendMapData(currentWorld);
                broadcastWorld(); // Notify new world
            }

        } catch (e) {}
    });

    ws.on("close", () => {
        if (worlds[currentWorld] && worlds[currentWorld][id]) {
            delete worlds[currentWorld][id];
            broadcastWorld();
        }
    });
});
