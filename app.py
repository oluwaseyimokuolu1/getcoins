import os
import sqlite3
import requests
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

# Initialize Flask app
app = Flask(__name__)

# Database path
DATABASE_PATH = os.path.join(os.path.dirname(__file__), 'crypto_prices.db')

# Initialize Prometheus metrics
metrics = PrometheusMetrics(app)

# Function to initialize the database
def init_db():
    # Create the database if it doesn't exist
    if not os.path.exists(DATABASE_PATH):
        print(f"Database file {DATABASE_PATH} does not exist. Creating new one.")
    
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()

    # Create table if not exists
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS price_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT NOT NULL,
            price REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

# Function to save price history to the database
def save_price(symbol, price):
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO price_history (symbol, price) VALUES (?, ?)
    ''', (symbol, price))
    conn.commit()
    conn.close()

# Function to fetch crypto prices
def fetch_crypto_price(symbol):
    url = f'https://api.coingecko.com/api/v3/simple/price?ids={symbol}&vs_currencies=usd'
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return data[symbol]['usd']
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {symbol} price: {e}")
        return None

# Route to get current price of Bitcoin
@app.route('/price/bitcoin', methods=['GET'])
@metrics.counter('bitcoin_price_requests', 'Total number of requests for Bitcoin price')
def get_bitcoin_price():
    price = fetch_crypto_price('bitcoin')
    if price is not None:
        save_price('bitcoin', price)
        return jsonify({'symbol': 'bitcoin', 'price': price})
    return jsonify({'error': 'Unable to fetch Bitcoin price'}), 500

# Route to get current price of Ethereum
@app.route('/price/ethereum', methods=['GET'])
@metrics.counter('ethereum_price_requests', 'Total number of requests for Ethereum price')
def get_ethereum_price():
    price = fetch_crypto_price('ethereum')
    if price is not None:
        save_price('ethereum', price)
        return jsonify({'symbol': 'ethereum', 'price': price})
    return jsonify({'error': 'Unable to fetch Ethereum price'}), 500

# Route to get price history for a specific symbol
@app.route('/history/<symbol>', methods=['GET'])
@metrics.counter('price_history_requests', 'Total number of requests for price history')
def get_price_history(symbol):
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        SELECT symbol, price, timestamp FROM price_history WHERE symbol = ? ORDER BY timestamp DESC LIMIT 10
    ''', (symbol,))
    history = cursor.fetchall()
    conn.close()
    
    if history:
        return jsonify([{'symbol': row[0], 'price': row[1], 'timestamp': row[2]} for row in history])
    return jsonify({'error': f'No price history found for {symbol}'}), 404

# Initialize the database
init_db()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8100)