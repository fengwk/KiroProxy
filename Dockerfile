FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install uv for dependency management parity with local workflow.
RUN pip install --no-cache-dir uv

# Install runtime dependencies in a project-local virtualenv.
COPY requirements.txt ./requirements.txt
RUN uv venv --python 3.12 \
    && uv pip install --python .venv/bin/python --no-cache -r requirements.txt

# Copy application source.
COPY . .

CMD ["uv", "run", "run.py", "8080"]
