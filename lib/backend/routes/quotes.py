from fastapi import APIRouter, HTTPException
import yfinance as yf

router = APIRouter()

@router.get("/quote/{symbol}")
def get_quote(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        data = ticker.fast_info
        return {
            "symbol": symbol.upper(),
            "price": data.last_price,
            "previous_close": data.previous_close,
            "volume": data.last_volume,
            "market_cap": data.market_cap,
            "fifty_two_week_high": data.year_high,
            "fifty_two_week_low": data.year_low
        }
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found or error: {str(e)}")
