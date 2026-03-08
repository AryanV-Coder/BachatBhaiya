from langchain_aws import ChatBedrock
from .config import bedrock_runtime

# Use cross-region inference profile for Llama model
llm = ChatBedrock(
    client=bedrock_runtime,
    model_id="us.meta.llama3-1-70b-instruct-v1:0",  # Cross-region inference profile
    model_kwargs={"temperature": 0}
)