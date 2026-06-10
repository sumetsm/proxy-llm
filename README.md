# proxy-llm

A lightweight API proxy that exposes a local [Ollama](https://ollama.com/) instance to the internet via [ngrok](https://ngrok.com/), protected by an API key.

## How it works

```
Internet
   │
   ▼
ngrok (public HTTPS URL)
   │
   ▼
FastAPI proxy (localhost:8000)  ← checks X-Api-Key header
   │
   ▼
Ollama (localhost:11434)
```

Requests must include the header `X-Api-Key: my-secret-key-123` or they are rejected with `401 Unauthorized`.

## Requirements

- Python 3.8+
- [Ollama](https://ollama.com/) installed and at least one model pulled
- [ngrok](https://ngrok.com/) installed and authenticated
- Python packages: `fastapi`, `uvicorn`, `httpx`

Install dependencies:

```bash
pip install fastapi uvicorn httpx
```

## Usage

### Start all services

Double-click **`start-llm.bat`** or run it from the terminal. It will:

1. Kill any existing Ollama, ngrok, and proxy processes
2. Start Ollama (`ollama serve`)
3. Start the FastAPI proxy on port `8000`
4. Start an ngrok tunnel on port `8000`

Check the ngrok window for the public URL (e.g. `https://xxxx.ngrok-free.app`).

### Stop all services

Double-click **`stop-llm.bat`** to cleanly shut down Ollama, ngrok, and the proxy.

## Making requests

Use the ngrok public URL as the base URL and add the API key header.

**Example — list local models:**

```bash
curl https://xxxx.ngrok-free.app/api/tags \
  -H "X-Api-Key: my-secret-key-123"
```

**Example — chat completion:**

```bash
curl https://xxxx.ngrok-free.app/api/chat \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## Configuration

| Item | Location | Default |
|------|----------|---------|
| API key | `proxy.py` line 5 | `my-secret-key-123` |
| Proxy port | `start-llm.bat` / `proxy.py` | `8000` |
| Ollama host | `start-llm.bat` | `0.0.0.0:11434` |

To change the API key, update `API_KEY` in `proxy.py` and restart.

## Security notes

- The API key is hardcoded in `proxy.py`. Do not commit a real secret to a public repo — consider loading it from an environment variable instead.
- ngrok exposes your machine to the internet. Stop the tunnel when not in use (`stop-llm.bat`).
