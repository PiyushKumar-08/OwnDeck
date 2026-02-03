# OwnDeck 🛡️

**A Zero-Cost Consumer Lifecycle Manager | The "Right to Repair" Advocate**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

---

## 📖 Overview

**OwnDeck** is a smart, privacy-focused mobile application designed to solve the chaos of managing product documentation. It acts as a centralized **Digital Vault** for your invoices, warranties, and insurance papers.

By leveraging **AI-powered OCR** and **Offline-First Architecture**, OwnDeck ensures you never miss a warranty claim, helps track product lifespans, and contributes to reducing global E-Waste.

> *"Bridging the gap between Purchase and Disposal."*

---

## ✨ Key Features

* **📸 AI Smart Scan:** Automatically extracts Model Name, Purchase Date, and Price from thermal receipts using Google ML Kit (OCR).
* **🔔 Smart Warranty Alerts:** Get notified 30 days and 7 days before your warranty expires.
* **🔒 Privacy-First Design:** Financial data is stored locally on your device using **Drift (SQLite)**. No sensitive data is sent to the cloud.
* **☁️ Secure Auth:** Hybrid architecture using **Firebase Authentication** for secure Google Sign-In.
* **🕵️ Lost & Found Mode:** Generate instant shareable "Report Cards" for lost items with Serial/IMEI numbers.
* **📉 E-Waste Reduction:** Encourages timely repairs over premature disposal.

---

## 🛠️ Tech Stack

This project follows a **Hybrid Architecture** combining the security of the cloud with the speed of local storage.

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Cross-platform UI (Android/iOS) |
| **Authentication** | Firebase Auth | Google Sign-In & Identity Verification |
| **Local Database** | Drift (SQLite) | Offline storage for Bills & Item Data |
| **AI/ML** | Google ML Kit | On-device Text Recognition (OCR) |
| **State Management**| Provider/BLoC | For managing app state efficiently |

---

## 🌍 Social Impact (SDGs)

OwnDeck is built in alignment with the **United Nations Sustainable Development Goals**:

* **SDG 12: Responsible Consumption:** By tracking warranties, we empower users to repair gadgets instead of throwing them away.
* **SDG 13: Climate Action:** Promoting a paperless ecosystem by digitizing non-recyclable thermal receipts.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK installed ([Guide](https://flutter.dev/docs/get-started/install))
* VS Code or Android Studio
* An Android Emulator or Physical Device

---

## 📞 Contact

**Developer:** Piyush Kumar
**Connect:** https://www.linkedin.com/in/piyush-kumar-40074a19a

---
*Developed as a Final Year Project for Dept. of Artificial Intelligence.*
