# Requirements Document: Bachat Bhaiya

## Introduction

Bachat Bhaiya is an AI-driven financial life-simulation game designed to build "Digital Financial Immunity" for Indian users. The platform combines persona-based RPG mechanics, daily financial decision-making, social banking features, and realistic scam combat training to transform complex financial concepts and RBI guidelines into an engaging, educational gaming experience.

The system targets diverse Indian demographics (farmers, students, housewives, corporate employees) and uses AI-generated storylines, voice interactions, and social mechanics to create an immersive learning environment where users develop real-world financial literacy through low-stakes virtual scenarios.

## Glossary

- **Game_System**: The core Bachat Bhaiya platform managing all game mechanics, user progression, and AI interactions
- **AI_Story_Generator**: The AI subsystem responsible for creating personalized 30-day story arcs based on user persona
- **Bachat_Bhaiya**: The daily AI companion that delivers morning briefings and financial guidance
- **Haveli_Score**: Virtual wealth metric representing user's financial success (0-100 scale)
- **Zubaan_Score**: Trust/reputation metric affecting social banking interactions (0-100 scale)
- **Friendship_Score**: AI-calculated metric between users determining P2P lending rates
- **Scam_Combat_Engine**: AI subsystem generating and evaluating realistic financial scam scenarios
- **Cyber_Shield_Badge**: Achievement unlocked after successfully identifying scams
- **Social_Banking_Module**: Subsystem managing P2P lending, group pooling, and friend interactions
- **Voice_AI_System**: Text-to-speech and speech-to-text system using Bhashini/Google Cloud TTS
- **RAG_System**: Retrieval-Augmented Generation system with RBI circulars and NPCI guidelines
- **User_Persona**: One of four roles (Farmer, Student, Housewife, Corporate_Employee)
- **Story_Arc**: 30-day narrative sequence with financial decision points
- **Daily_Loop**: Morning routine consisting of Audit, News Feed, and Safety Brief
- **P2P_Lending**: Peer-to-peer virtual money lending between friends
- **Collective_Goal**: Group pooling mechanism for community asset acquisition
- **Game_Master**: AI system orchestrating scam scenarios and providing feedback

## Requirements

### Requirement 1: User Persona Selection and Onboarding

**User Story:** As a new user, I want to select a persona that matches my real-life situation, so that I receive relevant financial scenarios and learning experiences.

#### Acceptance Criteria

1. WHEN a new user launches the application, THE Game_System SHALL display four persona options (Farmer, Student, Housewife, Corporate_Employee) with descriptions
2. WHEN a user selects a persona, THE Game_System SHALL store the persona choice and initialize appropriate starting values for Haveli_Score and Zubaan_Score
3. WHEN persona selection is complete, THE AI_Story_Generator SHALL create an initial 30-day Story_Arc tailored to the selected User_Persona
4. WHEN onboarding is complete, THE Game_System SHALL persist user profile data to local storage
5. THE Game_System SHALL authenticate users via Firebase phone number authentication before persona selection

### Requirement 2: AI-Generated Story Arc Creation

**User Story:** As a user, I want personalized financial storylines that reflect my chosen persona, so that the game feels relevant to my daily life.

#### Acceptance Criteria

1. WHEN a Story_Arc is requested, THE AI_Story_Generator SHALL generate a 30-day narrative sequence with minimum 15 financial decision points
2. WHEN generating storylines, THE AI_Story_Generator SHALL incorporate persona-specific scenarios (crop loans for Farmer, education expenses for Student, household budgeting for Housewife, salary management for Corporate_Employee)
3. WHEN a Story_Arc is created, THE AI_Story_Generator SHALL define clear financial outcomes for each decision point affecting Haveli_Score and Zubaan_Score
4. WHEN a 30-day Story_Arc completes, THE AI_Story_Generator SHALL automatically generate a new Story_Arc maintaining narrative continuity
5. THE AI_Story_Generator SHALL use Gemini 1.5 Flash via Vertex AI for story generation

### Requirement 3: Daily "Bachat Bhaiya" Loop

**User Story:** As a daily user, I want a morning routine that reviews my progress and prepares me for the day, so that I stay engaged and learn consistently.

#### Acceptance Criteria

