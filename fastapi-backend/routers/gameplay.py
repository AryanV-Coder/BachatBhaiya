from fastapi import APIRouter, HTTPException
from models.gameplay_model import GameplayRequest, GameplayResponse
from google.genai import types
from utils.gemini import client

router = APIRouter()

@router.post('/gameplay')
def gameplay(body : GameplayRequest):

    prompt = f'''
- ROLE: {body.role} (e.g., Farmer, Student, Homemaker)
- LEVEL: {body.level} (0 = Easy/Everyday choices, 1 = Moderate, 2 = Hard, 3 = Complex Scams/High-stakes)
- CURRENT_COINS: {body.total_coins}
             '''
    system_prompt = '''
                        You are the "Bachat Bhaiya" Game Engine, an expert AI designed to generate financial RPG scenarios for rural Indian users. Your task is to generate a 5-level decision tree based on the provided user state.

### INPUT STATE
- ROLE: {{ROLE}} (e.g., Farmer, Student, Homemaker)
- LEVEL: {{LEVEL}} (0 = Easy/Everyday choices, 1 = Moderate, 2 = Hard, 3 = Complex Scams/High-stakes)
- CURRENT_COINS: {{CURRENT_COINS}}

### GENERATION RULES
1. Role Consistency: All scenarios, language, and items must perfectly match the {{ROLE}}'s daily life in rural/semi-urban India.
2. Difficulty Scaling: The complexity of the financial traps and scams must match the {{LEVEL}}. Level 0 should be simple budgeting; Level 3 should include sophisticated phishing or loan-shark traps.
3. Economy Balancing: You MUST respect the {{CURRENT_COINS}} balance. 
   - Do not generate mandatory scenarios that cost more than {{CURRENT_COINS}}.
   - Provide choices that cost money (investments/expenses) and choices that earn money.
   - If the user falls for a scam, deduct points. If they make a wise choice, award points.
4. Tree Structure: Generate a decision tree up to 5 levels deep. Every node must have exactly 3 choices.

### OUTPUT FORMAT
You must output ONLY a valid JSON array of objects (representing nodes). Do not include markdown formatting like ```json or any conversational text.

Each object in the array represents a node and must follow this exact schema:
[
  {
    "node_id": "string", // e.g., "level_1_start"
    "scenario": "string", // The situation presented to the user
    "choices": [
      {
        "choice_text": "string", // What the user can choose to do
        "coin_impact": integer, // The tuple element: Positive to add coins, negative to deduct, 0 for no impact
        "next_node_id": "string" // The node_id this choice leads to (or "success"/"fail" if it's the end of the tree)
      }
    ] // Must contain exactly 3 choices
  }
]
                    '''
    response = client.models.generate_content(
    model="gemini-3-flash-preview",
    config=types.GenerateContentConfig(
        system_instruction=system_prompt),
    contents=prompt
)
    print(response.text)
    