from fastapi import APIRouter, HTTPException
import yfinance as yf
import pandas as pd
import math

router = APIRouter()

def safe_to_dict(df):
    if df is None or df.empty:
        return {}
    # Convert dates (columns/indices) to string, handle NaN
    if isinstance(df, pd.DataFrame):
        df.columns = [col.strftime('%Y-%m-%d') if hasattr(col, 'strftime') else str(col) for col in df.columns]
        df = df.fillna(0)
        return df.to_dict(orient="index")
    elif isinstance(df, pd.Series):
        df = df.fillna(0)
        return df.to_dict()
    return {}

@router.get("/statements/{symbol}")
def get_statements(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        return {
            "symbol": symbol.upper(),
            "income_stmt": safe_to_dict(ticker.income_stmt),
            "balance_sheet": safe_to_dict(ticker.balance_sheet),
            "cashflow": safe_to_dict(ticker.cashflow)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/options/{symbol}")
def get_options(symbol: str, date: str = None):
    try:
        ticker = yf.Ticker(symbol)
        expirations = ticker.options
        if not expirations:
            return {"symbol": symbol.upper(), "expirations": [], "calls": [], "puts": []}
            
        target_date = date if date in expirations else expirations[0]
        opt = ticker.option_chain(target_date)
        return {
            "symbol": symbol.upper(),
            "expirations": expirations,
            "target_date": target_date,
            "calls": safe_to_dict(opt.calls),
            "puts": safe_to_dict(opt.puts)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/holders/{symbol}")
def get_holders(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        
        insider = ticker.insider_transactions
        if insider is not None and not insider.empty:
            insider = insider.head(20).to_dict(orient="records")
        else:
            insider = []
            
        return {
            "symbol": symbol.upper(),
            "major_holders": safe_to_dict(ticker.major_holders),
            "institutional_holders": safe_to_dict(ticker.institutional_holders),
            "insider_transactions": insider
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/events/{symbol}")
def get_events(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        return {
            "symbol": symbol.upper(),
            "calendar": safe_to_dict(ticker.calendar),
            "earnings_dates": safe_to_dict(ticker.earnings_dates),
            "actions": safe_to_dict(ticker.actions)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/esg/{symbol}")
def get_esg(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        return {
            "symbol": symbol.upper(),
            "sustainability": safe_to_dict(ticker.sustainability)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analysts/{symbol}")
def get_analysts(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        upgrades = ticker.upgrades_downgrades
        if upgrades is not None and not upgrades.empty:
            upgrades = upgrades.head(20).to_dict(orient="records")
        else:
            upgrades = []
            
        recommendations = ticker.recommendations
        if recommendations is not None and not recommendations.empty:
            recommendations = recommendations.to_dict(orient="records")
        else:
            recommendations = []
            
        return {
            "symbol": symbol.upper(),
            "upgrades": upgrades,
            "recommendations": recommendations
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
