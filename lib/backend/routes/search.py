from fastapi import APIRouter
import yfinance as yf

router = APIRouter()

@router.get("/search")
def search_symbol(q: str):
    try:
        search = yf.Search(q, quotes_count=10)
        results = [{"symbol": quote.get("symbol", ""), "shortname": quote.get("shortname", ""), "quoteType": quote.get("quoteType", "")} for quote in search.quotes]
        return {
            "query": q,
            "results": results
        }
    except Exception as e:
        try:
             search = yf.Search(q)
             results = [{"symbol": quote.get("symbol", ""), "shortname": quote.get("shortname", ""), "quoteType": quote.get("quoteType", "")} for quote in search.quotes]
             return {"query": q, "results": results}
        except:
             pass
        print(f"Error in yfinance search: {e}")
        return {"query": q, "results": []}
