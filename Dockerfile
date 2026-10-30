FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Render injects PORT at runtime
ENV PORT=8000

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Pre-download the fastembed ONNX model (~40MB) into the image so
# there is zero network call at runtime — eliminates cold-start RAM spike.
# fastembed uses ONNX runtime (no PyTorch), so RAM footprint stays low.
RUN python -c "\
from fastembed import TextEmbedding; \
list(TextEmbedding('BAAI/bge-small-en-v1.5').embed(['warmup']))"

COPY . .

EXPOSE 8000

# Single worker — keeps RSS within the 512MB free-tier limit
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --workers 1"]