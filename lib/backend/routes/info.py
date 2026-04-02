from fastapi import APIRouter, HTTPException
import yfinance as yf
import pandas as pd

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
def get_info(symbol: str):
    """
    Returns the comprehensive dictionary of all stats, metrics, and details
    provided by yfinance for the requested asset.
    """
    try:
        ticker = yf.Ticker(symbol)
        info = ticker.info
        if not info or len(info.keys()) == 0:
            raise HTTPException(status_code=404, detail="No info found for symbol")
        return {"symbol": symbol.upper(), "info": info}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

# @router.get("/financials/{symbol}")
# def get_financials(symbol: str):
    """
    Returns income statement (P&L), balance sheet, and cashflow.
    These are typically only available for equities, not crypto/ETFs.
    """
    try:
        ticker = yf.Ticker(symbol)
        
        income = {}
        balance = {}
        cashflow = {}
        
        try:
            if hasattr(ticker, "income_stmt") and not ticker.income_stmt.empty:
                income = clean_financials(ticker.income_stmt)
        except Exception:
            pass
            
        try:
            if hasattr(ticker, "balance_sheet") and not ticker.balance_sheet.empty:
                balance = clean_financials(ticker.balance_sheet)
        except Exception:
            pass
            
        try:
            if hasattr(ticker, "cashflow") and not ticker.cashflow.empty:
                cashflow = clean_financials(ticker.cashflow)
        except Exception:
            pass

        return {
            "symbol": symbol.upper(),
            "income_statement": income,
            "balance_sheet": balance,
            "cash_flow": cashflow
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
