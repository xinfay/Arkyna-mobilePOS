# Mobile POS Application

A lightweight, cross-platform Point of Sale (POS) system built with Flutter, designed for both desktop and mobile (Android). This app allows users to manage inventory, process payments, view analytics, and track transactions efficiently.

---

## 📦 Project Structure

```
mobile_pos_application/
├── backend/                # Node.js backend for handling payments
├── lib/                   # Flutter app code
│   ├── pages/             # App screen UIs
│   ├── models/            # Data models
│   ├── providers/         # State management with Provider
│   ├── widgets/           # Shared/custom UI components
│   └── app.dart           # Main Flutter app entry
├── pubspec.yaml           # Flutter dependencies
└── README.md              # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/)
- Git
- A Square Developer account for sandbox API keys

---

## 🛠️ Flutter Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/mobile_pos_application.git
   cd mobile_pos_application
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the Flutter app:

   ```bash
   flutter run -d windows   # or -d android
   ```

---

## 🖥️ Backend Setup

1. Navigate to the `backend/` directory:

   ```bash
   cd backend
   ```

2. Create a `.env` file in the backend directory with your **Square sandbox** credentials:

   ```
   SQUARE_ACCESS_TOKEN=your_square_sandbox_token
   SQUARE_LOCATION_ID=your_location_id
   ```

3. Install Node.js dependencies:

   ```bash
   npm install
   ```

4. Start the backend server:

   ```bash
   node index.js
   ```

The server will start on `http://localhost:3000`.

---

## 🧪 Debugging Tips

- Make sure you run `flutter pub get` if you see import or package errors.
- Ensure the backend server is running when testing payment integration.
- Check `.env` values are correctly set and match your Square developer dashboard.

---

## 📄 License

This project is licensed under the MIT License.
