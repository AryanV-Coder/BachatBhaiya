from langchain_aws import ChatBedrock
import boto3
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Bedrock client
bedrock_runtime = boto3.client(
    service_name="bedrock-runtime",
    region_name=os.getenv("AWS_DEFAULT_REGION", "us-east-1"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)

# Initialize ChatBedrock with Llama model
llm = ChatBedrock(
    client=bedrock_runtime,
    model_id="us.meta.llama3-1-70b-instruct-v1:0",  # Cross-region inference profile
    model_kwargs={"temperature": 0.3}
)


def generate_content(system_prompt: str, user_prompt: str) -> str:
    """
    Generate content using AWS Bedrock with system and user prompts.
    
    Args:
        system_prompt: The system instruction/context
        user_prompt: The user's input/query
        
    Returns:
        Generated text response as string
    """
    from langchain_core.messages import HumanMessage, SystemMessage
    
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=user_prompt)
    ]
    
    response = llm.invoke(messages)
    return response.content
