-- ====================================================================
-- AIRLINE RESERVATION SYSTEM (ARS) - DATABASE SCRIPT
-- Aptech 3rd Semester E-Project
-- Phases 1, 2, and 3
-- ====================================================================

-- 1. Create Database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AirlineReservationDB')
BEGIN
    CREATE DATABASE AirlineReservationDB;
END
GO

USE AirlineReservationDB;
GO

-- 2. Users Table (Registered Users & Admins)
-- Required Profile fields as per Aptech Specification:
-- Username, Password, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
BEGIN
    CREATE TABLE Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        Username VARCHAR(50) UNIQUE NOT NULL,
        Password VARCHAR(255) NOT NULL,
        FirstName VARCHAR(50) NOT NULL,
        LastName VARCHAR(50) NOT NULL,
        Email VARCHAR(100) UNIQUE NOT NULL,
        PhoneNumber VARCHAR(20) NULL,
        Gender VARCHAR(10) NULL,
        Age INT NULL,
        Address VARCHAR(255) NULL,
        PreferredCreditCard VARCHAR(30) NULL,
        SkyMiles INT DEFAULT 0, -- Initialized to 0 for every user as per doc
        Role VARCHAR(20) DEFAULT 'User',
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- 3. Cities Table (Validation, Ambiguity Check, Nearest Serviced Cities)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Cities' AND xtype='U')
BEGIN
    CREATE TABLE Cities (
        CityId INT IDENTITY(1,1) PRIMARY KEY,
        CityName VARCHAR(50) NOT NULL,
        QualifiedName VARCHAR(100) NOT NULL,
        Country VARCHAR(50) NOT NULL,
        StateOrProvince VARCHAR(50) NOT NULL,
        AirportCode VARCHAR(10) NOT NULL,
        AirportName VARCHAR(100) NOT NULL,
        IsDirectlyServiced BIT DEFAULT 1,
        NearestServicedCity VARCHAR(50) NULL,
        NearestAirportCode VARCHAR(10) NULL,
        DistanceToNearestKm INT NULL
    );
END
GO

-- 4. Flights Table (Schedules, Availability, Pricing)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Flights' AND xtype='U')
BEGIN
    CREATE TABLE Flights (
        FlightId INT IDENTITY(1,1) PRIMARY KEY,
        FlightNumber VARCHAR(20) NOT NULL,
        AirlineName VARCHAR(50) NOT NULL,
        OriginCity VARCHAR(50) NOT NULL,
        DestinationCity VARCHAR(50) NOT NULL,
        DepartureTime DATETIME NOT NULL,
        ArrivalTime DATETIME NOT NULL,
        EconomyPrice DECIMAL(10,2) NOT NULL,
        BusinessPrice DECIMAL(10,2) NOT NULL,
        FirstClassPrice DECIMAL(10,2) NOT NULL,
        TotalSeats INT NOT NULL,
        AvailableSeats INT NOT NULL,
        Status VARCHAR(20) DEFAULT 'Scheduled',
        RevisedDepartureTime DATETIME NULL,
        RevisedArrivalTime DATETIME NULL,
        TimingChangeReason VARCHAR(255) NULL
    );
END
GO

-- 5. Reservations Table (Bookings, Blocked Tickets, Cancellations)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Reservations' AND xtype='U')
BEGIN
    CREATE TABLE Reservations (
        ReservationId INT IDENTITY(1001,1) PRIMARY KEY,
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        FlightId INT FOREIGN KEY REFERENCES Flights(FlightId),
        BookingReference VARCHAR(12) UNIQUE NOT NULL,
        PassengerName VARCHAR(100) NOT NULL,
        SeatClass VARCHAR(20) NOT NULL,
        Status VARCHAR(20) NOT NULL,
        TotalPrice DECIMAL(10,2) NOT NULL,
        BookingDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- 6. Cancellation Policies Table (Section 3.6 / Phase 5)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CancellationPolicies' AND xtype='U')
BEGIN
    CREATE TABLE CancellationPolicies (
        PolicyId INT IDENTITY(1,1) PRIMARY KEY,
        PeriodDescription VARCHAR(100) NOT NULL,
        MinDaysBefore INT NOT NULL,
        MaxDaysBefore INT NULL,
        RefundPercentage INT NOT NULL,
        DeductionPercentage INT NOT NULL,
        Remarks VARCHAR(255) NULL
    );
END
GO

-- 6. Seed Demo Users
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username='john_doe')
BEGIN
    INSERT INTO Users (Username, Password, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles, Role)
    VALUES ('john_doe', 'Password123', 'John', 'Doe', 'john@example.com', '+92 300 1234567', 'Male', 29, 'Block 6, PECHS, Karachi', '************4321', 1250, 'User');
