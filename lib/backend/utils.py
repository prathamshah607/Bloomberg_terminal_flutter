import yfinance as yf
from functools import lru_cache
import pandas as pd
from datetime import datetime
import pytz

@lru_cache(maxsize=128)
def get_exchange_rate(from_curr: str, to_curr: str) -> float:
    if not from_curr or not to_curr or from_curr.upper() == to_curr.upper():
        return 1.0
    
    from_curr = from_curr.upper()
    to_curr = to_curr.upper()
    
    # Try fetching the pair
    pair = f"{from_curr}{to_curr}=X"
    try:
        ticker = yf.Ticker(pair)
        price = ticker.fast_info.last_price
        if price is not None and price > 0:
            return float(price)
    except Exception:
        pass
    
    # Fallback to inverse
    try:
        inv_pair = f"{to_curr}{from_curr}=X"
        inv_ticker = yf.Ticker(inv_pair)
        inv_price = inv_ticker.fast_info.last_price
        if inv_price is not None and inv_price > 0:
            return 1.0 / float(inv_price)
    except Exception:
        pass
    
    return 1.0

def convert_tz(dt, target_tz: str = "Asia/Kolkata"):
    if pd.isna(dt):
        return dt
    
    try:
        tz = pytz.timezone(target_tz)
    except pytz.UnknownTimeZoneError:
        tz = pytz.timezone("Asia/Kolkata")
        
    if isinstance(dt, pd.Timestamp):
        if dt.tz is None:
            dt = dt.tz_localize("UTC")
        return dt.tz_convert(tz)
    elif isinstance(dt, datetime):
        if dt.tzinfo is None:
            dt = pytz.utc.localize(dt)
        return dt.astimezone(tz)
    return dt

# Known monetary fields in yfinance info dictionary
MONETARY_FIELDS = {
    'previousClose', 'open', 'dayLow', 'dayHigh', 'regularMarketPreviousClose',
    'regularMarketOpen', 'regularMarketDayLow', 'regularMarketDayHigh',
    'fiftyTwoWeekLow', 'fiftyTwoWeekHigh', 'fiftyDayAverage', 'twoHundredDayAverage',
    'marketCap', 'enterpriseValue', 'totalRevenue', 'grossProfits', 'freeCashflow',
    'operatingCashflow', 'ebitda', 'totalDebt', 'totalCash', 'totalCashPerShare',
    'revenuePerShare', 'bookValue', 'priceToBook', 'targetLowPrice', 'targetHighPrice',
    'targetMeanPrice', 'targetMedianPrice', 'currentPrice'
}

def convert_info_dict(info: dict, rate: float, target_currency: str) -> dict:
    converted = info.copy()
    if rate == 1.0:
        return converted
    
    for key, val in converted.items():
        if key in MONETARY_FIELDS and isinstance(val, (int, float)):
            converted[key] = val * rate
            
    converted['currency'] = target_currency
    converted['financialCurrency'] = target_currency
    return converted
