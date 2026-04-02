from fastapi import APIRouter, HTTPException
import yfinance as yf

router = APIRouter()

@router.get("/history/{symbol}")
def get_history(symbol: str, period: str = "1mo", interval: str = "1d"):
    try:
        ticker = yf.Ticker(symbol)
        hist = ticker.history(period=period, interval=interval)
        if hist.empty:
            raise ValueError("No data found for given period/interval")
        
        hist.index = hist.index.strftime('%Y-%m-%d %H:%M:%S')
        records = []
        for date, row in hist.iterrows():
            records.append({
                "date": date,
                "open": row["Open"],
                "high": row["High"],
                "low": row["Low"],
                "close": row["Close"],
                "volume": row["Volume"]
            })
        return {"symbol": symbol.upper(), "data": records}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