1. WHEN a user opens the app each day, THE Bachat_Bhaiya SHALL deliver The Audit showing yesterday's financial decisions with "Hits" and "Misses" breakdown
2. WHEN The Audit is displayed, THE Game_System SHALL show specific Haveli_Score and Zubaan_Score changes from previous day's decisions
3. WHEN The Audit completes, THE Bachat_Bhaiya SHALL deliver The News Feed with simulated market updates relevant to the user's User_Persona
4. WHEN The News Feed is delivered, THE Voice_AI_System SHALL provide audio narration using Bhashini APIs or Google Cloud TTS
5. IF a user encountered a scam scenario in the previous 24 hours, THEN THE Bachat_Bhaiya SHALL deliver The Safety Brief explaining relevant RBI guidelines and demonstrating 1930 Cybercrime Helpline usage

### Requirement 4: Haveli and Zubaan Score Management

**User Story:** As a player, I want clear metrics showing my financial success and trustworthiness, so that I understand the consequences of my decisions.

#### Acceptance Criteria

1. WHEN a user makes a financial decision, THE Game_System SHALL update Haveli_Score based on economic outcome (range 0-100)
2. WHEN a user makes a social or trust-related decision, THE Game_System SHALL update Zubaan_Score based on reliability and honesty (range 0-100)
3. WHEN scores change, THE Game_System SHALL display visual feedback showing the magnitude and direction of change
4. THE Game_System SHALL persist Haveli_Score and Zubaan_Score to local storage after each update
5. WHEN a user views their profile, THE Game_System SHALL display current Haveli_Score and Zubaan_Score with historical trend graphs

### Requirement 5: Social Banking Chat System

**User Story:** As a user, I want to chat with friends in the game, so that I can coordinate financial activities and build social connections.

#### Acceptance Criteria

1. WHEN a user adds a friend, THE Social_Banking_Module SHALL establish a bidirectional connection and initialize Friendship_Score
2. WHEN users exchange messages, THE Social_Banking_Module SHALL deliver messages in real-time using Socket.io
3. WHEN chat history is requested, THE Social_Banking_Module SHALL retrieve and display message history from MongoDB
4. THE Social_Banking_Module SHALL support text messages with maximum length of 500 characters
5. WHEN a user is offline, THE Social_Banking_Module SHALL queue messages for delivery when the user reconnects

### Requirement 6: P2P Lending System

**User Story:** As a user, I want to lend or borrow virtual money from friends, so that I can experience real-world lending dynamics in a safe environment.

#### Acceptance Criteria

1. WHEN a user initiates a lending request, THE Social_Banking_Module SHALL validate that the lender has sufficient Haveli_Score balance
2. WHEN a lending transaction is created, THE Social_Banking_Module SHALL calculate interest rate based on Friendship_Score between users (range 0-20% annual)
3. WHEN a loan is accepted, THE Game_System SHALL transfer virtual currency and update both users' Haveli_Scores immediately
4. WHEN a loan repayment is due, THE Social_Banking_Module SHALL send notification to borrower 24 hours before deadline
5. WHEN a loan is repaid on time, THE Game_System SHALL increase Zubaan_Score for borrower and Friendship_Score between users
6. WHEN a loan is not repaid on time, THE Game_System SHALL decrease Zubaan_Score for borrower and Friendship_Score between users

### Requirement 7: Friendship Score Calculation

**User Story:** As a user, I want my lending rates to reflect the trust I've built with friends, so that good relationships are rewarded with better terms.

#### Acceptance Criteria

1. WHEN a new friendship is established, THE Social_Banking_Module SHALL initialize Friendship_Score at 50 (neutral)
2. WHEN users complete successful lending transactions, THE Social_Banking_Module SHALL increase Friendship_Score by 5-10 points
3. WHEN users default on loans, THE Social_Banking_Module SHALL decrease Friendship_Score by 10-20 points
4. WHEN users interact positively (messages, collective goals), THE Social_Banking_Module SHALL increase Friendship_Score by 1-3 points
5. WHEN calculating P2P lending interest rates, THE Social_Banking_Module SHALL use formula: base_rate * (100 - Friendship_Score) / 100, where base_rate is 20%

### Requirement 8: Collective Goals and Group Pooling

**User Story:** As a user, I want to pool resources with friends toward shared goals, so that I learn about cooperative financial planning.

#### Acceptance Criteria

1. WHEN a user creates a Collective_Goal, THE Social_Banking_Module SHALL define target amount, deadline, and invite list
2. WHEN invited users join a Collective_Goal, THE Social_Banking_Module SHALL track individual contributions and total progress
3. WHEN a user contributes to a Collective_Goal, THE Game_System SHALL deduct from user's Haveli_Score and add to goal pool
4. WHEN a Collective_Goal reaches 100% funding before deadline, THE Social_Banking_Module SHALL distribute the community asset to all participants
5. WHEN a Collective_Goal fails to reach target by deadline, THE Social_Banking_Module SHALL refund all contributions to participants

