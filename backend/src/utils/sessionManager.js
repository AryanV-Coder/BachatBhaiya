// src/utils/sessionManager.js
const { v4: uuidv4 } = require("uuid");

/**
 * In-memory session storage
 * Structure:
 * {
 *   sessionId: {
 *     spamMessage: string,
 *     conversationHistory: Array,
 *     startTime: timestamp,
 *     isEvaluated: boolean
 *   }
 * }
 */
const sessions = {};

/**
 * Create a new session with a spam message
 * @param {string} spamMessage - The spam message for this session
 * @returns {string} sessionId
 */
const createSession = (spamMessage) => {
  const sessionId = uuidv4();

  sessions[sessionId] = {
    spamMessage,
    conversationHistory: [],
    startTime: Date.now(),
    isEvaluated: false,
  };

  return sessionId;
};

/**
 * Get session data
 * @param {string} sessionId - The session ID
 * @returns {Object|null} Session data or null if not found
 */
const getSession = (sessionId) => {
  return sessions[sessionId] || null;
};

/**
 * Add message to conversation history
 * @param {string} sessionId - The session ID
 * @param {string} role - "user" or "assistant"
 * @param {string} content - Message content
 * @returns {boolean} Success status
 */
const addMessage = (sessionId, role, content) => {
  if (!sessions[sessionId]) {
    return false;
  }

  sessions[sessionId].conversationHistory.push({
    role,
    content,
    timestamp: Date.now(),
  });

  return true;
};

/**
 * Mark session as evaluated
 * @param {string} sessionId - The session ID
 * @returns {boolean} Success status
 */
const markEvaluated = (sessionId) => {
  if (!sessions[sessionId]) {
    return false;
  }

  sessions[sessionId].isEvaluated = true;
  return true;
};

/**
 * Get spam message for a session
 * @param {string} sessionId - The session ID
 * @returns {string|null} Spam message or null if not found
 */
const getSpamMessage = (sessionId) => {
  const session = sessions[sessionId];
  return session ? session.spamMessage : null;
};

/**
 * Check if session is already evaluated
 * @param {string} sessionId - The session ID
 * @returns {boolean} Evaluation status
 */
const isEvaluated = (sessionId) => {
  const session = sessions[sessionId];
  return session ? session.isEvaluated : false;
};

/**
 * Clean up old sessions (optional - for memory management)
 * Remove sessions older than 24 hours
 */
const cleanupOldSessions = () => {
  const TWENTY_FOUR_HOURS = 24 * 60 * 60 * 1000;
  const now = Date.now();

  Object.keys(sessions).forEach((sessionId) => {
    if (now - sessions[sessionId].startTime > TWENTY_FOUR_HOURS) {
      delete sessions[sessionId];
    }
  });
};

// Optional: Run cleanup every hour
setInterval(cleanupOldSessions, 60 * 60 * 1000);

module.exports = {
  createSession,
  getSession,
  addMessage,
  markEvaluated,
  getSpamMessage,
  isEvaluated,
  cleanupOldSessions,
};
