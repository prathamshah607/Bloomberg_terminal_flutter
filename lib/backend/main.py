from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import quotes, history, search, info, financials, advanced

app = FastAPI(title="StockSim Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(quotes.router, prefix="/api")
app.include_router(history.router, prefix="/api")
app.include_router(search.router, prefix="/api")
app.include_router(info.router, prefix="/api")
app.include_router(financials.router, prefix="/api/financials")
app.include_router(advanced.router, prefix="/api/advanced")

@app.get("/")
def read_root():
    return {"status": "Backend is running!"}
