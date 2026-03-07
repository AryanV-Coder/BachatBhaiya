from fastapi import APIRouter, HTTPException
from models.bachat_bhaiya_model import BachatBhaiya, BachatBhaiyaResponse
from utils.gemini import client
from google.genai import types
