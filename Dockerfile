FROM python:3.11-slim-trixie

# Python's system trust store is separate from the certifi bundle used by HTTPX.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && dpkg --compare-versions "$(dpkg-query -W -f='${Version}' ca-certificates)" ge '20250419+deb13u1' \
    && update-ca-certificates --fresh \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,id=s/0f50c76e-3b3e-4ac3-bc49-e4f716d8cc3f-/root/.cache/uv,target=/root/.cache/uv \
    uv sync --frozen --no-install-project

COPY README.md ./
COPY src/ ./src/

RUN --mount=type=cache,id=s/0f50c76e-3b3e-4ac3-bc49-e4f716d8cc3f-/root/.cache/uv,target=/root/.cache/uv \
    uv sync --frozen

ENV PATH="/app/.venv/bin:$PATH"

# Use the local stdio transport unless the operator explicitly configures secured HTTP.
CMD ["alpaca-mcp-server"]
