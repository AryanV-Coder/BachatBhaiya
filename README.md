# 🌾 Bachat Bhaiya - Financial Literacy Through Gamification

**An AI-powered RPG designed to teach financial planning, savings, and entrepreneurial skills to underserved communities in India.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flame](https://img.shields.io/badge/Flame-Game%20Engine-FF6B00?style=for-the-badge)
![Google Generative AI](https://img.shields.io/badge/Google%20Generative%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)

---

## 🎮 Project Overview

**Bachat Bhaiya** is an innovative educational game that combines entertainment with financial literacy. Players step into the shoes of a farmer, Student, or HomeMaker in a vibrant Indian village, making real-world economic decisions while earning coins, managing resources, and progressing through multiple levels.

### 🎯 Vision
Empower underprivileged communities with practical financial knowledge through an engaging, interactive gaming experience powered by AI.

### 🏆 Key Features

| Feature | Description |
|---------|-------------|
| **🎭 Role-Based Gameplay** | Choose your role: Farmer, Student, or Homemaker |
| **📊 Interactive Village Simulation** | Manage resources, make business decisions, and grow your wealth |
| **🤖 AI-Powered Guidance** | Get personalized advice and scenario generation using Google Generative AI |
| **💰 Dynamic Economy System** | Earn coins, invest, trade, and learn real financial strategies |
| **📚 Educational Quizzes** | Reinforce learning through contextual financial literacy questions |
| **📈 Progress Tracking** | Monitor your financial growth with visual charts and statistics |
| **🎨 Rich 2D Graphics** | Beautiful village world with animated characters and landscapes |

---

## 💻 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Flame** - 2D game engine for Flutter
- **FL Chart** - Data visualization for financial graphs
- **Flutter Animate** - Smooth UI animations
- **Flutter SVG** - Scalable vector graphics

### Backend
- **FastAPI** - High-performance Python web framework
- **Google Generative AI** - LLM-powered scenario generation and guidance
- **LangChain** - AI orchestration and memory management
- **AWS Bedrock** - Alternative AI services integration
- **FAISS** - Vector similarity search for knowledge retrieval
- **AWS OpenSearch** - Document storage and retrieval

### Infrastructure
- **Uvicorn** - ASGI server
- **CORS Middleware** - Cross-origin resource sharing
- **Docker-ready** - Containerized deployment

---

## 🏗️ Architecture

### Directory Structure
```
BachatBhaiya/
├── lib/                          # Flutter Frontend
│   ├── screens/                  # Game screens (splash, game_screen)
│   ├── components/               # Reusable UI components
│   ├── world/                    # Game world (village simulation)
│   ├── models/                   # Data models
│   ├── services/                 # API communication layer
│   ├── widgets/                  # Custom widgets
│   ├── constants/                # App constants
│   └── main.dart                 # Entry point
│
├── fastapi-backend/              # Python Backend
│   ├── main.py                   # FastAPI application entry
│   ├── routers/                  # API endpoints
│   │   ├── gameplay.py          # Game logic endpoints
│   │   ├── bachat_bhaiya.py     # AI guidance endpoints
│   │   └── quiz.py              # Quiz endpoints
│   ├── models/                   # Request/response schemas
│   ├── utils/                    # Utility functions
│   │   ├── gemini.py            # Google Generative AI integration
│   │   ├── bedrock.py           # AWS Bedrock integration
│   │   └── ...
│   └── requirements.txt          # Python dependencies
│
├── assets/                       # Game assets
│   ├── images/                   # Sprites and graphics
│   ├── audio/                    # Sound effects (if any)
│   └── tiles/                    # Tiled map editor files
│
├── android/                      # Android native code
├── ios/                          # iOS native code
├── web/                          # Web platform support
├── windows/                      # Windows desktop support
└── linux/                        # Linux desktop support
```

---

## 🎮 Gameplay Mechanics

### 1️⃣ Role Selection
Players choose their role:
- **👨‍🌾 Farmer** - Plant crops, manage irrigation, sell produce
- **🏪 Student** - Learn new skills, trade smartly, and manage money to build your future.
- **💼 HomeMaker** - Manage household finances, invest wisely, and earn commissions by guiding others.

### 2️⃣ Level Progression
Each role has multiple levels with increasing difficulty:
- Level 1: Basic operations (earn 100-500 coins)
- Level 2: Intermediate strategies (earn 500-2000 coins)
- Level 3+: Advanced wealth building

### 3️⃣ AI-Powered Scenarios
- **Dynamic Scene Generation**: Each level generates unique scenarios based on your role and performance
- **Smart Guidance**: Get personalized financial advice from AI
- **Contextual Learning**: Quizzes adapt to your gameplay progress

### 4️⃣ Economy System
```
Initial Investment → Execute Strategy → Earn Coins → Reinvest/Progress
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (3.11.0+)
- **Python 3.9+**
- **Git**
- **API Keys**:
  - Google Generative AI key
  - AWS credentials (optional, for Bedrock)

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/AryanV-Coder/BachatBhaiya.git
cd BachatBhaiya
```

#### 2. Setup Flutter Frontend
```bash
# Install dependencies
flutter pub get

# Run the app (requires a device or emulator)
flutter run
```

#### 3. Setup FastAPI Backend
```bash
cd fastapi-backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Python dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env with your API keys:
# GOOGLE_GENERATIVE_AI_KEY=your_key_here
# AWS_ACCESS_KEY_ID=your_key
# AWS_SECRET_ACCESS_KEY=your_key

# Run the server
uvicorn main:app --reload --port 8000
```

---

## 📱 API Endpoints

### Base URL
```
http://localhost:8000
```

### 🎮 Gameplay Endpoints

#### `POST /gameplay`
Generate game scenario for a role and level
```json
{
  "role": "farmer",
  "level": "1",
  "total_coins": "1000"
}
```

### 🤖 AI Guidance Endpoints

#### `POST /bachat-bhaiya`
Get AI-powered financial advice
```json
{
  "role": "Student",
  "previousLevel": "1",
  "currentCoins": "2500",
  "previousLevelGraph": {...}
}
```

### 📚 Quiz Endpoints

#### `POST /quiz`
Generate quiz questions
```json
{
  "role": "farmer"
}
```

---

## 🎨 Game Features in Detail

### 🌍 Village World
- Interactive 2D village map with multiple locations
- NPCs and business entities
- Day/night cycle simulation
- Weather effects

### 💰 Financial Tracking
- Real-time coin earnings display
- Historical performance graphs
- ROI calculations
- Wealth progression chart

### 🧠 Learning Integration
- Contextual quizzes after major actions
- Achievement badges
- Tips and hints from AI mentor
- Financial concepts tutorials

---

## 🛠️ Development

### Building for Production

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

### Running Backend Tests
```bash
cd fastapi-backend
pytest tests/
```

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Areas
- 🎨 UI/UX improvements
- 🤖 Better AI scenario generation
- 📊 Enhanced analytics
- 🐛 Bug fixes
- 📚 Documentation
- 🌍 Localization

---

## 📈 Performance & Scalability

- **Optimized game rendering** with Flame engine
- **Efficient API design** with FastAPI
- **Vector-based search** using FAISS for quick retrievals
- **Caching strategies** for frequently accessed data
- **Scalable architecture** ready for cloud deployment

---

## 🔐 Security

- Environment variables for sensitive keys
- CORS middleware for API security
- Input validation on all endpoints
- Secure API communication

---

## 📊 Metrics & Impact

### Target Audience
- 🎓 School and college students
- 👥 Rural communities
- 💼 Microentrepreneurs
- 📚 Financial literacy programs

### Learning Outcomes
✅ Understanding basic financial concepts  
✅ Practical investment strategies  
✅ Risk management principles  
✅ Entrepreneurship fundamentals  
✅ Sustainable business practices  

---

## 📞 Contact & Support

- **GitHub Issues**: [Report bugs](https://github.com/AryanV-Coder/BachatBhaiya/issues)
- **Discussions**: [Community discussions](https://github.com/AryanV-Coder/BachatBhaiya/discussions)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- 🎮 Flame community for the amazing game engine
- 🤖 Google Generative AI for intelligent scenario generation
- 💙 Flutter community for cross-platform development tools
- 🏆 Special thanks to all contributors and testers

---

## 🚀 Future Roadmap

- [ ] Multiplayer cooperative gameplay
- [ ] Real-time leaderboards
- [ ] Advanced financial instruments (stocks, bonds)
- [ ] Voice-based interactions with AI
- [ ] Offline gameplay support
- [ ] AR features for immersive experience
- [ ] Blockchain integration for earned assets
- [ ] International localization

---

<div align="center">

**🌱 Empowering Financial Literacy Through Play 🌱**

*Made with ❤️ by Team Bachat Bhaiya*

</div>