END
GO

IF NOT EXISTS (SELECT 1 FROM Users WHERE Username='admin')
BEGIN
    INSERT INTO Users (Username, Password, FirstName, LastName, Email, PhoneNumber, Gender, Age, Address, PreferredCreditCard, SkyMiles, Role)
    VALUES ('admin', 'Admin@123', 'System', 'Administrator', 'admin@aerofly.com', '+92 321 9876543', 'Male', 35, 'Airport Road, Karachi', '************9999', 5000, 'Admin');
END
GO

-- 7. Seed Cities (Directly Serviced, Ambiguity Cases, Nearest Fallbacks)
DELETE FROM Cities;
INSERT INTO Cities (CityName, QualifiedName, Country, StateOrProvince, AirportCode, AirportName, IsDirectlyServiced, NearestServicedCity, NearestAirportCode, DistanceToNearestKm)
VALUES
('Karachi', 'Karachi (Sindh, Pakistan) - KHI', 'Pakistan', 'Sindh', 'KHI', 'Jinnah International Airport', 1, NULL, NULL, 0),
('Islamabad', 'Islamabad (Capital Territory, Pakistan) - ISB', 'Pakistan', 'Islamabad', 'ISB', 'Islamabad International Airport', 1, NULL, NULL, 0),
('Lahore', 'Lahore (Punjab, Pakistan) - LHE', 'Pakistan', 'Punjab', 'LHE', 'Allama Iqbal International Airport', 1, NULL, NULL, 0),
('Dubai', 'Dubai (United Arab Emirates) - DXB', 'UAE', 'Dubai', 'DXB', 'Dubai International Airport', 1, NULL, NULL, 0),
('London', 'London (United Kingdom) - LHR', 'United Kingdom', 'Greater London', 'LHR', 'Heathrow Airport', 1, NULL, NULL, 0),
('Istanbul', 'Istanbul (Turkey) - IST', 'Turkey', 'Marmara', 'IST', 'Istanbul Airport', 1, NULL, NULL, 0),
('New York', 'New York (United States) - JFK', 'USA', 'New York', 'JFK', 'John F. Kennedy International Airport', 1, NULL, NULL, 0),

-- Ambiguity Test Cases (Section 3.3.1)
('Hyderabad', 'Hyderabad (Sindh, Pakistan) - HDD', 'Pakistan', 'Sindh', 'HDD', 'Hyderabad Airport', 0, 'Karachi', 'KHI', 160),
('Hyderabad', 'Hyderabad (Telangana, India) - HYD', 'India', 'Telangana', 'HYD', 'Rajiv Gandhi International Airport', 1, NULL, NULL, 0),
('Springfield', 'Springfield (Illinois, USA) - SPI', 'USA', 'Illinois', 'SPI', 'Abraham Lincoln Capital Airport', 0, 'Chicago', 'ORD', 320),
('Springfield', 'Springfield (Missouri, USA) - SGF', 'USA', 'Missouri', 'SGF', 'Springfield-Branson Airport', 0, 'St. Louis', 'STL', 345),

-- Non-Serviced Cities with Nearest Serviced Suggestions (Section 3.3.1)
('Rawalpindi', 'Rawalpindi (Punjab, Pakistan)', 'Pakistan', 'Punjab', 'RWP', 'Rawalpindi Station', 0, 'Islamabad', 'ISB', 25),
('Abbottabad', 'Abbottabad (KPK, Pakistan)', 'Pakistan', 'KPK', 'ATD', 'Abbottabad Town', 0, 'Islamabad', 'ISB', 120),
('Faisalabad', 'Faisalabad (Punjab, Pakistan)', 'Pakistan', 'Punjab', 'LYP', 'Faisalabad City', 0, 'Lahore', 'LHE', 130),
('Sharjah', 'Sharjah (United Arab Emirates)', 'UAE', 'Sharjah', 'SHJ', 'Sharjah Center', 0, 'Dubai', 'DXB', 28),
('Cambridge', 'Cambridge (England, UK)', 'United Kingdom', 'Cambridgeshire', 'CBG', 'Cambridge Station', 0, 'London', 'LHR', 85);

