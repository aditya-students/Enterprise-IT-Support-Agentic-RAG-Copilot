# 🤖 Enterprise IT Support Agentic RAG Copilot

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.116-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![LangGraph](https://img.shields.io/badge/LangGraph-1.1-orange)](https://www.langchain.com/langgraph)
[![Pinecone](https://img.shields.io/badge/Pinecone-Vector%20DB-00B388?logo=pinecone)](https://www.pinecone.io/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> An **agentic, self-correcting RAG (Retrieval-Augmented Generation) copilot** for enterprise IT support — powered by LangGraph, Groq LLM, Pinecone vector search, and Tavily web search.

---

## 📌 Overview

The **Enterprise IT Support Agentic RAG Copilot** is a production-ready AI assistant that helps employees resolve IT issues by intelligently routing questions through a multi-step agentic workflow. It first searches the **company's private knowledge base** (policies, runbooks, handbooks), grades the evidence quality, and falls back to **live web search** when internal docs are insufficient — with automatic query rewriting for better retrieval.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🧠 **Agentic Reasoning** | LangGraph-powered stateful workflow with conditional routing and self-correction |
| 📚 **Private KB Search** | Pinecone vector store with HuggingFace sentence-transformer embeddings |
| 🌐 **Web Fallback** | Tavily web search when internal knowledge is insufficient |
| 🔁 **Query Rewriting** | Automatically rewrites poorly-retrieving queries and retries |
| ✅ **Evidence Grading** | LLM-based grading of KB and web evidence before generating answers |
| 📄 **Document Ingestion** | Upload PDF, DOCX, and Markdown files directly into the vector store |
| 🪵 **Audit Logging** | Every query, source used, and reasoning trace is persisted to SQLite |
| 🔒 **Admin Auth** | API-key-protected ingestion endpoint |
| 🖥️ **Chat UI** | Built-in web interface with citation display and reasoning trace |

---

## 🏗️ Architecture

```
User Question
      │
      ▼
┌─────────────────┐
│  Route Question │  ← LLM decides: "kb" or "direct"
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
Retrieve   Direct
  KB       Answer
    │
    ▼
Grade KB Evidence
    │
  ┌─┴─┐
  │   │
  ▼   ▼
Gen  Web
KB   Search
Ans    │
       ▼
   Grade Web Evidence
       │
     ┌─┴──────────────┐
     │                │
     ▼                ▼
 Gen Web Ans     Rewrite Query → (retry KB)
                      │
                      ▼ (max retries exceeded)
                 Insufficient Response
```

The workflow is built as a **LangGraph `StateGraph`** with full observability of each step via the `trace` field in every response.

---

## 🗂️ Project Structure

```
Enterprise IT Support Agentic RAG Copilot/
├── app/
│   ├── api/
│   │   └── routes.py           # FastAPI endpoints (/chat, /ingest, /health)
│   ├── core/
│   │   ├── config.py           # Pydantic settings (env-based config)
│   │   └── logging.py          # Structured logging setup
│   ├── rag/
│   │   ├── state.py            # LangGraph AgentState & structured output models
│   │   ├── vectorstore.py      # Pinecone retriever & document upserting
│   │   └── workflow.py         # Full LangGraph agentic workflow
│   ├── services/
│   │   ├── audit.py            # SQLite audit trail
│   │   └── ingestion.py        # PDF/DOCX/Markdown loader & chunker
│   └── main.py                 # FastAPI app entrypoint
├── data/
│   └── sample_kb/              # Sample knowledge base documents
│       ├── company_it_handbook.md
│       └── service_desk_runbook.md
├── static/
│   ├── css/style.css           # Chat UI styles
│   └── js/app.js               # Chat UI logic
├── templates/
│   └── index.html              # Jinja2 chat interface template
├── uploads/                    # Uploaded documents (gitignored)
├── Agentic_RAG.ipynb           # Jupyter notebook for experimentation
├── ingest_sample_kb.py         # Script to ingest sample KB into Pinecone
├── run.py                      # App launcher
├── requirements.txt
└── .env                        # Environment variables (not committed)
```

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/aditya-students/Enterprise-IT-Support-Agentic-RAG-Copilot.git
cd Enterprise-IT-Support-Agentic-RAG-Copilot
```

### 2. Create a Virtual Environment

```bash
python -m venv env
# Windows
env\Scripts\activate
# macOS/Linux
source env/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the project root (copy from the template below):

```env
# LLM — Groq
GROQ_API_KEY=your_groq_api_key_here
GROQ_MODEL=openai/gpt-oss-120b

# Web Search — Tavily
TAVILY_API_KEY=your_tavily_api_key_here

# Vector DB — Pinecone
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_INDEX_NAME=industry-agentic-rag-kb
PINECONE_NAMESPACE=langgraph-agentic-rag

# Embeddings
EMBEDDING_MODEL=all-MiniLM-L6-v2

# App Settings
APP_ENV=development
ADMIN_API_KEY=change-me-in-production
MAX_RETRIES=1
TOP_K=4
```

### 5. Ingest the Sample Knowledge Base

```bash
python ingest_sample_kb.py
```

This indexes the IT handbook and service desk runbook into your Pinecone vector store.

### 6. Run the Application

```bash
python run.py
```

The app starts at **http://localhost:8000** 🎉

---

## 🔑 API Reference

### `GET /api/health`
Health check endpoint.

```json
{ "status": "ok", "service": "Enterprise IT Support Agentic RAG Copilot" }
```

---

### `POST /api/chat`
Ask the IT copilot a question.

**Request:**
```json
{
  "question": "How do I reset my VPN password?"
}
```

**Response:**
```json
{
  "answer": "To reset your VPN password, follow these steps from the company IT handbook...",
  "source_used": "private_kb",
  "trace": [
    "Router → KB",
    "Private KB retrieval → 4 chunks",
    "KB evidence grade → GOOD",
    "Answer generation → PRIVATE KB"
  ],
  "citations": [
    { "title": "company_it_handbook.md", "url": "", "type": "private_kb" }
  ],
  "rewritten_query": "How do I reset my VPN password?"
}
```

**`source_used` values:**
| Value | Meaning |
|---|---|
| `private_kb` | Answer from internal company knowledge base |
| `web_search` | Answer from Tavily web search (KB was insufficient) |
| `direct` | Casual/greeting — no retrieval needed |
| `insufficient_evidence` | No reliable evidence found; user advised to contact helpdesk |

---

### `POST /api/ingest`
Upload a document (PDF, DOCX, or Markdown) to the knowledge base.

**Headers:** `X-Admin-Key: your_admin_api_key`

**Form Data:** `file=<your_document>`

**Response:**
```json
{
  "message": "Document indexed",
  "file": "policy_doc.pdf",
  "chunks": 42,
  "ids_created": 42
}
```

---

## 🧩 Tech Stack

| Layer | Technology |
|---|---|
| **Web Framework** | [FastAPI](https://fastapi.tiangolo.com/) + Uvicorn |
| **Agentic Workflow** | [LangGraph](https://www.langchain.com/langgraph) |
| **LLM** | [Groq](https://groq.com/) (configurable model) |
| **Embeddings** | [HuggingFace Sentence Transformers](https://www.sbert.net/) (`all-MiniLM-L6-v2`) |
| **Vector Store** | [Pinecone](https://www.pinecone.io/) |
| **Web Search** | [Tavily](https://tavily.com/) |
| **Document Parsing** | PyPDF, python-docx |
| **Audit Storage** | SQLite |
| **Observability** | LangSmith (optional) |
| **Frontend** | HTML + Vanilla CSS + JavaScript |

---

## 🔄 Agentic Workflow Detail

The workflow is a **stateful LangGraph graph** with 10 nodes:

| Node | Role |
|---|---|
| `route_question` | Classifies question as `kb` (needs retrieval) or `direct` (casual) |
| `retrieve_kb` | Fetches top-K relevant chunks from Pinecone |
| `grade_kb` | LLM judges if KB evidence is `good` or `weak` |
| `search_web` | Calls Tavily for live web results with citations |
| `grade_web` | LLM judges if web evidence is `good` or `weak` |
| `rewrite_query` | Rewrites the query with better technical keywords |
| `generate_from_kb` | Generates a grounded answer from private KB |
| `generate_from_web` | Generates an answer from web evidence (with disclaimer) |
| `direct_answer` | Responds naturally to greetings / casual chat |
| `insufficient` | Returns a graceful failure message |

---

## 📓 Jupyter Notebook

The `Agentic_RAG.ipynb` notebook is available for **interactive experimentation** — step through the workflow, inspect state at each node, and prototype new ideas without running the full server.

---

## 🛡️ Security Notes

- **Never commit your `.env` file.** It is excluded by `.gitignore`.
- Change the default `ADMIN_API_KEY=change-me` before deploying to production.
- The ingestion endpoint (`/api/ingest`) is protected by the admin API key.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push and open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License**.
