// src/app.js
require("dotenv").config({ path: require("path").join(__dirname, "../.env") });
const express = require("express");

// Import routes and middleware
const spamRoutes = require("./routes/spamRoutes");
const {
  createRateLimiter,
  logRequest,
  errorHandler,
  notFoundHandler,
} = require("./utils/middleware");

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// ==================== MIDDLEWARE ====================

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use(logRequest);

// Rate limiting
app.use("/api/", createRateLimiter());

// ==================== ROUTES ====================

// Health check endpoint
app.get("/health", (req, res) => {
  return res.status(200).json({
    success: true,
    message: "Spam Detection Training Chatbot Backend is running",
    timestamp: new Date().toISOString(),
  });
});

// API documentation endpoint
app.get("/api", (req, res) => {
  return res.status(200).json({
    success: true,
    serviceName: "Spam Detection Training Chatbot",
    version: "1.0.0",
    description:
      "Backend service for interactive spam detection training using Gemini AI",
    note: "All endpoints except /auth/signup and /auth/login require Bearer token in Authorization header",
    endpoints: [
      {
        method: "POST",
        path: "/api/spam/auth/signup",
        description: "Create a new user account",
        authentication: "None",
        request: {
          user_id: "string",
          password: "string",
          password_confirm: "string",
        },
        response: {
          success: true,
          message: "User registered successfully",
          token: "jwt_token",
          user: {
            id: "number",
            user_id: "string",
            role: "string",
            coins: "number",
            credit_score: "number",
          },
        },
      },
      {
        method: "POST",
        path: "/api/spam/auth/login",
        description: "Login with username and password",
        authentication: "None",
        request: {
          user_id: "string",
          password: "string",
        },
        response: {
          success: true,
          message: "Login successful",
          token: "jwt_token",
          user: {
            id: "number",
            user_id: "string",
            role: "string",
            coins: "number",
            credit_score: "number",
          },
        },
      },
      {
        method: "POST",
        path: "/api/spam/start-session",
        description: "Start a new spam detection session",
        authentication: "Bearer token (required)",
        request: "{}",
        response: {
          success: true,
          sessionId: "uuid",
          userId: "number",
          message: "string",
          receivedMessage: "string",
          instruction: "string",
        },
      },
      {
        method: "POST",
        path: "/api/spam/chat",
        description: "Chat with the assistant to analyze the message",
        authentication: "Bearer token (required)",
        request: {
          sessionId: "string",
          userMessage: "string",
        },
        response: {
          success: true,
          sessionId: "uuid",
          assistantResponse: "string",
          conversationLength: "number",
          instruction: "string",
        },
      },
      {
        method: "POST",
        path: "/api/spam/evaluate",
        description:
          "Submit your final answer and get evaluation with explanation",
        authentication: "Bearer token (required)",
        request: {
          sessionId: "string",
          userFinalAnswer: "spam | not_spam",
        },
        response: {
          success: true,
          sessionId: "uuid",
          userAnswer: "string",
          correctAnswer: "string",
          correct: "boolean",
          result: "string",
          explanation: "string",
          feedbackMessage: "string",
        },
      },
    ],
  });
});

// Spam detection routes
app.use("/api/spam", spamRoutes);

// ==================== ERROR HANDLING ====================

// 404 handler
app.use(notFoundHandler);

// Global error handler (must be last)
app.use(errorHandler);

// ==================== SERVER ====================

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║   Spam Detection Training Chatbot Backend             ║
║   Server running on: http://localhost:${PORT}            ║
║   Health check: http://localhost:${PORT}/health        ║
║   API docs: http://localhost:${PORT}/api              ║
╚═══════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
