import unittest
from app import app  # Import your Flask app

class BasicTests(unittest.TestCase):
    def setUp(self):
        # Set up test client
        self.app = app.test_client()
        self.app.testing = True

    def test_home_status_code(self):
        # Test that the home page loads successfully
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_crypto_endpoint(self):
        # Test that the crypto price endpoint responds successfully
        response = self.app.get('/crypto')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'bitcoin', response.data)
        self.assertIn(b'ethereum', response.data)

if __name__ == "__main__":
    unittest.main()