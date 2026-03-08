# Bachat Bhaiya - FastAPI Backend

A FastAPI-powered backend service for the Bachat Bhaiya financial literacy game platform. This service provides AI-driven gameplay scenarios, personalized financial mentorship, and role-based quiz generation for Indian users.

## 🎯 Overview

Bachat Bhaiya is an educational financial RPG designed to teach financial literacy through interactive gameplay. The backend generates dynamic scenarios, provides mentorship feedback, and creates contextual quizzes tailored to different user roles (Farmers, Students, Homemakers).

## ✨ Features

- **AI-Powered Gameplay Engine**: Generates dynamic 5-level decision graphs with financial scenarios
- **Financial Mentorship**: Post-level debriefs from "Bachat Bhaiya" with voice-ready feedback
- **RAG-Based Quiz Generation**: Context-aware quiz questions using Retrieval Augmented Generation
- **Multi-Role Support**: Customized content for Farmers, Students, and Homemakers
- **Hybrid AI Integration**: Leverages both AWS Bedrock and Google Gemini APIs

## 🏗️ Architecture

```
fastapi-backend/
├── main.py                     # Application entry point
├── requirements.txt            # Python dependencies
├── models/                     # Pydantic models for request/response
│   ├── bachat_bhaiya_model.py
│   ├── gameplay_model.py
│   └── quiz_model.py
├── routers/                    # API route handlers
│   ├── bachat_bhaiya.py       # Mentorship endpoints
│   ├── gameplay.py            # Game scenario generation
│   └── quiz.py                # Quiz generation
└── utils/                      # Utility functions and services
    ├── bedrock.py             # AWS Bedrock integration
    ├── gemini.py              # Google Gemini integration
    ├── sanitizer.py           # Response sanitization
    └── rag/                   # RAG implementation
        ├── agent.py           # LangChain agent setup
        ├── config.py          # Configuration
        ├── ingest.py          # Document ingestion
        ├── llm.py             # LLM configuration
        ├── tools.py           # LangChain tools
        └── faiss_db/          # Vector database
            ├── farmers/
            └── students/
```

## 🚀 Getting Started

### Prerequisites

- Python 3.8+
- AWS Account (for Bedrock access)
- Google AI API Key (for Gemini)
- Virtual environment tool (venv or conda)

### Installation

1. **Navigate to the backend directory:**
   ```bash
   cd fastapi-backend
   ```

2. **Create and activate a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   Create a `.env` file in the `fastapi-backend` directory:
   ```env
   # AWS Configuration
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   AWS_REGION=us-east-1
   
   # Google AI Configuration
   GOOGLE_API_KEY=your_gemini_api_key
   
   # OpenSearch (if used)
   OPENSEARCH_ENDPOINT=your_opensearch_endpoint
   ```

5. **Run the development server:**
   ```bash
   uvicorn main:app --reload
   ```

The API will be available at `http://localhost:8000`

## 📚 API Documentation

Once the server is running, access the interactive API documentation:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Main Endpoints

#### 1. Health Check
```http
GET /start-server
```
Verifies the server is running.

**Response:**
```json
{
  "status": "success"
}
```

#### 2. Generate Gameplay Scenario
```http
POST /gameplay
```
Generates a 5-level financial decision graph based on user role and current state.

**Request Body:**
```json
{
  "role": "Farmer",
  "level": "2",
  "total_coins": "500"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "nodes": [
      {
        "node_id": "level_1_start",
        "scenario": "You receive an SMS about a government subsidy...",
        "choices": [
          {
            "text": "Click the link immediately",
            "coin_impact": "-100",
            "next_node_id": "l2_scam_victim"
          },
          {
            "text": "Verify with the local office",
            "coin_impact": "+50",
            "next_node_id": "l2_safe_path"
          },
          {
            "text": "Ignore the message",
            "coin_impact": "0",
            "next_node_id": "l2_neutral"
          }
        ]
      }
    ],
    "optimal_path": ["Choice 2", "Choice 1", ...]
  },
  "message": "Scenario generated successfully"
}
```

#### 3. Bachat Bhaiya Debrief
```http
POST /bachat-bhaiya
```
Provides personalized post-level mentorship feedback.

