from fastapi import APIRouter, HTTPException
from models.quiz_model import QuizRequest, QuizResponse
from utils.rag.agent import generate_quiz

router = APIRouter()

@router.post("/quiz", response_model=QuizResponse)
async def quiz(body: QuizRequest):
    """
    Generate quiz questions based on user role.
    
    Args:
        request: QuizRequest containing the role (farmer, student, etc.)
        
    Returns:
        QuizResponse with generated quiz questions
    """
    try:
        # Generate quiz using the agent
        result = generate_quiz(body.role)
        
        # Check if generation was successful
        if not result.get("success", False):
            raise HTTPException(
                status_code=500,
                detail=f"Failed to generate quiz: {result.get('error', 'Unknown error')}"
            )
        
        answer = result.get("answer")
        
        # Check if answer contains error from sanitization
        if isinstance(answer, dict) and "error" in answer:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to parse quiz response: {answer.get('details', 'Unknown error')}"
            )
        
        return QuizResponse(
            status="success",
            data=answer,
            message=f"Successfully generated quiz questions for {body.role}"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An unexpected error occurred: {str(e)}"
        )
