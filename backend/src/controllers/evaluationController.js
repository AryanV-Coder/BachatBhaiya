// src/controllers/evaluationController.js
const { generateEvaluation } = require("../services/geminiService");
const {
  getSession,
  updateSession,
} = require("../services/supabaseService");

/**
 * Validate user input for evaluation endpoint
 */
const validateEvaluationInput = (req) => {
  const { sessionId, userFinalAnswer } = req.body;

  if (!sessionId || typeof sessionId !== "string") {
    return { valid: false, error: "sessionId is required and must be a string" };
  }

  if (!userFinalAnswer || typeof userFinalAnswer !== "string") {
    return {
      valid: false,
      error: "userFinalAnswer is required and must be a string",
    };
  }

  const validAnswers = ["spam", "not_spam"];
  if (!validAnswers.includes(userFinalAnswer.toLowerCase())) {
    return {
      valid: false,
      error: 'userFinalAnswer must be either "spam" or "not_spam"',
    };
  }

  return { valid: true };
};

/**
 * Evaluate the user's answer
 * Checks if they correctly identified the message as spam
 * Requires authentication (Bearer token in Authorization header)
 */
const evaluate = async (req, res) => {
  try {
    // Validate input
    const validation = validateEvaluationInput(req);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error,
      });
    }

    const { sessionId, userFinalAnswer } = req.body;
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

    // Check if already evaluated
    if (session.b_status) {
      return res.status(400).json({
        success: false,
        error: "This session has already been evaluated.",
      });
    }

    // The correct answer is always "spam" since we generate spam messages
    const correctAnswer = "spam";
    const userAnswerLower = userFinalAnswer.toLowerCase();
    const isCorrect = userAnswerLower === correctAnswer;

    // Get the spam message for explanation
    const spamMessage = session.current_message;

    // Generate explanation
    const explanation = await generateEvaluation(spamMessage, isCorrect);

    // Mark session as evaluated and store user response
    await updateSession(sessionId, {
      user_response: userAnswerLower,
      is_correct: isCorrect,
      b_status: true, // Mark as completed
    });

    return res.status(200).json({
      success: true,
      sessionId,
      userAnswer: userAnswerLower,
      correctAnswer,
      correct: isCorrect,
      result: isCorrect ? "✓ Correct!" : "✗ Incorrect",
      explanation,
      feedbackMessage: isCorrect
        ? "Great job! You correctly identified the spam message. You're developing good instincts for detecting phishing and spam."
        : "Not quite! You missed some red flags. The message was actually spam. Study the explanation above to improve your spam detection skills.",
    });
  } catch (error) {
    console.error("Error in evaluate:", error);
    return res.status(500).json({
      success: false,
      error: "Evaluation failed. " + error.message,
    });
  }
};

module.exports = {
  evaluate,
};
