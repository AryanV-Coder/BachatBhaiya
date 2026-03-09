from fastapi import APIRouter, HTTPException
from models.gameplay_model import GameplayRequest, GameplayResponse
from utils.bedrock import generate_content
from utils.sanitizer import sanitize_ai_response
from google.genai import types
from utils.gemini import client

router = APIRouter()

@router.post('/gameplay', response_model=GameplayResponse)
def gameplay(body : GameplayRequest):

    prompt = f'''
                - ROLE: {body.role}
                - LEVEL: {body.level}
                - CURRENT_COINS: {body.total_coins}
             '''
    system_prompt = '''
                        You are the "Bachat Bhaiya" Game Engine, an expert AI designed to generate financial RPG scenarios for diverse Indian demographics. Your task is to generate a 5-level decision graph based on the provided user state.

                        ### INPUT STATE
                        - ROLE: {{ROLE}} (e.g., Farmer, Student, Homemaker)
                        - LEVEL: {{LEVEL}} (1 = Easy/Everyday choices, 2 = Moderate, 3 = Hard, 4 = Complex Scams/High-stakes, etc)
                        - CURRENT_COINS: {{CURRENT_COINS}}

                        ### GENERATION RULES
                        1. Role Consistency: All scenarios, language, and items must perfectly match the {{ROLE}}'s specific daily life and environment (e.g., agricultural settings for Farmers, college campuses or urban life for Students, and household management for Homemakers).
                        2. Difficulty Scaling: The complexity of the financial traps and scams must match the {{LEVEL}}. Level 1 should be simple budgeting; Level 4 should include sophisticated phishing or loan-shark traps.
                        3. Economy Balancing: You MUST respect the {{CURRENT_COINS}} balance. 
                          - Do not generate mandatory scenarios that cost more than {{CURRENT_COINS}}.
                          - Provide choices that cost money (investments/expenses) and choices that earn money.
                          - If the user falls for a scam, deduct coins. If they make a wise choice, award coins.
                          - Ensure that no sequence of choices across the 5 levels can deplete the user's coin balance to zero or below. There must always be at least one viable path that maintains a positive balance.
                        4. Graph Structure (DAG Strategy): 
                          - Generate a Directed Acyclic Graph (DAG) up to 5 levels deep. Every node must have exactly 3 choices. To optimize the structure and prevent exponential node growth, different choices from different nodes MUST frequently merge into shared subsequent nodes in the next level (e.g., a safe choice and a risky choice in Level 2 can both lead to the exact same Level 3 scenario, just leaving the user with a different coin balance). 
                          - Tree Termination: All paths must end exactly at Level 5. The `next_node_id` for all choices in the final leaf nodes MUST be strictly either "success" or "failure" (do not generate new scenarios for these terminal states).
                        5. Strict JSON Compliance: Ensure no duplicate JSON keys are generated within the same object.
                        6. The Winning Strategy: Determine the single best sequence of choices from Level 1 to Level 5 that maximizes the user's final coin balance. CRITICAL: You must output the human-readable choice text that the user needs to click. DO NOT output the `next_node_id` (e.g., do not output "l2_canteen_lunch" or "success"). If the best choice is "Buy a second-hand book", you must output that exact string.

                        ### OUTPUT FORMAT
                        You must output ONLY a valid JSON object (not an array). Do not include markdown formatting like ```json or any conversational text.

                        Follow this exact schema:
                        {
                          "nodes": [
                            {
                              "node_id": "string", // e.g., "level_1_start"
                              "scenario": "string", // The situation presented to the user
                              "choices": [
                                {
                                  "choice_text": "string", // What the user can choose to do
                                  "coin_impact": integer, // Positive to add coins, negative to deduct, 0 for no impact
                                  "next_node_id": "string" // The node_id this choice leads to (or "success"/"failure" if it's the end of the tree)
                                },
                                {
                                  "choice_text": "string",
                                  "coin_impact": integer,
                                  "next_node_id": "string"
                                },
                                {
                                  "choice_text": "string",
                                  "coin_impact": integer,
                                  "next_node_id": "string"
                                }
                              ] // Must contain exactly 3 choices
                            },
                            // ... (all other generated nodes go here) ...
                          ],
                          "optimal_path": [
                            "Exact text of the best choice from Level 1 (NOT the node_id)",
                            "Exact text of the best choice from Level 2 (NOT the node_id)",
                            "Exact text of the best choice from Level 3",
                            "Exact text of the best choice from Level 4",
                            "Exact text of the best choice from Level 5"
                          ]
                        }

                        IMPORTANT: The output must be a single JSON object with two keys: "nodes" (array of node objects) and "optimal_path" (array of choice text strings).
                    '''
    
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            config=types.GenerateContentConfig(
                system_instruction=system_prompt),
            contents=prompt
        )
        
        # Extract the raw text from the response
        raw_text = response.text
        
        # Sanitize and parse the AI response
        game_data = sanitize_ai_response(raw_text)
        
        # Return the sanitized JSON response
        return GameplayResponse(
            status="success",
            data=game_data,
            message="Game scenario generated successfully"
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to parse AI response: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generating gameplay: {str(e)}"
        )
