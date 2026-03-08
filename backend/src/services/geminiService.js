// src/services/geminiService.js
const { GoogleGenerativeAI } = require("@google/generative-ai");

/**
 * Initialize Gemini AI with API key from environment variables
 */
const initializeGemini = () => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY environment variable is not set");
  }
  return new GoogleGenerativeAI(apiKey);
};

// Initialize Gemini client
const genAI = initializeGemini();
const MODEL_NAME = "gemini-2.5-flash";

/**
 * Generate a realistic spam/phishing message using Gemini
 * @returns {Promise<string>} Generated spam message
 */
const generateSpamMessage = async () => {
  try {
    const prompt = `Generate a realistic phishing or spam message that would typically be sent via email or SMS. 
    
Requirements:
- Make it convincing and realistic so it challenges users to identify if it's spam
- Include common phishing elements (urgency, requests for personal info, suspicious links, etc.)
- Do NOT explicitly say it is spam or a test
- The message should be 1-3 sentences long
- Write it as if it's from a real company or service
- Make it seem legitimate at first glance

Generate only the spam message itself, nothing else.`;

    const model = genAI.getGenerativeModel({ model: MODEL_NAME });
    const result = await model.generateContent(prompt);
    const response = result.response;
    const spamMessage = response.text().trim();

    if (!spamMessage) {
      throw new Error("Failed to generate spam message from Gemini");
    }

    return spamMessage;
  } catch (error) {
    console.error("Error generating spam message:", error);
    throw error;
  }
};

/**
 * Chat with Gemini to help user analyze the message
 * Gemini acts as a neutral assistant without revealing the answer
 * @param {string} spamMessage - The original spam message to analyze
 * @param {Array} conversationHistory - Array of previous messages
 * @returns {Promise<string>} Assistant's response
 */
const chatWithAssistant = async (spamMessage, conversationHistory = []) => {
  try {
    const systemPrompt = `You are a neutral assistant helping a user determine whether a message is spam or legitimate. 
    
The message under analysis is: "${spamMessage}"

Your role:
- Ask probing questions to help the user think critically about the message
- Point out suspicious elements without giving away the answer
- Be conversational and encouraging
- Help them analyze sender, requests for personal info, urgency, grammar, links, etc.
- Do NOT explicitly say whether it is spam or not
- Keep responses concise (1-2 sentences per response)

Analyze the message and respond helpfully.`;

    const model = genAI.getGenerativeModel({ model: MODEL_NAME });

    // Build conversation with system context
    const chat = model.startChat({
      history: conversationHistory.map((msg) => ({
        role: msg.role,
        parts: msg.content,
      })),
      generationConfig: {
        maxOutputTokens: 200,
      },
    });

    const userMessage =
      conversationHistory.length === 0
        ? `Here's a message I received: "${spamMessage}". Can you help me determine if it's spam or legitimate?`
        : conversationHistory[conversationHistory.length - 1].content;

    const result = await chat.sendMessage(userMessage);
    const assistantResponse = result.response.text().trim();

    if (!assistantResponse) {
      throw new Error("Failed to get response from Gemini");
    }

    return assistantResponse;
  } catch (error) {
    console.error("Error in chat with assistant:", error);
    throw error;
  }
};

/**
 * Generate evaluation explanation based on user's answer
 * @param {string} spamMessage - The original spam message
 * @param {boolean} userSaidSpam - Whether user identified it as spam
 * @returns {Promise<string>} Explanation of the answer
 */
const generateEvaluation = async (spamMessage, userSaidSpam) => {
  try {
    const prompt = `A user was asked to identify whether this message is spam or legitimate:
    
"${spamMessage}"

They answered: "${userSaidSpam ? "SPAM" : "NOT SPAM"}"

This message is actually SPAM. ${userSaidSpam ? "They got it correct!" : "They incorrectly identified it as legitimate."}

Provide a brief explanation (2-3 sentences) of why this message is spam, highlighting the key red flags that should have been noticed.`;

    const model = genAI.getGenerativeModel({ model: MODEL_NAME });
    const result = await model.generateContent(prompt);
    const explanation = result.response.text().trim();

    return explanation;
  } catch (error) {
    console.error("Error generating evaluation:", error);
    throw error;
  }
};

module.exports = {
  generateSpamMessage,
  chatWithAssistant,
  generateEvaluation,
};
