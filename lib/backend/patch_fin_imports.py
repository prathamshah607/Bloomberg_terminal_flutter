with open("routes/financials.py", "r") as f:
    c = f.read()

# I patched the wrong import somehow, let's fix it
if "from utils import get_exchange_rate" not in c:
    c = "from utils import get_exchange_rate\n" + c
    with open("routes/financials.py", "w") as f:
        f.write(c)
