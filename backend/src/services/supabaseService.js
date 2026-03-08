// src/services/supabaseService.js
const { createClient } = require("@supabase/supabase-js");

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error(
    "Missing SUPABASE_URL or SUPABASE_SERVICE_KEY/SUPABASE_ANON_KEY in environment variables"
  );
}

const supabase = createClient(supabaseUrl, supabaseKey);

// ==================== USER OPERATIONS ====================

/**
 * Create a new user
 * @param {string} user_id - Username
 * @param {string} passwordHash - Hashed password
 * @param {string} role - User role (default: "user")
 * @returns {Promise<Object>} Created user data
 */
const createUser = async (user_id, passwordHash, role = "user") => {
  const { data, error } = await supabase
    .from("User")
    .insert([{
      user_id,
      password: passwordHash,
      role,
      coins: 0,
      credit_score: 0,
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
};

/**
 * Get user by username
 * @param {string} user_id - Username
 * @returns {Promise<Object>} User data
 */
const getUserByUsername = async (user_id) => {
  const { data, error } = await supabase
    .from("User")
    .select("*")
    .eq("user_id", user_id)
    .single();

  if (error && error.code === "PGRST116") {
    return null; // User not found
  }
  if (error) throw error;
  return data;
};

/**
 * Get user by ID
 * @param {number} id - User ID
 * @returns {Promise<Object>} User data
 */
const getUserById = async (id) => {
  const { data, error } = await supabase
    .from("User")
    .select("*")
    .eq("id", id)
    .single();

  if (error && error.code === "PGRST116") {
    return null;
  }
  if (error) throw error;
  return data;
};

/**
 * Update user
 * @param {number} userId - User ID
 * @param {Object} updates - Fields to update
 * @returns {Promise<Object>} Updated user data
 */
const updateUser = async (userId, updates) => {
  const { data, error } = await supabase
    .from("User")
    .update(updates)
    .eq("id", userId)
    .select()
    .single();

  if (error) throw error;
  return data;
};

// ==================== SESSION OPERATIONS ====================

/**
 * Create a new session
 * @param {number} userId - User ID
 * @param {string} sessionId - Session ID
 * @param {string} spamMessage - The spam message for this session
 * @returns {Promise<Object>} Created session data
 */
const createSession = async (userId, sessionId, spamMessage) => {
  const { data, error } = await supabase
    .from("Transactions")
    .insert([{
      id: sessionId,
      borrower: userId,
      b_status: false, // Not completed
      current_message: spamMessage,
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
};

/**
 * Get session by ID
 * @param {string} sessionId - Session ID
 * @returns {Promise<Object>} Session data
 */
const getSession = async (sessionId) => {
  const { data, error } = await supabase
    .from("Transactions")
    .select("*")
    .eq("id", sessionId)
    .single();

  if (error && error.code === "PGRST116") {
    return null;
  }
  if (error) throw error;
  return data;
};

/**
 * Update session
 * @param {string} sessionId - Session ID
 * @param {Object} updates - Fields to update
 * @returns {Promise<Object>} Updated session data
 */
const updateSession = async (sessionId, updates) => {
  const { data, error } = await supabase
    .from("Transactions")
    .update(updates)
    .eq("id", sessionId)
    .select()
    .single();

  if (error) throw error;
  return data;
};

/**
 * Get all sessions for a user
 * @param {number} userId - User ID
 * @returns {Promise<Array>} Array of sessions
 */
const getUserSessions = async (userId) => {
  const { data, error } = await supabase
    .from("Transactions")
    .select("*")
    .eq("borrower", userId)
    .order("b_date", { ascending: false });

  if (error) throw error;
  return data || [];
};

// ==================== CHAT MESSAGE OPERATIONS ====================

/**
 * Add chat message to database
 * @param {string} sessionId - Session ID
 * @param {string} role - "user" or "assistant"
 * @param {string} content - Message content
 * @returns {Promise<Object>} Created message data
 */
const addChatMessage = async (sessionId, role, content) => {
  const { data, error } = await supabase
    .from("chat_messages")
    .insert([{
      session_id: sessionId,
      role,
      content,
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
};

/**
 * Get chat messages for a session
 * @param {string} sessionId - Session ID
 * @returns {Promise<Array>} Array of messages
 */
const getSessionMessages = async (sessionId) => {
  const { data, error } = await supabase
    .from("chat_messages")
    .select("*")
    .eq("session_id", sessionId)
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data || [];
};

module.exports = {
  supabase,
  // User operations
  createUser,
  getUserByUsername,
  getUserById,
  updateUser,
  // Session operations
  createSession,
  getSession,
  updateSession,
  getUserSessions,
  // Chat operations
  addChatMessage,
  getSessionMessages,
};
