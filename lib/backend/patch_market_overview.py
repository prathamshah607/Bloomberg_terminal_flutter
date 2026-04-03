with open("../screens/home/widgets/market_overview.dart", "r") as f:
    c = f.read()

c = c.replace("_MiniChartGrid(symbols: ['EURUSD=X', 'GBPUSD=X', 'JPY=X', 'CAD=X', 'AUDUSD=X', 'EURGBP=X'])", "_MiniChartGrid(symbols: ['USDINR=X', 'EURINR=X', 'GBPINR=X', 'JPYINR=X', 'AUDINR=X', 'SGDINR=X'])")

with open("../screens/home/widgets/market_overview.dart", "w") as f:
    f.write(c)
