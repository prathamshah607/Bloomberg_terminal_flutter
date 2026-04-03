from fastapi import APIRouter, HTTPException
import yfinance as yf
from utils import get_exchange_rate

router = APIRouter()

@router.get("/quote/{symbol}")
def get_quote(symbol: str, currency: str = "INR"):
    try:
        ticker = yf.Ticker(symbol)
        data = ticker.fast_info
        
        # Get base currency
        base_currency = ticker.fast_info.currency if hasattr(ticker.fast_info, 'currency') else "USD"
        
        rate = get_exchange_rate(base_currency, currency)
        
        return {
            "symbol": symbol.upper(),
            "price": (data.last_price * rate) if data.last_price else None,
            "previous_close": (data.previous_close * rate) if data.previous_close else None,
            "volume": data.last_volume,
            "market_cap": (data.market_cap * rate) if data.market_cap else None,
            "fifty_two_week_high": (data.year_high * rate) if data.year_high else None,
            "fifty_two_week_low": (data.year_low * rate) if data.year_low else None,
            "currency": currency.upper()
        }
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found or error: {str(e)}")
