from fastapi import APIRouter, HTTPException
import yfinance as yf
import pandas as pd
from utils import get_exchange_rate, convert_info_dict

router = APIRouter()

def clean_financials(df: pd.DataFrame) -> dict:
    if df is None or df.empty:
        return {}
    # Convert dates (columns) to string
    df.columns = [col.strftime('%Y-%m-%d') if hasattr(col, 'strftime') else str(col) for col in df.columns]
    # Replace NaN with None
    df = df.fillna(0)
    # Convert to dict of dicts: { metric: { date: value } }
    return df.to_dict(orient="index")

@router.get("/info/{symbol}")
def get_info(symbol: str, currency: str = "INR"):
    """
    Returns the comprehensive dictionary of all stats, metrics, and details
    provided by yfinance for the requested asset.
    """
    try:
        ticker = yf.Ticker(symbol)
        info = ticker.info
        if not info or len(info.keys()) == 0:
            raise HTTPException(status_code=404, detail="No info found for symbol")
            
        base_currency = info.get('currency', 'USD')
        rate = get_exchange_rate(base_currency, currency)
        info = convert_info_dict(info, rate, currency)
        
        return {"symbol": symbol.upper(), "info": info}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
