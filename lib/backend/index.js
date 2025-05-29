const express = require("express");
const { Client, Environment } = require("square");
const { v4: uuidv4 } = require("uuid");
require("dotenv").config();

const app = express();
const port = 3000;

app.use(express.json());

// Initialize Square client
const client = new Client({
  accessToken: process.env.SQUARE_ACCESS_TOKEN,
  environment: Environment.Sandbox,
});

// ✅ Redirect route for Square to return to your app
app.get("/payment-success-redirect", (req, res) => {
  // For browser use, this page will load after successful payment
  res.send(`
    <html>
      <head><title>Payment Complete</title></head>
      <body style="text-align:center; padding-top:50px;">
        <h1>✅ Payment Successful</h1>
        <p>You may now return to the app.</p>
        <script>
          // Optional: notify the Flutter desktop app via localStorage or websocket
          localStorage.setItem("payment_complete", "true");
        </script>
      </body>
    </html>
  `);
});

// Create a checkout session
app.post("/create-checkout", async (req, res) => {
  console.log("📦 Received checkout request");

  try {
    const { itemNames, amount } = req.body;

    if (!itemNames || !amount) {
      return res.status(400).json({ error: "Missing itemNames or amount" });
    }

    const { result } = await client.checkoutApi.createCheckout(
      process.env.SQUARE_LOCATION_ID,
      {
        idempotencyKey: uuidv4(),
        order: {
          order: {
            locationId: process.env.SQUARE_LOCATION_ID,
            lineItems: [
              {
                name: itemNames,
                quantity: "1",
                basePriceMoney: {
                  amount: amount,
                  currency: "CAD",
                },
              },
            ],
          },
        },
        askForShippingAddress: false,

        // Update this URL with your ngrok or hosted HTTPS endpoint
        // via running "ngrok http 3000" on your terminal
        redirectUrl: "https://e1c0-142-198-231-11.ngrok-free.app/payment-success-redirect",
      }
    );

    const checkoutUrl = result.checkout.checkoutPageUrl;
    console.log("✅ Checkout URL created:", checkoutUrl);
    res.json({ checkoutUrl });
  } catch (err) {
    console.error("❌ Failed to create checkout:", err);
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`✅ Server running on port ${port}`);
});