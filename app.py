from flask import Flask, jsonify, render_template
import requests

app = Flask(__name__)

# Fetch prices from CoinGecko API
def fetch_crypto_prices():
    try:
        url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd"
        response = requests.get(url)
        data = response.json()

        bitcoin_price = data["bitcoin"]["usd"]
        ethereum_price = data["ethereum"]["usd"]

        return {
            "Bitcoin": {"price_usd": bitcoin_price},
            "Ethereum": {"price_usd": ethereum_price}
        }
    except Exception as e:
        return {"error": str(e)}

# Endpoint to fetch cryptocurrency prices
@app.route('/crypto-prices', methods=['GET'])
def get_crypto_prices():
    prices = fetch_crypto_prices()
    return jsonify(prices)

# Serve the HTML page
@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, port=8100)