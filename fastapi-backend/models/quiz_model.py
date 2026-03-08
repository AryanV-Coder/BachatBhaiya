from pydantic import BaseModel
from typing import Any


class QuizRequest(BaseModel):
    role: str


class QuizResponse(BaseModel):
    status: str
    data: Any  # The quiz data as JSON
    message: str
