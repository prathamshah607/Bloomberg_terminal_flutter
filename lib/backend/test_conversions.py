import requests

base = "http://127.0.0.1:8000/api"

print("Testing quote conversion...")
r = requests.get(f"{base}/quote/AAPL")
print(r.json())

print("\nTesting history conversion (timezones and prices)...")
r = requests.get(f"{base}/history/AAPL?period=1d&interval=1h")
data = r.json()
print("Currency:", data.get("currency"))
print("Timezone:", data.get("timezone"))
if data.get("data"):
    print("First record:", data["data"][0])

print("\nTesting info conversion...")
r = requests.get(f"{base}/info/AAPL")
if r.status_code == 200:
    info = r.json().get('info', {})
    print("Current Price (INR):", info.get("currentPrice"))
    print("Financial Currency:", info.get("financialCurrency"))
else:
    print("Failed info:", r.status_code)

print("\nTesting financials conversion...")
r = requests.get(f"{base}/financials/AAPL")
if r.status_code == 200:
    fin = r.json()
    print("Currency:", fin.get("currency"))
    if fin.get("income_statement"):
        first_date = list(fin["income_statement"].keys())[0]
        print("Sample Income Statement item (Total Revenue in INR):")
        print(fin["income_statement"][first_date].get("Total Revenue", "N/A"))
else:
    print("Failed fin:", r.status_code)

