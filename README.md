# ⚡ EV Charging Station Network System (Ongoing)

> An Electric Vehicle (EV) Charging Network platform modeled with Object-Oriented Design (OOD) principles and modern design patterns, featuring IoT-enabled real-time monitoring, a comprehensive reservation system, and a smart payment infrastructure.

![Status: Work in Progress](https://imgshields.io/badge/Status-Work_in_Progress-orange)
![Architecture: OOD](https://imgshields.io/badge/Architecture-Object_Oriented_Design-blue)

## 📌 Project Overview
This project aims to build a robust, scalable backend architecture for an Electric Vehicle (EV) charging network. Currently in the **System Design and Architecture phase**, the project focuses on establishing a solid foundation using UML modeling before moving into implementation. 

The system manages interactions between EV Owners, System Administrators, and IoT Sensors located at the charging stations.

## 🏗️ System Architecture & Design Patterns
The system is heavily modeled around core OOP principles and utilizes several software design patterns to ensure scalability and maintainability:
*   **State Pattern:** Used to manage the dynamic states of charging sockets (`AVAILABLE`, `OCCUPIED`, `RESERVED`, `FAULTY`) without complex conditional logic.
*   **Strategy Pattern:** Implemented in the payment module (`IPaymentStrategy`) to seamlessly swap between different payment methods (Credit Card, Wallet, etc.).
*   **Observer Pattern:** Utilized for real-time IoT sensor communication, notifying the system and users instantly about vehicle detection, charging progress, or anomalies.

---

## 📊 UML Models & Diagrams

*Note: The original `.vpp` (Visual Paradigm) source files are located in the `/vp-source` directory.*

### 1. System Class Diagram
The core domain model illustrating the entities, relationships (composition, aggregation, inheritance), and design pattern implementations.

![Class Diagram](images/Class-Diagram.jpg) 

### 2. Use Case Diagram
High-level interactions between the actors (User, Admin, IoT Sensors, Database, Payment System) and the core functionalities of the platform.

![Use Case Diagram](images/EV-Charge-Station-Network-UseCase.jpg)

### 3. Activity Diagrams
Detailed workflows of critical system processes.

**User Setup & Authentication:**
*   **System Login/Register:** ![Sisteme Kayıt](images/sisteme_kayit_giris.jpg)
*   **Add Vehicle Plate:** ![Araç Plaka Gir](images/arac_plaka_gir.jpg)

**Station Search & Booking:**
*   **Map & Station Search:** ![İstasyon Ara](images/istasyon_ara_harita_goruntule.jpg)
*   **Create Reservation:** ![Rezervasyon Oluştur](images/rezervasyon_olustur.jpg)

**Charging & Payment Processes:**
*   **Start/Stop Charging:** ![Şarj Başlat/Durdur](images/sarj_baslat_durdur.jpg)
*   **Monitor Charge Status:** ![Şarj Durumu İzle](images/sarj_durumu_izle.jpg)
*   **Process Payment:** ![Ödeme Yap](images/odeme_yap.jpg)

**System & IoT Management:**
*   **Check Occupancy (IoT):** ![İşgal Durumu Kontrol Et](images/isgal_durumu_kontrol_et.jpg)
*   **Monitor Station Status:** ![İstasyon Durumu İzle](images/istasyon_durumu_izle.jpg)
*   **Manage Stations (Admin):** ![İstasyon Durumu Yönet](images/istasyon_durumu_yonet.jpg)

---

## 🗂️ Repository Structure

```text
├── images/                 # Exported JPG diagrams for quick viewing
│   ├── Class-Diagram.jpg
│   ├── EV-Charge-Station-Network-UseCase.jpg
│   └── (Activity Diagram JPGs...)
├── vp-source/              # Original .vpp Visual Paradigm source files
└── README.md
```
## 🚀 Upcoming Implementation Phases
[x] Requirement Gathering & Use Case Analysis

[x] UML Modeling & System Architecture Design (Current Phase)

[ ] Database Schema (ERD) Design

[ ] Backend API Development

[ ] IoT Sensor Data Simulation
