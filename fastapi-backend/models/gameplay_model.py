from pydantic import BaseModel

class GameplayRequest(BaseModel):
    role : str
    level : str
    total_coins : str

class GameplayResponse(BaseModel):
    pass