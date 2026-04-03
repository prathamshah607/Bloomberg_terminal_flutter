import os 
from pathlib import Path
routes_dir = Path("routes")

# Patch history.py
history_py = """from fastapi import APIRouter, HTTPException
import yfinance as yf
from utils import get_exchange_rate, convert_tz

router = APIRouter()

@router.get("/history/{symbol}")
def get_history(symbol: str, period: str = "1mo", interval: str = "1d", currency: str = "INR", timezone: str = "Asia/Kolkata"):
    try:
        ticker = yf.Ticker(symbol)
        hist = ticker.history(period=period, interval=interval)
        if hist.empty:
            raise ValueError("No data found for given period/interval")
        
        base_currency = ticker.fast_info.currency if hasattr(ticker.fast_info, 'currency') else "USD"
        rate = get_exchange_rate(base_currency, currency)
        
        # Convert timezone and format
        if hist.index.tz is None:
            hist.index = hist.index.tz_localize('UTC')
        hist.index = hist.index.tz_convert(timezone).strftime('%Y-%m-%d %H:%M:%S')
        
        records = []
        for date, row in hist.iterrows():
            records.append({
                "date": date,
                "open": row["Open"] * rate,
                "high": row["High"] * rate,
                "low": row["Low"] * rate,
                "close": row["Close"] * rate,
                "volume": row["Volume"]
            })
        return {"symbol": symbol.upper(), "data": records, "currency": currency.upper(), "timezone": timezone}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
"""
with open(routes_dir / "history.py", "w") as f: f.write(history_py)
