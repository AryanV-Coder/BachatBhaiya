// src/controllers/authController.js
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const {
  createUser,
  getUserByUsername,
} = require("../services/supabaseService");

const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key-change-in-production";
const JWT_EXPIRY = process.env.JWT_EXPIRY || "24h";

/**
 * Validate signup input
 */
const validateSignupInput = (req) => {
  const { user_id, password, password_confirm } = req.body;

  if (!user_id || typeof user_id !== "string") {
    return { valid: false, error: "user_id is required and must be a string" };
  }

  if (user_id.length < 3) {
    return { valid: false, error: "user_id must be at least 3 characters long" };
  }

  if (user_id.length > 50) {
    return { valid: false, error: "user_id must be at most 50 characters long" };
  }

  if (!password || typeof password !== "string") {
    return { valid: false, error: "password is required and must be a string" };
  }

  if (password.length < 6) {
    return { valid: false, error: "password must be at least 6 characters long" };
  }

  if (password !== password_confirm) {
    return { valid: false, error: "passwords do not match" };
  }

  return { valid: true };
};

/**
 * Validate login input
 */
const validateLoginInput = (req) => {
  const { user_id, password } = req.body;

  if (!user_id || typeof user_id !== "string") {
    return { valid: false, error: "user_id is required and must be a string" };
  }

  if (!password || typeof password !== "string") {
    return { valid: false, error: "password is required and must be a string" };
  }

  return { valid: true };
};

/**
 * Sign up a new user
 */
const signup = async (req, res) => {
  try {
    // Validate input
    const validation = validateSignupInput(req);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error,
      });
    }

    const { user_id, password } = req.body;

    // Check if user already exists
    const existingUser = await getUserByUsername(user_id);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: "User already exists",
      });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user in database
    const newUser = await createUser(user_id, passwordHash, "user");

    // Generate JWT token
    const token = jwt.sign(
      { id: newUser.id, user_id: newUser.user_id, role: newUser.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRY }
    );

    return res.status(201).json({
      success: true,
      message: "User registered successfully",
      token,
      user: {
        id: newUser.id,
        user_id: newUser.user_id,
        role: newUser.role,
        coins: newUser.coins,
        credit_score: newUser.credit_score,
      },
    });
  } catch (error) {
    console.error("Error in signup:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to register user. " + error.message,
    });
  }
};

/**
 * Login a user
 */
const login = async (req, res) => {
  try {
    // Validate input
    const validation = validateLoginInput(req);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error,
      });
    }

    const { user_id, password } = req.body;

    // Get user from database
    const user = await getUserByUsername(user_id);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: "Invalid username or password",
      });
    }

    // Compare passwords
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        error: "Invalid username or password",
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, user_id: user.user_id, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRY }
    );

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: user.id,
        user_id: user.user_id,
        role: user.role,
        coins: user.coins,
        credit_score: user.credit_score,
      },
    });
  } catch (error) {
    console.error("Error in login:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to login. " + error.message,
    });
  }
};

module.exports = {
  signup,
  login,
};
