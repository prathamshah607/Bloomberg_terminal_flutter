import re

with open("routes/financials.py", "r") as f:
    c = f.read()

# The script I wrote earlier duplicated some things incorrectly because of bad replaces. I'll just rewrite the apply_rate loop
c = c.replace('''"revenue": float(revenue) if revenue else 0.0,
            "cost_of_revenue": float(cogs) if cogs else 0.0,
            "gross_profit": float(gross_profit) if gross_profit else 0.0,
            "operating_expense": float(operating_expense) if operating_expense else 0.0,
            "operating_income": float(operating_income) if operating_income else 0.0,
            "net_income": float(net_income) if net_income else 0.0,
            "other_expenses": float(operating_income - net_income) if (operating_income and net_income) else 0.0''',
'''"revenue": (float(revenue) * rate) if revenue else 0.0,
            "cost_of_revenue": (float(cogs) * rate) if cogs else 0.0,
            "gross_profit": (float(gross_profit) * rate) if gross_profit else 0.0,
            "operating_expense": (float(operating_expense) * rate) if operating_expense else 0.0,
            "operating_income": (float(operating_income) * rate) if operating_income else 0.0,
            "net_income": (float(net_income) * rate) if net_income else 0.0,
            "other_expenses": (float(operating_income - net_income) * rate) if (operating_income and net_income) else 0.0''')

c = c.replace('return {"symbol": symbol, "data": [data]}', 'return {"symbol": symbol, "data": [data], "currency": currency.upper()}')

with open("routes/financials.py", "w") as f:
    f.write(c)

