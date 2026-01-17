/**
 * Production-Grade Authentication Middleware
 * Token-based auth with session management
 */

const crypto = require('crypto');

class AuthManager {
  constructor(config) {
    this.config = config;
    this.adminPassword = config.admin_password || 'changethis';
    this.sessions = new Map();
    this.tokenExpiry = 3600000; // 1 hour
  }

  /**
   * Generate secure token
   */
  generateToken() {
    return crypto.randomBytes(32).toString('hex');
  }

  /**
   * Hash password
   */
  hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
  }

  /**
   * Authenticate user
   */
  authenticate(password) {
    const hashedInput = this.hashPassword(password);
    const hashedStored = this.hashPassword(this.adminPassword);
    
    if (hashedInput !== hashedStored) {
      return { success: false, error: 'Invalid password' };
    }

    const token = this.generateToken();
    const expiresAt = Date.now() + this.tokenExpiry;
    
    this.sessions.set(token, {
      createdAt: Date.now(),
      expiresAt,
      lastActivity: Date.now()
    });

    return { 
      success: true, 
      token,
      expiresAt 
    };
  }

  /**
   * Verify token
   */
  verifyToken(token) {
    if (!this.sessions.has(token)) {
      return { valid: false, error: 'Invalid token' };
    }

    const session = this.sessions.get(token);
    
    if (Date.now() > session.expiresAt) {
      this.sessions.delete(token);
      return { valid: false, error: 'Token expired' };
    }

    // Update last activity
    session.lastActivity = Date.now();
    return { valid: true };
  }

  /**
   * Revoke token
   */
  revokeToken(token) {
    return this.sessions.delete(token);
  }

  /**
   * Cleanup expired sessions
   */
  cleanupSessions() {
    const now = Date.now();
    for (const [token, session] of this.sessions.entries()) {
      if (now > session.expiresAt) {
        this.sessions.delete(token);
      }
    }
  }
}

/**
 * Express middleware for token verification
 */
function authMiddleware(authManager) {
  return (req, res, next) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const verification = authManager.verifyToken(token);
    if (!verification.valid) {
      return res.status(401).json({ error: verification.error });
    }

    req.authToken = token;
    next();
  };
}

module.exports = { AuthManager, authMiddleware };
