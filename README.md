# Eunoia 🧠✨

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini%20AI-121011?style=for-the-badge&logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)

**Eunoia** is a premium, minimalist mental wellness tracking mobile application built using Flutter. It blends advanced generative AI diagnostics with bulletproof local sandbox tracking, allowing users to safely log daily metrics, analyze mental health trends, and consult a localized AI agent without risking data privacy leakages.

---

## 🚀 Key Architectural Pillars

### 🤖 1. Secure AI Analysis Engine
- Powered by the stable **Google Gemini 1.5 Flash** model for sub-second, multi-turn cognitive reflections.
- Built using an optimized compilation architecture: API credentials are fully protected using secure compile-time environment flags (`--dart-define`), keeping your transaction keys off the repository grid.

### 📊 2. High-Fidelity Mood Trends Dashboard
- Integrated a highly scalable **7-Day Daily Average Trend Line Chart** powered by `fl_chart`.
- Groups messy intra-day multiple logs dynamically into singular mathematical daily checkpoints.
- Employs zero-clutter horizontal layouts and custom visual axes using explicit descriptive metrics (*Great, Good, Neutral, Low, Very Low*) instead of generic raw integers.

### 🔒 3. Safe Deletion & Ironclad Cloud Sync
- Syncs seamlessly with a scalable **Google Cloud Firestore** and Firebase Auth backend.
- Embedded data-ownership guardrails: Custom Firestore security policies explicitly bound to `resource.data.uid` prevents unauthorized deletion or cross-tenant scripting vulnerabilities.

---

## 🛠️ Tech Stack & Dependencies

- **Frontend Framework:** Flutter (Dart)
- **Database & Auth:** Google Cloud Firestore / Firebase Authentication
- **AI Backend Engine:** Google Gemini Pro / Flash SDK
- **Data Visualization:** `fl_chart` for complex vector charts
- **Architecture Pattern:** Clean Three-Layer State Optimization Layout

---

## ⚙️ Local Installation & Compilation Guide

To set up a local development environment and test or compile the release APK without hitting GitHub security rule blocks, follow these steps:

### Prerequisite Setup
1. Clone the repository natively:
   ```bash
   git clone [https://github.com/HarshBhardwaj00/Eunoia.git](https://github.com/HarshBhardwaj00/Eunoia.git)
   cd Eunoia
