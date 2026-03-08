import json
import re

def sanitize_ai_response(raw_response: str) -> dict:
    """
    Sanitizes AI response by removing markdown formatting, extra whitespace,
    and parsing it into a valid JSON object.
    
    Args:
        raw_response: Raw text response from AI model
        
    Returns:
        Parsed JSON as a dictionary
        
    Raises:
        ValueError: If response cannot be parsed as valid JSON
    """
    # Remove markdown code block formatting (```json, ```, etc.)
    cleaned = re.sub(r'^```(?:json)?\s*', '', raw_response.strip())
    cleaned = re.sub(r'```\s*$', '', cleaned)
    
    # Remove any leading/trailing whitespace
    cleaned = cleaned.strip()
    
    # Remove any BOM or special characters at the start
    cleaned = cleaned.lstrip('\ufeff\ufffe')
    
    # Try to find JSON content if there's extra text before/after
    json_match = re.search(r'(\[.*\]|\{.*\})', cleaned, re.DOTALL)
    if json_match:
        cleaned = json_match.group(1)
    
    try:
        # Parse the JSON
        parsed_data = json.loads(cleaned)
        return parsed_data
    except json.JSONDecodeError as e:
        # If parsing fails, try to fix common issues
        # Replace single quotes with double quotes (if applicable)
        try:
            fixed = cleaned.replace("'", '"')
            parsed_data = json.loads(fixed)
            return parsed_data
        except:
            raise ValueError(f"Failed to parse AI response as JSON: {str(e)}\nResponse: {cleaned[:200]}...")