### Requirement 9: Scam Combat Engine - Scenario Generation

**User Story:** As a user, I want to encounter realistic scam attempts, so that I can practice identifying and avoiding financial fraud.

#### Acceptance Criteria

1. WHEN a user has been active for minimum 3 days, THE Scam_Combat_Engine SHALL begin generating scam scenarios
2. WHEN generating scams, THE Scam_Combat_Engine SHALL create scenarios from categories: Phishing, Fake Bills, Deepfake Voice Calls, UPI Fraud, Lottery Scams
3. WHEN a scam is presented, THE Game_Master SHALL provide realistic context matching the user's User_Persona and current Story_Arc
4. THE Scam_Combat_Engine SHALL generate scams with frequency of 2-4 per week per user
5. WHEN generating scam content, THE Scam_Combat_Engine SHALL use RAG_System to ensure accuracy against RBI circulars and NPCI guidelines

### Requirement 10: Scam Combat - User Response and Feedback

**User Story:** As a user, I want immediate feedback on my scam responses, so that I learn what to watch for in real situations.

#### Acceptance Criteria

1. WHEN a user responds to a scam scenario, THE Scam_Combat_Engine SHALL evaluate the response within 2 seconds
2. WHEN a user correctly identifies a scam, THE Game_System SHALL increase Haveli_Score by 50-100 points and award a Cyber_Shield_Badge
3. WHEN a user falls for a scam, THE Game_System SHALL decrease Haveli_Score by 100-300 points and display educational feedback
4. WHEN feedback is provided, THE Scam_Combat_Engine SHALL explain specific red flags using RAG_System to reference RBI guidelines
5. WHEN a user accumulates 5 Cyber_Shield_Badges, THE Game_System SHALL unlock advanced gameplay features (higher lending limits, exclusive story branches)

### Requirement 11: RBI Guidelines Integration via RAG

**User Story:** As a user, I want accurate financial guidance based on official regulations, so that I learn legitimate practices.

#### Acceptance Criteria

1. WHEN The Safety Brief is delivered, THE RAG_System SHALL retrieve relevant RBI circulars matching the encountered scam type
2. WHEN educational content is generated, THE RAG_System SHALL cite specific RBI circular numbers and NPCI guidelines
3. THE RAG_System SHALL maintain an updated knowledge base of RBI circulars with refresh cycle of 7 days
4. WHEN a user requests explanation of a financial term, THE RAG_System SHALL provide definition sourced from official RBI documentation
5. THE RAG_System SHALL use vector embeddings for semantic search across RBI and NPCI document corpus

### Requirement 12: Voice AI Integration

**User Story:** As a user, I want to hear financial news and guidance in my preferred language, so that I can learn while multitasking.

#### Acceptance Criteria

1. WHEN The News Feed is delivered, THE Voice_AI_System SHALL convert text to speech using Bhashini APIs or Google Cloud TTS
2. THE Voice_AI_System SHALL support minimum 5 Indian languages (Hindi, English, Tamil, Telugu, Bengali)
3. WHEN a user selects a language preference, THE Game_System SHALL persist the choice and use it for all Voice_AI_System outputs
4. WHEN audio playback is initiated, THE Voice_AI_System SHALL provide playback controls (play, pause, replay)
5. WHERE voice input is available, THE Voice_AI_System SHALL accept speech-to-text for user responses to scenarios

### Requirement 13: Data Persistence and Synchronization

**User Story:** As a user, I want my progress saved automatically, so that I don't lose my achievements if I switch devices or lose connectivity.

#### Acceptance Criteria

1. WHEN a user makes progress, THE Game_System SHALL save critical data (Haveli_Score, Zubaan_Score, Story_Arc position) to local SQLite database immediately
2. WHEN internet connectivity is available, THE Game_System SHALL synchronize local data to MongoDB cloud storage within 30 seconds
3. WHEN a user logs in from a new device, THE Game_System SHALL retrieve latest game state from MongoDB and populate local SQLite database
4. WHEN synchronization conflicts occur, THE Game_System SHALL use server timestamp as source of truth and overwrite local data
5. THE Game_System SHALL maintain offline functionality for core gameplay (story progression, score updates) when internet is unavailable

### Requirement 14: 1930 Cybercrime Helpline Integration

**User Story:** As a user, I want to learn how to report real cybercrimes, so that I'm prepared if I encounter actual fraud.

#### Acceptance Criteria

