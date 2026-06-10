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

Use the ngrok public URL as the base URL and include the header `X-Api-Key: my-secret-key-123` on every request.

---

### List available models

```bash
curl https://xxxx.ngrok-free.app/api/tags \
  -H "X-Api-Key: my-secret-key-123"
```

---

### Chat completion

```bash
curl https://xxxx.ngrok-free.app/api/chat \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [
      {"role": "user", "content": "Hello, who are you?"}
    ]
  }'
```

Multi-turn conversation (pass the full message history):

```bash
curl https://xxxx.ngrok-free.app/api/chat \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [
      {"role": "user",      "content": "What is the capital of France?"},
      {"role": "assistant", "content": "The capital of France is Paris."},
      {"role": "user",      "content": "What is it famous for?"}
    ]
  }'
```

---

### Generate (raw completion)

```bash
curl https://xxxx.ngrok-free.app/api/generate \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "prompt": "Explain quantum computing in simple terms.",
    "stream": false
  }'
```

---

### Generate embeddings

```bash
curl https://xxxx.ngrok-free.app/api/embed \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nomic-embed-text",
    "input": "The quick brown fox jumps over the lazy dog"
  }'
```

---

### Pull a model

```bash
curl https://xxxx.ngrok-free.app/api/pull \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"model": "mistral"}'
```

---

### Delete a model

```bash
curl -X DELETE https://xxxx.ngrok-free.app/api/delete \
  -H "X-Api-Key: my-secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"model": "mistral"}'
```

---

### Python example

```python
import requests

BASE_URL = "https://xxxx.ngrok-free.app"
HEADERS = {
    "X-Api-Key": "my-secret-key-123",
    "Content-Type": "application/json",
}

response = requests.post(
    f"{BASE_URL}/api/chat",
    headers=HEADERS,
    json={
        "model": "llama3",
        "messages": [{"role": "user", "content": "Tell me a joke."}],
    },
)
print(response.json()["message"]["content"])
```

---

### JavaScript / fetch example

```js
const BASE_URL = "https://xxxx.ngrok-free.app";
const API_KEY = "my-secret-key-123";

const res = await fetch(`${BASE_URL}/api/chat`, {
  method: "POST",
  headers: {
    "X-Api-Key": API_KEY,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    model: "llama3",
    messages: [{ role: "user", content: "Tell me a joke." }],
  }),
});

const data = await res.json();
console.log(data.message.content);
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
