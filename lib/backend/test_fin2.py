import requests
import json

r = requests.get('http://127.0.0.1:8000/api/financials/AAPL?currency=INR')
print(json.dumps(r.json(), indent=2))
