from fastapi import FastAPI, Request, HTTPException
import httpx

app = FastAPI()
API_KEY = "my-secret-key-123"

@app.api_route("/{path:path}", methods=["GET","POST","DELETE"])
async def proxy(path: str, request: Request):
    if request.headers.get("X-Api-Key") != API_KEY:
        raise HTTPException(status_code=401, detail="Unauthorized")
    
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method=request.method,
            url=f"http://localhost:11434/{path}",
            content=await request.body(),
            headers={"Content-Type": "application/json"}
        )
    return response.json()