-- 8. Seed Flights (Direct & Connecting Routes)
DELETE FROM Flights;
DECLARE @BaseDate DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

INSERT INTO Flights (FlightNumber, AirlineName, OriginCity, DestinationCity, DepartureTime, ArrivalTime, EconomyPrice, BusinessPrice, FirstClassPrice, TotalSeats, AvailableSeats, Status)
VALUES
('PK-301', 'AeroFly Pakistan', 'Karachi', 'Islamabad', DATEADD(hour, 8, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 10, DATEADD(day, 1, @BaseDate)), 15500.00, 32000.00, 48000.00, 180, 42, 'On-Time'),
('PK-302', 'AeroFly Pakistan', 'Karachi', 'Lahore', DATEADD(hour, 11, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 13, DATEADD(day, 1, @BaseDate)), 14500.00, 30000.00, 45000.00, 180, 28, 'On-Time'),
('PK-303', 'AeroFly Pakistan', 'Islamabad', 'Karachi', DATEADD(hour, 14, DATEADD(day, 3, @BaseDate)), DATEADD(hour, 16, DATEADD(day, 3, @BaseDate)), 15500.00, 32000.00, 48000.00, 180, 50, 'On-Time'),
('PK-304', 'AeroFly Pakistan', 'Lahore', 'Karachi', DATEADD(hour, 17, DATEADD(day, 3, @BaseDate)), DATEADD(hour, 19, DATEADD(day, 3, @BaseDate)), 14500.00, 30000.00, 45000.00, 180, 35, 'On-Time'),
('PK-701', 'AeroFly Global', 'Karachi', 'Dubai', DATEADD(hour, 7, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 9, DATEADD(day, 1, @BaseDate)), 48000.00, 95000.00, 140000.00, 250, 68, 'On-Time'),
('EK-007', 'Emirates Partner', 'Dubai', 'London', DATEADD(hour, 12, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 20, DATEADD(day, 1, @BaseDate)), 92000.00, 180000.00, 260000.00, 350, 110, 'On-Time'),
('EK-201', 'Emirates Partner', 'Dubai', 'New York', DATEADD(hour, 14, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 26, DATEADD(day, 1, @BaseDate)), 140000.00, 290000.00, 420000.00, 380, 85, 'On-Time'),
('PK-785', 'AeroFly Global', 'Islamabad', 'London', DATEADD(hour, 9, DATEADD(day, 2, @BaseDate)), DATEADD(hour, 17, DATEADD(day, 2, @BaseDate)), 135000.00, 275000.00, 395000.00, 300, 72, 'On-Time'),
('PK-786', 'AeroFly Global', 'London', 'Islamabad', DATEADD(hour, 19, DATEADD(day, 5, @BaseDate)), DATEADD(hour, 29, DATEADD(day, 5, @BaseDate)), 135000.00, 275000.00, 395000.00, 300, 60, 'On-Time'),
('TK-708', 'Turkish Airlines Partner', 'Karachi', 'Istanbul', DATEADD(hour, 6, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 12, DATEADD(day, 1, @BaseDate)), 65000.00, 130000.00, 190000.00, 260, 45, 'On-Time'),
('TK-1985', 'Turkish Airlines Partner', 'Istanbul', 'London', DATEADD(hour, 15, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 19, DATEADD(day, 1, @BaseDate)), 42000.00, 88000.00, 130000.00, 200, 50, 'On-Time'),
('AI-839', 'Air India Partner', 'Hyderabad', 'Dubai', DATEADD(hour, 10, DATEADD(day, 1, @BaseDate)), DATEADD(hour, 14, DATEADD(day, 1, @BaseDate)), 52000.00, 105000.00, 155000.00, 220, 40, 'On-Time');
GO
