// src/controllers/chatController.js
const { chatWithAssistant } = require("../services/geminiService");
const {
  getSession,
  getSessionMessages,
  addChatMessage,
} = require("../services/supabaseService");

/**
 * Validate user input for chat endpoint
 */
const validateChatInput = (req) => {
  const { sessionId, userMessage } = req.body;

  if (!sessionId || typeof sessionId !== "string") {
    return { valid: false, error: "sessionId is required and must be a string" };
  }

  if (!userMessage || typeof userMessage !== "string") {
    return {
      valid: false,
      error: "userMessage is required and must be a string",
    };
  }

  if (userMessage.trim().length === 0) {
    return { valid: false, error: "userMessage cannot be empty" };
  }

  if (userMessage.length > 2000) {
    return { valid: false, error: "userMessage is too long (max 2000 chars)" };
  }

  return { valid: true };
};

/**
 * Handle chat interaction
 * User sends a message, chatbot responds to help them analyze the spam
 * Requires authentication (Bearer token in Authorization header)
 */
const chat = async (req, res) => {
  try {
    // Validate input
    const validation = validateChatInput(req);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error,
      });
    }

    const { sessionId, userMessage } = req.body;
    const userId = req.user.id;

    // Check if session exists and belongs to user
    const session = await getSession(sessionId);
    if (!session) {
      return res.status(404).json({
        success: false,
        error: "Session not found. Please start a new session first.",
      });
    }

    if (session.borrower !== userId) {
      return res.status(403).json({
        success: false,
        error: "Unauthorized: This session belongs to another user.",
      });
    }

    // Prevent chat if session is already evaluated
    if (session.b_status) {
      return res.status(400).json({
        success: false,
        error: "This session has already been evaluated. Start a new session.",
      });
    }

    // Add user message to database
    await addChatMessage(sessionId, "user", userMessage);

    // Get conversation history
    const messages = await getSessionMessages(sessionId);
    const conversationHistory = messages.map((m) => ({
      role: m.role,
      content: m.content,
    }));

    // Get the spam message for context
    const spamMessage = session.current_message;

    // Get assistant response
    const assistantResponse = await chatWithAssistant(
      spamMessage,
      conversationHistory
    );

    // Add assistant response to database
    await addChatMessage(sessionId, "assistant", assistantResponse);

    return res.status(200).json({
      success: true,
      sessionId,
      assistantResponse,
      conversationLength: conversationHistory.length,
      instruction:
        "Continue chatting to analyze the message, then use the /evaluate endpoint to provide your final answer.",
    });
  } catch (error) {
    console.error("Error in chat:", error);
    return res.status(500).json({
      success: false,
      error: "Chat failed. " + error.message,
    });
  }
};

module.exports = {
  chat,
};
