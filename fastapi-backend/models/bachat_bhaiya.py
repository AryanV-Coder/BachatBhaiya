from pydantic import BaseModel
from typing import Any

class BachatBhaiya(BaseModel):
    role : str
    previousLevel : str
    currentCoins : str
    previousLevelGraph : Any

class BachatBhaiyaResponse(BaseModel):
    status: str
    data: str  # The AI response as a parsed string
    message: str