from pydantic import BaseModel
from typing import Any

class GameplayRequest(BaseModel):
    role : str
    level : str
    total_coins : str

class GameplayResponse(BaseModel):
    status: str
    data: Any  # The sanitized game scenario JSON (list of nodes)
    message: str