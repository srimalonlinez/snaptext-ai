# 📱 SnapText AI

**SnapText AI** is a **SaaS Flutter application** that uses **AI/ML** to extract text from images (OCR – Optical Character Recognition). It features **Stripe integration** for premium subscriptions and uses **Firebase** for authentication, storage, and data management. The app is designed to deliver a seamless and responsive experience on both Android and iOS platforms.

---

## ✨ Key Features

- 🧠 **AI/ML OCR** using Google ML Kit to extract text from images
- 🔒 **Anonymous Authentication** via Firebase
- ☁️ **Cloud Storage** and Firestore support
- 💳 **Stripe Payment Integration** for subscription handling
- 🧾 Subscription-based service model
- 🪝 **Provider State Management**
- 📱 **Responsive UI** for mobile
- ⚙️ Platform support: **Android & iOS**

---

## 🧰 Tech Stack

| Feature                | Technology        |
|------------------------|------------------|
| Frontend               | Flutter & Dart    |
| State Management       | Provider          |
| Authentication         | Firebase Auth     |
| Database               | Firebase Firestore|
| File Storage           | Firebase Storage  |
| Payments               | Stripe SDK        |
| OCR                    | Google ML Kit     |

---

## 🚀 Getting Started

### 1. Clone the Project

```bash
git clone https://github.com/srimalonlinez/snaptext-ai.git
cd snaptext-ai

### 2. Install Dependencies

flutter pub get

### 3. Firebase Configuration

Add Firebase project

Enable Anonymous Auth

Setup Firestore & Firebase Storage

Add google-services.json (Android) and GoogleService-Info.plist (iOS)

### 4. Stripe Integration

Create Stripe account & plans

Configure test keys

Use Cloud Functions or external backend to validate subscriptions securely

Integrate Stripe Flutter SDK


🧠 OCR Process (Google ML Kit)
Image Preprocessing (grayscale, denoising, etc.)
Text detection using deep learning
Word segmentation
Text recognition (CNN/RNN models)
Post-processing for formatting and corrections

💼 Subscription Model

| Plan    | Features                                  |
| ------- | ----------------------------------------- |
| Free    | Limited text extractions per month        |
| Premium | Unlimited text extractions + future tools |

Stripe handles recurring billing
Premium access is stored in Firestore
User state managed with Provider

🖼 UI Structure

Bottom Navigation Bar
Home Screen – Overview & Start Scanning
Text Extraction Screen – Upload and extract
Subscription Screen – Upgrade to Premium