**Request Body:**
```json
{
  "role": "Student",
  "previousLevel": "3",
  "currentCoins": "750",
  "previousLevelGraph": {...}
}
```

**Response:**
```json
{
  "status": "success",
  "data": "Namaste! You completed Level 3 with 750 coins. The optimal path was to verify that scholarship link first...",
  "message": "Bachat Bhaiya advice generated successfully"
}
```

#### 4. Generate Quiz
```http
POST /quiz
```
Generates role-specific quiz questions using RAG.

**Request Body:**
```json
{
  "role": "farmer"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "role": "farmer",
    "questions": [
      {
        "question_number": 1,
        "question_text": "What is the primary benefit of crop insurance?",
        "choices": {
          "A": "Higher crop yield",
          "B": "Financial protection against crop loss",
          "C": "Lower seed costs",
          "D": "Government subsidy"
        },
        "correct_answer": "B"
      }
    ]
  },
  "message": "Successfully generated quiz questions for farmer"
}
```

## 🤖 AI Integration

### AWS Bedrock
Used for gameplay scenario generation and mentorship content. Provides high-quality, contextual responses optimized for voice output.

### Google Gemini
Used for quiz generation and RAG-based content retrieval. Offers fast inference and good multilingual support.

### LangChain RAG
- **FAISS Vector Database**: Stores domain-specific knowledge for farmers and students
- **Retrieval Tools**: Custom tools for searching role-specific PDFs and documents
- **Agent System**: Orchestrates tool usage and response generation

## 🔒 Security Features

- **CORS Middleware**: Configured for cross-origin requests
- **Input Sanitization**: All AI responses are sanitized before returning
- **Response Validation**: Pydantic models ensure type safety
- **Error Handling**: Comprehensive exception handling with HTTP status codes

## 🛠️ Development

### Running Tests
```bash
pytest tests/
```

### Code Style
```bash
# Format code
black .

# Lint code
flake8 .
```

### Adding New Routes
1. Create a new router file in `routers/`
2. Define Pydantic models in `models/`
3. Register the router in `main.py`:
   ```python
   from routers import your_new_router
   app.include_router(your_new_router.router)
   ```

## 📊 RAG System

### Document Ingestion
To add new documents to the knowledge base:

```python
from utils.rag.ingest import ingest_documents

# Ingest farmer-related PDFs
ingest_documents("farmers", "/path/to/farmer/pdfs")

# Ingest student-related PDFs
ingest_documents("students", "/path/to/student/pdfs")
```

### Knowledge Base Structure
- `faiss_db/farmers/`: Agricultural schemes, rural banking, crop management
- `faiss_db/students/`: Financial literacy, budgeting, scholarships, banking

## 🌐 Deployment

### Using Docker (Recommended)
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Using Uvicorn with Gunicorn
```bash
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS access key for Bedrock | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes |
| `AWS_REGION` | AWS region (e.g., us-east-1) | Yes |
| `GOOGLE_API_KEY` | Google AI API key for Gemini | Yes |
| `OPENSEARCH_ENDPOINT` | OpenSearch cluster endpoint | No |

## 🧩 Dependencies

Core dependencies include:
- **fastapi**: Web framework
- **uvicorn**: ASGI server
- **langchain**: LLM orchestration framework
- **langchain-aws**: AWS Bedrock integration
- **boto3**: AWS SDK
- **google-genai**: Google Gemini API client
- **faiss-cpu**: Vector similarity search
- **pydantic**: Data validation
- **python-dotenv**: Environment variable management

See [requirements.txt](requirements.txt) for complete list.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a pull request

## 📄 License

This project is part of the Bachat Bhaiya platform.

## 🆘 Troubleshooting

### Common Issues

**Issue**: `ModuleNotFoundError: No module named 'faiss'`
- **Solution**: Install faiss-cpu: `pip install faiss-cpu`

**Issue**: AWS Bedrock authentication errors
- **Solution**: Verify AWS credentials and region in `.env` file

**Issue**: FAISS index not found
- **Solution**: Run document ingestion script to create the vector database

**Issue**: CORS errors in browser
- **Solution**: Check that frontend URL is included in CORS origins

## 📞 Support

For issues or questions, please open an issue in the repository.

---

**Built with ❤️ for financial literacy in India**
