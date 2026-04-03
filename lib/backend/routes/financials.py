from utils import get_exchange_rate
from fastapi import APIRouter, HTTPException, Query
import yfinance as yf
from datetime import datetime
from typing import Dict, Any
import numpy as np

router = APIRouter()

@router.get("/{symbol}")
async def get_financials(symbol: str, currency: str = "INR"):
    """
    Get financials (Income Statement) for a given symbol.
    Provides data to construct a Waterfall chart (Revenue -> Net Income).
    """
    try:
        ticker = yf.Ticker(symbol)
        
        base_currency = ticker.fast_info.currency if hasattr(ticker.fast_info, 'currency') else "USD"
        rate = get_exchange_rate(base_currency, currency)
        
        # Get yearly financials
        fin = ticker.financials
        
        if fin.empty:
             return {"symbol": symbol, "data": [], "currency": currency.upper()}
             
        # yfinance financials dataframe has dates as columns and metrics as index
        # We'll take the most recent period (column 0)
        recent_date = fin.columns[0]
        recent_data = fin[recent_date]
        
        # Extract necessary fields, fillna(0) just in case
        revenue = recent_data.get("Total Revenue", 0)
        cogs = recent_data.get("Cost Of Revenue", 0)
        gross_profit = recent_data.get("Gross Profit", 0)
        operating_expense = recent_data.get("Operating Expense", 0)
        operating_income = recent_data.get("Operating Income", 0)
        net_income = recent_data.get("Net Income", 0)
        
        # Calculate intermediate waterfall steps
        # Revenue -> (COGS) -> Gross Profit -> (Opex) -> Operating Income -> (Taxes/Interest) -> Net Income
        # We can just return the raw numbers and let the frontend do the waterfall math
        
        data = {
            "period": recent_date.strftime("%Y-%m-%d") if isinstance(recent_date, datetime) else str(recent_date),
            "revenue": (float(revenue) * rate) if revenue and not np.isnan(revenue) else 0.0,
            "cost_of_revenue": (float(cogs) * rate) if cogs and not np.isnan(cogs) else 0.0,
            "gross_profit": (float(gross_profit) * rate) if gross_profit and not np.isnan(gross_profit) else 0.0,
            "operating_expense": (float(operating_expense) * rate) if operating_expense and not np.isnan(operating_expense) else 0.0,
            "operating_income": (float(operating_income) * rate) if operating_income and not np.isnan(operating_income) else 0.0,
            "net_income": (float(net_income) * rate) if net_income and not np.isnan(net_income) else 0.0,
            "other_expenses": (float(operating_income - net_income) * rate) if (operating_income and not np.isnan(operating_income) and net_income and not np.isnan(net_income)) else 0.0
        }
        
        return {"symbol": symbol, "data": [data], "currency": currency.upper()}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