1. WHEN The Safety Brief is delivered after a scam encounter, THE Bachat_Bhaiya SHALL demonstrate the process of calling 1930 Cybercrime Helpline
2. WHEN the demonstration is shown, THE Game_System SHALL display step-by-step visual guide with screenshots or animations
3. THE Game_System SHALL provide a direct link to initiate a call to 1930 from within the app
4. WHEN a user completes the 1930 demonstration tutorial, THE Game_System SHALL award a special Cyber_Shield_Badge
5. THE Game_System SHALL include information about reporting timelines and required documentation for cybercrime reports

### Requirement 15: Achievement and Badge System

**User Story:** As a user, I want to earn badges and achievements, so that I feel motivated to continue learning and improving.

#### Acceptance Criteria

1. WHEN a user completes specific milestones, THE Game_System SHALL award corresponding Cyber_Shield_Badges
2. THE Game_System SHALL track badge categories: Scam Detection, Lending Mastery, Savings Champion, Community Builder
3. WHEN a badge is earned, THE Game_System SHALL display celebration animation and update user profile
4. WHEN a user views their profile, THE Game_System SHALL display all earned badges with unlock dates and descriptions
5. WHEN a user earns rare badges, THE Game_System SHALL increase Zubaan_Score by 5-10 points

### Requirement 16: User Authentication and Security

**User Story:** As a user, I want secure access to my account, so that my progress and personal information are protected.

#### Acceptance Criteria

1. WHEN a new user registers, THE Game_System SHALL authenticate via Firebase phone number authentication with OTP verification
2. WHEN a user logs in, THE Game_System SHALL validate credentials and establish secure session with JWT token
3. THE Game_System SHALL enforce session timeout of 30 days for inactive users
4. WHEN sensitive operations are performed (P2P lending above 1000 virtual currency), THE Game_System SHALL require re-authentication
5. THE Game_System SHALL encrypt all user data at rest using AES-256 encryption

### Requirement 17: Performance and Responsiveness

**User Story:** As a user, I want the app to respond quickly, so that my gaming experience is smooth and enjoyable.

#### Acceptance Criteria

1. WHEN a user navigates between screens, THE Game_System SHALL render new screen within 500ms
2. WHEN AI_Story_Generator creates content, THE Game_System SHALL display loading indicator if generation exceeds 2 seconds
3. WHEN real-time chat messages are sent, THE Social_Banking_Module SHALL deliver messages with latency under 1 second
4. THE Game_System SHALL maintain frame rate of minimum 30 FPS during animations using Flame Engine
5. WHEN the app launches, THE Game_System SHALL display main screen within 3 seconds on devices with minimum 2GB RAM

### Requirement 18: Accessibility and Localization

**User Story:** As a user with accessibility needs, I want the app to support assistive technologies, so that I can fully participate in the game.

#### Acceptance Criteria

1. THE Game_System SHALL support screen reader compatibility for all text content
2. THE Game_System SHALL provide minimum font size of 14sp with user-adjustable scaling up to 24sp
3. THE Game_System SHALL maintain color contrast ratio of minimum 4.5:1 for all text elements
4. THE Game_System SHALL support localization for minimum 5 Indian languages with complete UI translation
5. WHERE animations are used, THE Game_System SHALL provide option to reduce motion for users with vestibular disorders

### Requirement 19: Analytics and Progress Tracking

**User Story:** As a user, I want to see my learning progress over time, so that I can understand how much I've improved.

#### Acceptance Criteria

1. WHEN a user views their dashboard, THE Game_System SHALL display statistics: total scams detected, total scams missed, lending success rate, savings rate
2. THE Game_System SHALL track daily active streaks and award bonus points for consecutive daily logins
3. WHEN a user completes a Story_Arc, THE Game_System SHALL generate a summary report showing financial decisions and outcomes
4. THE Game_System SHALL provide comparison metrics showing user performance against anonymized community averages
5. WHEN a user requests historical data, THE Game_System SHALL display graphs showing Haveli_Score and Zubaan_Score trends over 30-day periods

### Requirement 20: Content Moderation for Social Features

**User Story:** As a user, I want a safe social environment, so that I can interact with others without harassment or inappropriate content.

#### Acceptance Criteria

1. WHEN a user sends a chat message, THE Social_Banking_Module SHALL scan content for profanity and inappropriate language
2. WHEN inappropriate content is detected, THE Social_Banking_Module SHALL block the message and warn the sender
3. WHEN a user reports another user, THE Game_System SHALL flag the account for review and temporarily restrict social features
4. THE Social_Banking_Module SHALL implement rate limiting of 50 messages per hour per user to prevent spam
5. WHEN a user accumulates 3 content violations, THE Game_System SHALL suspend social features for 24 hours
