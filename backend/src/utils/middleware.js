// src/utils/middleware.js
const rateLimit = require("express-rate-limit");

/**
 * Rate limiting middleware
 * Prevents abuse by limiting requests per IP
 */
const createRateLimiter = () => {
  const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || "900000"); // 15 minutes
  const maxRequests = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || "100");

  return rateLimit({
    windowMs,
    max: maxRequests,
    message: {
      success: false,
      error: "Too many requests. Please try again later.",
    },
    standardHeaders: true, // Return rate limit info in `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  });
};

/**
 * Request logging middleware
 * Logs API requests for debugging
 */
const logRequest = (req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
};

/**
 * Global error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error("Error:", err);

  // Check if response was already sent
  if (res.headersSent) {
    return next(err);
  }

  return res.status(err.status || 500).json({
    success: false,
    error: err.message || "Internal server error",
  });
};

/**
 * 404 handler for unknown routes
 */
const notFoundHandler = (req, res) => {
  return res.status(404).json({
    success: false,
    error: "Endpoint not found",
    path: req.path,
    method: req.method,
    availableEndpoints: [
      "POST /api/spam/start-session",
      "POST /api/spam/chat",
      "POST /api/spam/evaluate",
    ],
  });
};

module.exports = {
  createRateLimiter,
  logRequest,
  errorHandler,
  notFoundHandler,
};
