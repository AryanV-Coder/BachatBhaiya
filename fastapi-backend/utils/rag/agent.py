from langchain.agents import create_agent
from langchain_core.messages import HumanMessage
from .llm import llm
from .tools import tools
from ..sanitizer import sanitize_ai_response

# Define system prompt for the quiz generation agent
system_prompt = """You are an AI quiz generation assistant with expertise in financial literacy and education. Your task is to generate relevant, contextual quiz questions based on the user's role.

IMPORTANT INSTRUCTIONS:
1. First, identify the user's role from their input (e.g., farmer, student)
2. Always search the appropriate knowledge base using the tools BEFORE generating questions:
   - Use search_farmer_pdf for farmer-related queries
   - Use search_student_pdf for student-related queries
3. Generate exactly 5 questions that are highly relevant to the role and based on the retrieved context
4. Each question must have exactly 4 answer choices (labeled A, B, C, D)
5. Identify the correct answer for each question

KNOWLEDGE BASE ACCESS:
- For farmers: Search agricultural practices, government schemes, rural banking, loans, crop management
- For students: Search financial literacy, budgeting, scholarships, banking, career guidance

OUTPUT FORMAT:
You must respond ONLY with a valid JSON structure in this exact format:
{
  "role": "the identified role",
  "questions": [
    {
      "question_number": 1,
      "question_text": "The question text here?",
      "choices": {
        "A": "First choice",
        "B": "Second choice",
        "C": "Third choice",
        "D": "Fourth choice"
      },
      "correct_answer": "A"
    }
  ]
}

RULES:
- Always use the search tool FIRST to get relevant context before generating questions
- Questions must be factual and based on the retrieved information from the knowledge base
- All 4 choices should be plausible and realistic, but only one should be correct
- The correct_answer must be one of: "A", "B", "C", or "D"
- Ensure questions test important, practical concepts relevant to the role
- Make questions educational and useful for the target audience
- Do not include any explanatory text outside the JSON structure
- The JSON must be valid and parseable
"""

agent = create_agent(
    llm,
    tools=tools,
    system_prompt=system_prompt,
)

def query_agent(question: str) -> dict:
    """
    Query the quiz generation agent with a role-based request.
    
    Args:
        question (str): The question or role-based request (e.g., "Generate quiz for farmer")
        
    Returns:
        dict: Response containing the answer and metadata
    """
    try:
        result = agent.invoke(
            {"messages": [{"role": "user", "content": question}]}
        )
        
        # Extract the final response
        messages = result.get("messages", [])
        if messages:
            final_message = messages[-1]
            raw_answer = final_message.content if hasattr(final_message, 'content') else str(final_message)
            
            # Sanitize and extract JSON from response
            try:
                parsed_json = sanitize_ai_response(raw_answer)
                answer = parsed_json  # Return parsed JSON object
            except ValueError as e:
                # If sanitization fails, return raw answer with error info
                answer = {
                    "error": "Failed to parse JSON",
                    "details": str(e),
                    "raw_response": raw_answer
                }
        else:
            answer = "No response generated"
        
        return {
            "success": True,
            "answer": answer,
            "full_response": result
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "answer": f"An error occurred: {str(e)}"
        }

def generate_quiz(role: str) -> str:
    """
    Simple interface to generate quiz questions for a specific role.
    
    Args:
        role (str): The user role (e.g., "farmer", "student")
        
    Returns:
        str: The agent's JSON response with quiz questions
    """
    question = f"Generate 5 quiz questions for a {role}"
    result = query_agent(question)
    return result

def chat(user_input: str) -> str:
    """
    General chat interface for the agent.
    
    Args:
        user_input (str): The user's input message
        
    Returns:
        str: The agent's response
    """
    result = query_agent(user_input)
    return result.get("answer", result.get("error", "Unknown error occurred"))

if __name__ == "__main__":
    import json
    
    # Test the agent with a sample query
    print("Testing quiz generation agent...\n")
    
    response = agent.invoke(
        {"messages": [HumanMessage("Generate quiz questions for a farmer")]}
    )
    
    # Extract and display raw content
    raw_content = response["messages"][-1].content
    print("Raw Response:")
    print("-" * 60)
    print(raw_content)
    print("-" * 60)
    
    # Sanitize and display JSON
    try:
        clean_json = sanitize_ai_response(raw_content)
        print("\nParsed JSON:")
        print("-" * 60)
        print(json.dumps(clean_json, indent=2))
        print("-" * 60)
    except ValueError as e:
        print(f"\nFailed to parse JSON: {e}")