from langchain_community.vectorstores import FAISS
from langchain_aws import BedrockEmbeddings
from langchain.tools import tool
from .config import bedrock_runtime
import os

# Get the absolute path to this file's directory
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
FAISS_DB_PATH = os.path.join(CURRENT_DIR, "faiss_db")

# Initialize embeddings
embeddings = BedrockEmbeddings(
    client=bedrock_runtime,
    model_id="amazon.titan-embed-text-v2:0"
)

# Load FAISS indexes
farmer_vector_collection = FAISS.load_local(
    os.path.join(FAISS_DB_PATH, "farmers"),
    embeddings,
    allow_dangerous_deserialization=True
)

student_vector_collection = FAISS.load_local(
    os.path.join(FAISS_DB_PATH, "students"),
    embeddings,
    allow_dangerous_deserialization=True
)

# Create retrievers
farmer_retriever = farmer_vector_collection.as_retriever()
student_retriever = student_vector_collection.as_retriever()


@tool("search_farmer_pdf")
def search_farmer_knowledge(query: str) -> str:
    """Search comprehensive database of farming knowledge, agricultural practices, and rural financial management.
    
    Use this tool for queries about:
    - Agricultural techniques, crop cultivation, and farming best practices
    - Soil management, irrigation, fertilizers, and pest control
    - Crop planning, seasonal farming, and harvest management
    - Government schemes, subsidies, and benefits for farmers
    - Agricultural loans, insurance, and financial assistance programs
    - Market prices, crop selling strategies, and income management
    - Rural banking, savings, and investment options for farmers
    - Agricultural equipment, tools, and modern farming technology
    - Weather patterns, climate considerations, and disaster management
    - Organic farming, sustainable agriculture, and crop diversification
    
    This is your primary source for farmer-specific information, agricultural guidance, and rural financial literacy.
    
    Args:
        query: The search query about farming or farmer-related topics
        
    Returns:
        Relevant farming information and agricultural guidance
    """
    docs = farmer_retriever.invoke(query)
    return "\n\n".join([f"[Result {i+1}]\n{doc.page_content}" for i, doc in enumerate(docs)])


@tool("search_student_pdf")
def search_student_knowledge(query: str) -> str:
    """Search comprehensive database of student-focused financial literacy, education, and personal development.
    
    Use this tool for queries about:
    - Personal finance basics, budgeting, and money management for students
    - Savings accounts, student banking, and financial products for youth
    - Scholarship programs, educational loans, and funding opportunities
    - Part-time work, internships, and earning opportunities for students
    - Digital payments, online transactions, and financial technology
    - Investment basics, financial planning, and building wealth early
    - Career guidance, skill development, and educational pathways
    - Study techniques, time management, and academic success strategies
    - Government schemes and benefits for students and youth
    - Entrepreneurship, startups, and business ideas for students
    
    This is your primary source for student-specific information, financial education, and youth development guidance.
    
    Args:
        query: The search query about student life or student-related topics
        
    Returns:
        Relevant student information and educational guidance
    """
    docs = student_retriever.invoke(query)
    return "\n\n".join([f"[Result {i+1}]\n{doc.page_content}" for i, doc in enumerate(docs)])


tools = [
    search_farmer_knowledge,
    search_student_knowledge
]