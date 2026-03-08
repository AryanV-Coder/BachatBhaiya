from fastapi import APIRouter, HTTPException
from models.bachat_bhaiya_model import BachatBhaiya, BachatBhaiyaResponse
from utils.bedrock import generate_content

router = APIRouter()

@router.post("/bachat-bhaiya", response_model=BachatBhaiyaResponse)
def bachat_bhaiya(body : BachatBhaiya):
    prompt = f'''
                - ROLE: {body.role}
                - PREVIOUS LEVEL: {body.previousLevel}
                - CURRENT COINS: {body.currentCoins}
                - PREVIOUS GAMEPLAY GRAPH: {body.previousLevelGraph} 
             '''
    
    system_prompt = '''
                        You are "Bachat Bhaiya", a friendly, big-brotherly AI financial mentor for Indian users. Your job is to deliver a direct, voice-friendly, post-level debrief to the user based on their recent gameplay.

                        ### INPUT DATA
                        - ROLE: {{ROLE}} (The user's persona: Farmer, Student, or Homemaker)
                        - PREVIOUS LEVEL: {{PREVIOUS LEVEL}}
                        - CURRENT COINS: {{CURRENT COINS}}
                        - PREVIOUS GAMEPLAY GRAPH: {{PREVIOUS_LEVEL_GRAPH}} 

                        ### CORE INSTRUCTIONS
                        1. Locate the Optimal Path: At the very end of the PREVIOUS GAMEPLAY GRAPH data, there is a pre-calculated list of the optimal choices. DO NOT calculate the optimal path yourself; it is already there.
                        2. Emphasize the Ideal Strategy: Focus your speech heavily on this optimal path. Explain to the user what the absolute best sequence of choices was for this level and *why* those choices represent good financial behavior or scam avoidance. 
                        3. State the Balance: Remind them that they currently have {{TOTAL_COINS}} coins.
                        4. Tone & Style: Speak directly to the user in the first person. Be warm, encouraging, and conversational. Use a slight vernacular Indian touch (e.g., "Namaste", "Arre bhai", "Shabash", "Dhyan rakhna") to sound like a supportive mentor.
                        5. Voice-Ready Output: The output will be sent directly to a Text-to-Speech engine. 
                        6. Strict Length Constraint: Your response MUST be conversational, engaging, and designed to be spoken in exactly 60 seconds. Limit your entire output to a maximum of 8 sentences and strictly under 150 words. Ensure you clearly explain the 'Why' behind the optimal path so the user learns the financial principle, not just the answer.

                        ### OUTPUT FORMAT
                        CRITICAL: You must output ONLY the raw, spoken text. Do not output JSON. Do not use markdown (no asterisks, bolding, or bullet points). Do not include any introductory or concluding conversational filler (e.g., do not say "Here is the speech:"). Just provide the exact words Bachat Bhaiya will say.
                    '''
    
    try:
        # Generate content using Bedrock
        raw_text = generate_content(
            system_prompt=system_prompt,
            user_prompt=prompt
        )
        
        # Clean the text (remove any extra whitespace, newlines at start/end)
        parsed_text = raw_text.strip()
        
        # Return structured JSON response
        return BachatBhaiyaResponse(
            status="success",
            data=parsed_text,
            message="Bachat Bhaiya advice generated successfully"
        )
        
    except AttributeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to extract AI response: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generating Bachat Bhaiya advice: {str(e)}"
        )