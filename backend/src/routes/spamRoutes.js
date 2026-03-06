// src/routes/spamRoutes.js
const express = require("express");
const router = express.Router();

const { startSession } = require("../controllers/spamController");
const { chat } = require("../controllers/chatController");
const { evaluate } = require("../controllers/evaluationController");
const { signup, login } = require("../controllers/authController");
const { verifyToken } = require("../utils/authMiddleware");

// ==================== AUTHENTICATION ROUTES ====================

/**
 * POST /auth/signup
 * Create a new user account
 * Body: { user_id: string, password: string, password_confirm: string }
 * Returns: { success, message, token, user }
 */
router.post("/auth/signup", signup);

/**
 * POST /auth/login
 * Login with username and password
 * Body: { user_id: string, password: string }
 * Returns: { success, message, token, user }
 */
router.post("/auth/login", login);

// ==================== PROTECTED ROUTES ====================
// All routes below require valid JWT token in Authorization header

/**
 * POST /start-session
 * Start a new spam detection training session
 * Headers: { Authorization: "Bearer <token>" }
 * Returns: { success, sessionId, userId, message, receivedMessage, instruction }
 */
router.post("/start-session", verifyToken, startSession);

/**
 * POST /chat
 * Send a message to chat with the assistant
 * Headers: { Authorization: "Bearer <token>" }
 * Body: { sessionId: string, userMessage: string }
 * Returns: { success, sessionId, assistantResponse, conversationLength, instruction }
 */
router.post("/chat", verifyToken, chat);

/**
 * POST /evaluate
 * Submit your final answer about whether the message is spam or not
 * Headers: { Authorization: "Bearer <token>" }
 * Body: { sessionId: string, userFinalAnswer: "spam" | "not_spam" }
 * Returns: { success, sessionId, userAnswer, correctAnswer, correct, result, explanation, feedbackMessage }
 */
router.post("/evaluate", verifyToken, evaluate);

module.exports = router;
