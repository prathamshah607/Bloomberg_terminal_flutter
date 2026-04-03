import os 
from pathlib import Path
routes_dir = Path("routes")

# Patch info.py
with open(routes_dir / "info.py", "r") as f:
    info_py = f.read()

info_py = info_py.replace("import pandas as pd", "import pandas as pd\nfrom utils import get_exchange_rate, convert_info_dict")
info_py = info_py.replace('def get_info(symbol: str):', 'def get_info(symbol: str, currency: str = "INR"):')
info_py = info_py.replace('        info = ticker.info', '''        info = ticker.info\n        base_currency = info.get('currency', 'USD')\n        rate = get_exchange_rate(base_currency, currency)\n        info = convert_info_dict(info, rate, currency)''')

with open(routes_dir / "info.py", "w") as f: f.write(info_py)

# Patch financials.py
with open(routes_dir / "financials.py", "r") as f:
    fin_py = f.read()
    
fin_py = fin_py.replace("import pandas as pd", "import pandas as pd\nfrom utils import get_exchange_rate")
fin_py = fin_py.replace('def get_financials(symbol: str):', 'def get_financials(symbol: str, currency: str = "INR"):')

to_insert_fin = '''        ticker = yf.Ticker(symbol)
        
        base_currency = ticker.fast_info.currency if hasattr(ticker.fast_info, 'currency') else "USD"
        rate = get_exchange_rate(base_currency, currency)
        
        def apply_rate(data_dict):
            for m in data_dict:
                for d in data_dict[m]:
                    if isinstance(data_dict[m][d], (int, float)):
                        data_dict[m][d] *= rate
            return data_dict
'''
fin_py = fin_py.replace('        ticker = yf.Ticker(symbol)', to_insert_fin)
fin_py = fin_py.replace('income = clean_financials(ticker.income_stmt)', 'income = apply_rate(clean_financials(ticker.income_stmt))')
fin_py = fin_py.replace('balance = clean_financials(ticker.balance_sheet)', 'balance = apply_rate(clean_financials(ticker.balance_sheet))')
fin_py = fin_py.replace('cashflow = clean_financials(ticker.cashflow)', 'cashflow = apply_rate(clean_financials(ticker.cashflow))')

fin_py = fin_py.replace('"cash_flow": cashflow', '"cash_flow": cashflow,\n            "currency": currency.upper()')

with open(routes_dir / "financials.py", "w") as f: f.write(fin_py)

