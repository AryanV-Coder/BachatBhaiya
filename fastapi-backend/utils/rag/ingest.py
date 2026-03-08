from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_aws import BedrockEmbeddings
from langchain_community.vectorstores import FAISS
import os

from .config import bedrock_runtime

def load_and_split(pdf_path):
    loader = PyPDFLoader(pdf_path)
    documents = loader.load()

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200
    )

    return splitter.split_documents(documents)


def get_embeddings():
    return BedrockEmbeddings(
        client=bedrock_runtime,
        model_id="amazon.titan-embed-text-v2:0"
    )


def ingest_pdf(pdf_path, index_name):

    docs = load_and_split(pdf_path)

    embeddings = get_embeddings()

    vector_store = FAISS.from_documents(
        documents=docs,
        embedding=embeddings
    )

    script_dir = os.path.dirname(os.path.abspath(__file__))

    os.makedirs(os.path.join(script_dir,"faiss_db"), exist_ok=True)

    vector_store.save_local(os.path.join(script_dir,f"faiss_db/{index_name}"))

    print(f"Ingested {len(docs)} chunks into {index_name}")


if __name__ == "__main__":
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    ingest_pdf(os.path.join(script_dir, "data/RBI_FarmersGuidelines.pdf"), "farmers")
    ingest_pdf(os.path.join(script_dir, "data/RBI_StudentsGuidelines.pdf"), "students")