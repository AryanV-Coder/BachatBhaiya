// src/controllers/spamController.js
const { generateSpamMessage } = require("../services/geminiService");
const { createSession } = require("../services/supabaseService");
const { v4: uuidv4 } = require("uuid");

/**
 * Start a new spam detection session
 * Generates a spam message and creates a session ID
 * Requires authentication (Bearer token in Authorization header)
 */
const startSession = async (req, res) => {
  try {
    // Get user ID from auth token
    const userId = req.user.id;

    // Generate spam message
    const spamMessage = await generateSpamMessage();

    // Generate unique session ID
    const sessionId = uuidv4();

    // Create session with the spam message in database
    await createSession(userId, sessionId, spamMessage);

    // Return session ID and the message to analyze
    return res.status(201).json({
      success: true,
      sessionId,
      userId,
      message:
        "A new spam detection training session has started. Here's a message you received:",
      receivedMessage: spamMessage,
      instruction:
        "Analyze this message carefully. Is it spam or legitimate? Chat with the assistant to help you decide, then provide your final answer.",
    });
  } catch (error) {
    console.error("Error in startSession:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to start session. " + error.message,
    });
  }
};

module.exports = {
  startSession,
};
