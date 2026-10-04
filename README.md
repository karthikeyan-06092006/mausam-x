# 🌤️ Mausam-X: Personalized Meteorological & Activity Feasibility App
### **Ministry of Earth Sciences (MoES) • India Meteorological Department (IMD)**
**Problem Statement ID:** 26076  
**Problem Statement Title:** Development of personalized homepage for 'Mausam' mobile application  
**Category / Theme:** Software / Smart Automation  

---

## 📌 Executive Summary

**Mausam-X** is an intelligent, persona-driven meteorological application built with **Flutter** and **100% Real-Time Live Atmospheric APIs**. It transforms traditional raw weather numbers into **actionable intelligence** through two core capabilities:

1. **Meteorological Calculation Engine:** Standardized computation of Thermal Comfort (Humidex / Heat Index), Air Quality Index (AQI Breakdown with $PM_{2.5}, PM_{10}, NO_2, O_3$), Road Visibility / Fog Index, and Soil Moisture / Agromet metrics.
2. **Personalized Activity Feasibility Engine (Step 2 Core):** Dynamic calculation of activity suitability (Bike Ride, Running, Beach Outing, Commute, Farming, Outdoor Events, Drone Flying) that answers:
   * *"Is it safe to do this activity at my selected date and time?"* (Scores 0–100 with clear verdict & reasons).
   * *"What is the best time slot today for this activity?"* (Automated scanning of 24h forecast window).

---

## 🚀 Key Features & Personas Supported

| Persona / User Segment | Live Data Points Calculated | Smart Advisory & Feature |
| :--- | :--- | :--- |
| **🚴 Bike Riders & Cyclists** | Rain %, Wind Gusts, AQI, Road Visibility | Road traction rating, fog hazard warning, optimal ride window |
| **🏃 Outdoor Fitness** | Best running hours, UV Index, Heat Stress, Wind | Coolest daylight window with lowest particulate pollution |
| **❤️ Health-Conscious** | National AQI, $PM_{2.5}, PM_{10}$, Pollen counts | Respiratory advisory, N95 mask recommendation |
| **🌊 Beachgoers & Surfers** | Wave height, Swell, Wave period, Sea Surface Temp | Coastal safety flags (Green / Yellow / Orange / Red) |
| **🚗 Commuters** | Horizontal visibility (meters), Fog alerts, Wet road | Dense fog warnings, safe braking distance advisories |
| **🌾 Agriculture & Kisan** | Soil moisture (0-7cm & 7-28cm), ET₀, Frost risk | Smart irrigation window & chemical spray drift alerts |
| **✈️ Travelers** | Multi-city forecasts, severe weather alerts | Dynamic packing suggestions (umbrella, warm wear, sunscreen) |
| **👨‍👩‍👧 Parents & Families** | School morning drop-off & pickup forecasts | Rain gear alerts and kids outdoor play UV advisory |
| **🎉 Event Planners** | 7-day rain probability, Outdoor Comfort Index | Humidex comfort score for outdoor tents & gatherings |
| **🚨 Emergency Override** | Severe thunderstorms, heatwaves, heavy downpours | High-priority IMD banner with safety instructions |

---

## 🧮 How The Calculation Engines Work

### 1. Thermal Comfort & Heat Index ($HI$)
Calculated from Dry Bulb Temperature ($T$) and Relative Humidity ($RH$) using the Rothfusz equation:
$$\text{Heat Index} = f(T, RH)$$

### 2. Air Quality Index (AQI) Breakpoint Calculation
Uses standard breakpoint equations across particulate matters:
$$I_p = \frac{I_{hi} - I_{lo}}{BP_{hi} - BP_{lo}} \times (C_p - BP_{lo}) + I_{lo}$$

### 3. Multi-Criteria Activity Suitability Score ($S_{activity}$)
Each hour is scored from $0 \text{ to } 100$:
$$S = 100 - \sum (\text{Penalties for Rain, AQI, Low Visibility, Excessive Wind, Extreme Heat, High UV})$$
* **$\ge 80$:** 🟢 **Ideal Conditions** (Highly Recommended)
* **$60 - 79$:** 🔵 **Good Conditions** (Recommended)
* **$40 - 59$:** 🟡 **Caution Advised** (Moderate Risk)
* **$< 40$:** 🔴 **Not Recommended** (Hazardous / Poor)

---

## 🏛️ System Architecture & Technology Stack

- **Client Application:** Flutter Framework (Dart 3.x), Material 3 Responsive UI
- **State Management:** Provider Architecture (`ChangeNotifier` & Reactive Streams)
- **Live Data Feeds:** India Meteorological Department (IMD) & WMO-Compliant Open-Meteo Telemetry
- **Air Quality:** Central Pollution Control Board (CPCB) NAQI Feed ($PM_{2.5}, PM_{10}$)
- **Hardware Integration:** Native Android Magnetometer Sensor Fusion & Native GPS
- **GIS / Mapping:** OpenStreetMap Geospatial Tile Renderer

