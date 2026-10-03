# ✈️ AeroFly — Airline Reservation System (ARS)

> **Aptech Semester 3 E-Project**  
> **Specialization:** Web Development with C#, ASP.NET Web Forms & Microsoft SQL Server  
> **Architecture:** Multi-Tier Web Architecture (Public, User Dashboard, Admin/Clerk Operations)  
> **UI/UX:** Premium 3D Aviation Theme with Interactive Light / Dark Mode  

---

## 📋 Table of Contents
1. [Project Overview](#-project-overview)
2. [Technology Stack](#-technology-stack)
3. [Folder & Directory Structure](#-folder--directory-structure)
4. [System Modules & Features](#-system-modules--features)
   - [1. Public Module](#1-public-module)
   - [2. User Dashboard](#2-user-dashboard)
   - [3. Admin & Clerk Command Center](#3-admin--clerk-command-center)
5. [Business Rules & Logic Implementation](#-business-rules--logic-implementation)
6. [Database Schema & Architecture](#-database-schema--architecture)
7. [Installation & Setup Guide](#-installation--setup-guide)
8. [Default Credentials & Demo Accounts](#-default-credentials--demo-accounts)
9. [User Interface & Design System](#-user-interface--design-system)
10. [Submission & Grading Highlights](#-submission--grading-highlights)

---

## 🌟 Project Overview

**AeroFly Airline Reservation System (ARS)** is an enterprise-grade web application built to simulate full-scale airline operations, passenger ticketing, and flight fleet administration. Developed strictly adhering to the **Aptech 3rd Semester E-Project Specifications**, AeroFly covers every required phase from guest flight exploration and user authentication to passenger blocking deadlines, ticket confirmation, rescheduling, cancellation policies, and centralized administration.

The platform provides a modern **3D Skeuomorphic Aviation Experience** with customizable **Light and Dark themes**, mobile-responsive layouts, and robust backend data processing via **C# ADO.NET** and **Microsoft SQL Server LocalDB**.

---

## 💻 Technology Stack

| Layer | Technologies Used |
|---|---|
| **Frontend Framework** | ASP.NET Web Forms (.NET Framework 4.8), Master Pages |
| **Styling & Icons** | Bootstrap 5.3.2, FontAwesome 6.4.2, Custom 3D Aviation CSS (`custom.css`) |
| **Client-Side Scripting** | JavaScript (ES6+), LocalStorage Theme Persistence |
| **Backend Language** | C# (C-Sharp) with Object-Oriented Multi-Tier Helpers |
| **Data Access** | ADO.NET (`SqlConnection`, `SqlCommand`, `SqlDataAdapter`, `SqlParameter`) |
| **Database** | Microsoft SQL Server LocalDB (`(localdb)\MSSQLLocalDB`), Database: `AirlineReservationDB` |
| **Web Server** | IIS Express (Port `8085`) / Visual Studio Web Development Server |

---

## 📂 Folder & Directory Structure

The project has been organized into a clean, modular folder hierarchy conforming to enterprise ASP.NET standards:

```text
Airline Reservation System (ARS) 3rd Semester Project/
│
├── Public/                       # Public & Guest User Pages (No Login Required)
│   ├── Home.aspx                 # Main Landing Page with Flight Search Banner & Promos
│   ├── Home.aspx.cs
│   ├── Login.aspx                # User Authentication (Login as User, Admin, or Clerk)
│   ├── Login.aspx.cs
│   ├── Register.aspx             # New Passenger Sign-Up (Auto SkyMiles = 0)
│   ├── Register.aspx.cs
│   ├── SearchFlights.aspx        # Public Flight Search with City Ambiguity Check
│   ├── SearchFlights.aspx.cs
│   ├── FlightResults.aspx        # Search Results with Sorting & Filtering
│   ├── FlightResults.aspx.cs
│   ├── FlightDetails.aspx        # Real-time Public Flight Dispatch & Schedule Tracker
│   └── FlightDetails.aspx.cs
│
├── User/                         # Authenticated Customer Dashboard
│   ├── Dashboard.aspx            # User Overview, SkyMiles Counter, Recent Bookings
│   ├── Dashboard.aspx.cs
│   ├── SearchFlights.aspx        # Member Flight Search
│   ├── SearchFlights.aspx.cs
│   ├── BookTicket.aspx           # Passenger Booking Form with Step-by-Step Flow
│   ├── BookTicket.aspx.cs
│   ├── BlockTicket.aspx          # Ticket Blocking Interface (14-Day Deadline Rule)
│   ├── BlockTicket.aspx.cs
│   ├── ConfirmTicket.aspx        # Blocked Ticket Conversion & SkyMiles Crediting
│   ├── ConfirmTicket.aspx.cs
│   ├── MyTickets.aspx            # Passenger Booking History & Downloadable Itineraries
│   ├── MyTickets.aspx.cs
│   ├── TicketStatus.aspx         # Real-Time PNR Lookup & Delay Notification Alert
│   ├── TicketStatus.aspx.cs
│   ├── RescheduleTicket.aspx     # Flight Rescheduling with Real-time Fare Adjustment
│   ├── RescheduleTicket.aspx.cs
│   ├── CancelTicket.aspx         # Ticket Cancellation with Refund Policy Matrix
│   ├── CancelTicket.aspx.cs
│   ├── Profile.aspx              # Passenger Profile & Frequent Flyer Miles Manager
│   ├── Profile.aspx.cs
│   ├── Logout.aspx               # Safe Session Termination
│   └── Logout.aspx.cs
│
├── Admin/                        # Central Operations Command (Admin & Clerk)
│   ├── Dashboard.aspx            # Comprehensive Operations Dashboard with KPI Metrics
│   ├── Dashboard.aspx.cs
│   ├── Flights.aspx              # Flight Fleet Management (Add, Update, Delete Flights)
│   ├── Flights.aspx.cs
│   ├── FlightSchedules.aspx      # Flight Schedule Planning & Time Slots
│   ├── FlightSchedules.aspx.cs
│   ├── Reservations.aspx         # Passenger Reservation Tracking & Status Updates
│   ├── Reservations.aspx.cs
│   ├── Users.aspx                # User Management & Role Administration
│   ├── Users.aspx.cs
│   ├── SeatAvailability.aspx     # Interactive Aircraft Seat Layout & Occupancy Audit
│   └── SeatAvailability.aspx.cs
│
├── Shared/                       # Shared Master Pages & Components
│   ├── Site.Master               # Global 3D Navigation, Theme Switcher & Footer
│   └── Site.Master.cs
│
├── App_Code/                     # Data Access & Core Business Logic Layer
│   ├── DbHelper.cs               # Centralized SQL Server Connection & Query Engine
│   ├── UserStateHelper.cs        # Session State Management & Role-Based Access Control
│   ├── AdminHelper.cs            # Admin Operations, KPI Metrics & Data Binding Helpers
│   ├── FlightSearchHelper.cs     # Multi-City Ambiguity, Nearest Airport & Transit Engine
│   └── ReservationHelper.cs      # Booking, Blocking, Rescheduling & Refund Math Engine
│
├── Content/                      # Visual Assets & Styling
│   └── css/
│       └── custom.css            # 3D Aviation Design System & Dual Theme Engine
│
├── Database/                     # SQL Scripts & Schema Definitions
│   └── setup_db.sql              # Clean SQL Database Schema, Tables, Constraints & Seeds
│
├── Docs/                         # Project Documentation
│   └── README.md
│
├── Default.aspx                  # Application Entrypoint (Auto-redirects to Public/Home.aspx)
├── Default.aspx.cs
├── Web.config                    # Connection Strings, Compilation & Routing Configuration
├── run_project.bat               # One-Click Project Runner (IIS Express Launcher)
└── AirlineReservationSystem.sln  # Visual Studio Solution File
```

---

## 🚀 System Modules & Features

### 1. Public Module
- **Home Landing Page (`Public/Home.aspx`):** Features hero section, quick flight search widget (One Way / Round Trip), popular destination cards, and airline benefits.
- **Unified Authentication (`Public/Login.aspx`):** Clean card interface for logging in with credentials. Auto-redirects users to their designated portals (`Admin` vs `User`). Includes a quick one-click demo login option for university grading.
- **Member Registration (`Public/Register.aspx`):** Captures complete profile info (Username, Password, First Name, Last Name, Email, Phone, Gender, Age, Address, Preferred Credit Card). Strictly initializes **`SkyMiles = 0`** as mandated by Aptech specifications.
- **Flight Discovery (`Public/SearchFlights.aspx`):** Allows public users and guests to check availability, compare ticket prices, and view seat layouts.
- **Real-Time Schedule Tracker (`Public/FlightDetails.aspx`):** Guests can search any flight number (e.g., `PK-301`, `EK-602`) and date to view live dispatch status, gate, terminal, and departure times without needing an account.

### 2. User Dashboard
- **Personal Aviation Hub (`User/Dashboard.aspx`):** Real-time flight statistics, loyalty tier badges, live SkyMiles balance, and recent booking overviews.
- **Ticket Booking (`User/BookTicket.aspx`):** Seamless passenger booking form supporting Adult, Child, and Senior fares with real-time tax calculation.
- **Ticket Blocking (`User/BlockTicket.aspx`):** Enforces Aptech business rule: **Passengers can block tickets only if departure date is more than 14 days away**. Generates temporary `BLK-XXXXX` reference numbers.
- **Confirm Ticket (`User/ConfirmTicket.aspx`):** Allows passengers to convert blocked tickets (`BLK-`) into confirmed reservations (`CNF-`), with instant SkyMiles credit.
- **Ticket Status & Flight Delay Alert (`User/TicketStatus.aspx`):** Real-time status tracker for both `CNF-` and `BLK-` numbers. Includes interactive **Delay Banner** displaying revised flight times and reasons when delays occur.
- **Flight Rescheduling (`User/RescheduleTicket.aspx`):** Reschedules flights dynamically. Calculates price differences: if the new flight costs more, it bills the passenger; if lower, it generates refund credit.
- **Ticket Cancellation & Refund Calculator (`User/CancelTicket.aspx`):** Automatically calculates cancellation fees and refund percentages based on days remaining before flight departure.
- **Profile Manager (`User/Profile.aspx`):** View and update personal information, contact numbers, payment preferences, and track SkyMiles accumulation.

### 3. Admin & Clerk Command Center
- **Executive Operations Dashboard (`Admin/Dashboard.aspx`):** High-level KPI cards summarizing total flights, total bookings, registered passengers, and available seats.
- **Fleet & Flights Management (`Admin/Flights.aspx`):** Manage aircraft carriers, flight numbers, aircraft models, total seat capacities, and status (Active/Grounded).
- **Flight Schedules (`Admin/FlightSchedules.aspx`):** Configure origins, destinations, departure and arrival times, and base fares across classes.
- **Reservations Auditor (`Admin/Reservations.aspx`):** Real-time monitor of all passenger bookings with filters for Confirmed, Blocked, Cancelled, and Rescheduled states.
- **User Administration (`Admin/Users.aspx`):** Manage customer profiles, assign roles (Admin, Clerk, User), and audit SkyMiles.
- **Seat Availability Inspector (`Admin/SeatAvailability.aspx`):** Visual interactive seating grid showing booked versus vacant seats per flight schedule.

---

## ⚙️ Business Rules & Logic Implementation

1. **User Role Separation:**
   - **Guest:** Allowed to browse, search flight schedules, and view pricing; barred from booking, blocking seats, or accessing dashboards.
   - **Registered User:** Full access to booking, blocking, managing tickets, and earning loyalty miles.
   - **Clerk / Administrator:** Full access to flight administration, schedules, reservations, and seat capacity.

2. **City Ambiguity Resolution (Same-Name Cities):**
   - When searching for cities sharing identical names (e.g., *Hyderabad*), the engine prompts users to specify the exact region and airport code:
     - `Hyderabad (Sindh, Pakistan) - HDD`
     - `Hyderabad (Telangana, India) - HYD`

3. **Nearest Serviced Airport Recommendations:**
   - For non-serviced cities (e.g., *Rawalpindi*, *Abbottabad*), the system detects the nearest operational airport (e.g., *Islamabad International - ISB*), calculates road distance in kilometers, and enables single-click route updating.

4. **14-Day Blocking Rule:**
   - A passenger cannot block a flight within 14 days of departure.
   - For departures $> 14$ days, blocking is allowed and generates a unique `BLK-` PNR code.

5. **PNR Code Standards:**
   - Blocked Tickets: `BLK-XXXXX`
   - Confirmed Tickets: `CNF-XXXXX`
   - Cancelled Tickets: `CAN-XXXXX`

6. **Refund Calculation Matrix:**
   - Cancellation $> 7$ days prior: $90\%$ refund ($10\%$ deduction fee).
   - Cancellation between $2$ to $7$ days: $75\%$ refund.
   - Cancellation $< 48$ hours prior: $50\%$ refund.

---

## 🗄️ Database Schema & Architecture

The database is built on **Microsoft SQL Server LocalDB** under database name **`AirlineReservationDB`**.

### Schema Tables Overview:

```text
AirlineReservationDB
│
├── Users
│   ├── UserId (PK, INT IDENTITY)
│   ├── Username (VARCHAR 50, UNIQUE)
│   ├── Password (VARCHAR 255)
│   ├── FirstName, LastName (VARCHAR 50)
│   ├── Email (VARCHAR 100, UNIQUE)
│   ├── PhoneNumber (VARCHAR 20)
│   ├── Gender (VARCHAR 10)
│   ├── Age (INT)
│   ├── Address (VARCHAR 255)
│   ├── PreferredCreditCard (VARCHAR 30)
│   ├── SkyMiles (INT, DEFAULT 0)
│   ├── Role (VARCHAR 20, DEFAULT 'User')
│   └── CreatedAt (DATETIME)
│
├── Cities
│   ├── CityId (PK, INT IDENTITY)
│   ├── CityName, QualifiedName, Country, StateOrProvince
│   ├── AirportCode, AirportName
│   ├── IsDirectlyServiced (BIT)
│   ├── NearestServicedCity, NearestAirportCode
│   └── DistanceToNearestKm (INT)
│
├── Flights
│   ├── FlightId (PK, INT IDENTITY)
│   ├── FlightNumber (VARCHAR 20, UNIQUE)
│   ├── AirlineName, AircraftType
│   ├── TotalSeats (INT)
│   └── IsActive (BIT)
│
├── FlightSchedules
│   ├── ScheduleId (PK, INT IDENTITY)
│   ├── FlightId (FK -> Flights)
│   ├── OriginCityId, DestinationCityId (FK -> Cities)
│   ├── DepartureTime, ArrivalTime
│   ├── DaysOfWeek (VARCHAR 50)
│   ├── BaseFare (DECIMAL)
│   └── Status (VARCHAR 20)
│
├── Reservations
│   ├── ReservationId (PK, INT IDENTITY)
│   ├── PNR (VARCHAR 20, UNIQUE)
│   ├── UserId (FK -> Users)
│   ├── ScheduleId (FK -> FlightSchedules)
│   ├── PassengerName, PassengerAge, PassengerGender
│   ├── TravelClass (VARCHAR 20)
│   ├── TravelDate (DATETIME)
│   ├── BookingStatus (VARCHAR 20) -- Confirmed, Blocked, Cancelled
│   ├── TotalAmount (DECIMAL)
│   └── CreatedAt (DATETIME)
│
└── Seats
    ├── SeatId (PK, INT IDENTITY)
    ├── ScheduleId (FK -> FlightSchedules)
    ├── SeatNumber (VARCHAR 10)
    ├── TravelClass (VARCHAR 20)
    └── IsAvailable (BIT)
```

---

## 🛠️ Installation & Setup Guide

### 1. Prerequisites
- **Visual Studio 2022** (with *.NET desktop development* and *ASP.NET and web development* workloads) OR **IIS Express**.
- **.NET Framework 4.8** installed.
- **SQL Server LocalDB** (included by default with Visual Studio) or SQL Server Express.

### 2. Database Initialization
1. Open PowerShell or command prompt.
2. Execute the setup script into SQL Server LocalDB using `sqlcmd`:
   ```powershell
   sqlcmd -S "(localdb)\MSSQLLocalDB" -i "D:\Aptech Shahr-e-faisal\3rd Semester\Airline Reservation System (ARS) 3rd Semester Project\Database\setup_db.sql"
   ```
3. Alternatively, open **SQL Server Management Studio (SSMS)**, connect to `(localdb)\MSSQLLocalDB`, open `Database/setup_db.sql`, and click **Execute**.

### 3. Running the Web Application
#### Option A: Quick Batch Launcher
Double click `run_project.bat` in the project root. This automatically:
- Checks SQL Server LocalDB availability.
- Starts **IIS Express** on port `8085`.
- Opens your browser directly to `http://localhost:8085/Default.aspx`.

#### Option B: Visual Studio
1. Open `AirlineReservationSystem.sln` in **Visual Studio**.
2. Press **F5** or click **IIS Express** to start debugging.

---

## 🔑 Default Credentials & Demo Accounts

For project evaluation, grading, and testing, the database is pre-seeded with the following accounts:

| Role | Username | Password | Purpose |
|---|---|---|---|
| **Administrator** | `admin` | `admin123` | Full access to Admin Operations, Fleets, Schedules & Users |
| **Clerk / Staff** | `clerk` | `clerk123` | Access to Reservations, Schedules & Seat Inspections |
| **Registered User** | `demo` | `demo123` | Standard Passenger Portal with booking history & SkyMiles |

> 💡 **Quick Demo Access:** On both `Public/Login.aspx` and `Admin/Dashboard.aspx`, convenient 1-click demo login buttons are provided for instant evaluation during presentations.

---

## 🎨 User Interface & Design System

- **3D Aviation Depth:** Custom layered elevations, skeuomorphic card borders, and tactile shadows.
- **Dual Themes:** Full system-wide support for **Light Mode** and **Dark Mode**.
- **Zero-Flicker Hydration:** Theme preferences are stored in browser `localStorage` and applied instantly before DOM render, preventing white flash transitions.
- **Clean Code Standard:** All 57 source files have been stripped of tutorial comments, leaving clean, production-grade code.

---

## 🏆 Submission & Grading Highlights

- **Requirement Coverage:** Fully fulfills Aptech 3rd Semester E-Project requirements across all 8 phases.
- **Code Cleanliness:** Organized into proper modules (`Public`, `User`, `Admin`, `Shared`, `App_Code`) with zero compiler warnings.
- **Security:** SQL injection prevention via ADO.NET parameterized queries, session state authorization validation, and role-based page protection.
- **Robust Exception Handling:** Graceful error handling for missing routes, invalid dates, and database interruptions.

---

**Developed for Aptech Shahr-e-Faisal — 3rd Semester E-Project**  
*AeroFly Airline Reservation System (ARS)*
