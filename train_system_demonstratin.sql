-- DDL TRAIN SYSTEM:
-- Create Users table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15),
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- Create Trains table
CREATE TABLE Trains (
    TrainNumber INT PRIMARY KEY,
    TrainRoute VARCHAR(255) NOT NULL,
    TrainDepartureTime TIME NOT NULL
);

-- Create Rails table
CREATE TABLE Rails (
    RailID INT AUTO_INCREMENT PRIMARY KEY,
    RailNumber INT NOT NULL UNIQUE,
    OriginStation VARCHAR(100) NOT NULL,
    DestinationStation VARCHAR(100) NOT NULL,
    TrainNumber INT NOT NULL,
    FOREIGN KEY (TrainNumber) REFERENCES Trains(TrainNumber)
);

-- Create Reservations table
CREATE TABLE Reservations (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    TrainNumber INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    RailNumber INT NOT NULL,
    ReservationDate DATE NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (TrainNumber) REFERENCES Trains(TrainNumber),
    FOREIGN KEY (RailNumber) REFERENCES Rails(RailNumber)
);

-- Create Seats table
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    RailNumber INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    AvailabilityStatus VARCHAR(20) NOT NULL,
    ReservationID INT,
    FOREIGN KEY (RailNumber) REFERENCES Rails(RailNumber),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);

-- Create Payments table
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    ReservationID INT NOT NULL,
    PaymentAmount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);

-- BASIC QUERIES:
-- 1. Query to find all users
SELECT * FROM Users;

-- 2. Query to find all trains
SELECT * FROM Trains;

-- 3. Query to find reservations for a specific user
SELECT * FROM Reservations WHERE UserID = 1;

-- 4. Query to find available seats for a specific rail
SELECT * FROM Seats WHERE RailNumber = 1 AND AvailabilityStatus = 'Available';

-- 5. Query to find payments made by a specific user
SELECT * FROM Payments WHERE UserID = 1;

-- 6. Query to find all seats in a specific rail section
SELECT * FROM Seats WHERE RailNumber = 1;

-- 7. Query to find trains with a specific departure time
SELECT * FROM Trains WHERE TrainDepartureTime = '08:00:00';

-- 8. Query to find reservations for a specific train
SELECT * FROM Reservations WHERE TrainNumber = 101;

-- 9. Query to find users by email
SELECT * FROM Users WHERE Email = 'example@example.com';
 
-- 10. Query to find trains by route
SELECT * FROM Trains WHERE TrainRoute = 'Route A';


-- JOIN QUERIES:
-- 1. Query to find users with reservations on a specific date
SELECT Users.FullName, Reservations.ReservationDate
FROM Users
JOIN Reservations ON Users.UserID = Reservations.UserID
WHERE Reservations.ReservationDate = '2024-07-15';

-- 2. Query to find all reservations with train and user details
SELECT Reservations.ReservationID, Users.FullName, Trains.TrainRoute, Reservations.SeatNumber, Reservations.ReservationDate
FROM Reservations
JOIN Users ON Reservations.UserID = Users.UserID
JOIN Trains ON Reservations.TrainNumber = Trains.TrainNumber;

-- 3. Query to find users and their respective reservations
SELECT Users.FullName, Reservations.ReservationID, Reservations.TrainNumber, Reservations.SeatNumber, Reservations.ReservationDate
FROM Users
JOIN Reservations ON Users.UserID = Reservations.UserID;

-- 4. Query to find train details for specific seat reservations
SELECT Seats.SeatNumber, Trains.TrainRoute, Trains.TrainDepartureTime
FROM Seats
JOIN Rails ON Seats.RailNumber = Rails.RailNumber
JOIN Trains ON Rails.TrainNumber = Trains.TrainNumber
WHERE Seats.AvailabilityStatus = 'Booked';

-- 5. Query to find users who have made payments for their reservations
SELECT Users.FullName, Payments.PaymentID, Payments.PaymentAmount, Payments.PaymentDate
FROM Users
JOIN Payments ON Users.UserID = Payments.UserID;


-- Procedures

-- 1. Procedure to Add a New User
DELIMITER //
CREATE PROCEDURE AddNewUser (
    IN p_FullName VARCHAR(100),
    IN p_Address VARCHAR(255),
    IN p_PhoneNumber VARCHAR(15),
    IN p_Email VARCHAR(100)
)
BEGIN
    INSERT INTO Users (FullName, Address, PhoneNumber, Email)
    VALUES (p_FullName, p_Address, p_PhoneNumber, p_Email);
END //
DELIMITER ;

-- 2. Procedure to Make a Reservation
DELIMITER //
CREATE PROCEDURE MakeReservation (
    IN p_UserID INT,
    IN p_TrainNumber INT,
    IN p_SeatNumber VARCHAR(10),
    IN p_RailNumber INT,
    IN p_ReservationDate DATE
)
BEGIN
    INSERT INTO Reservations (UserID, TrainNumber, SeatNumber, RailNumber, ReservationDate)
    VALUES (p_UserID, p_TrainNumber, p_SeatNumber, p_RailNumber, p_ReservationDate);
    
    UPDATE Seats
    SET AvailabilityStatus = 'Booked', ReservationID = LAST_INSERT_ID()
    WHERE RailNumber = p_RailNumber AND SeatNumber = p_SeatNumber;
END //
DELIMITER ;

-- Triggers

-- 1. Trigger to Automatically Update Seat Availability After Reservation
DELIMITER //
CREATE TRIGGER AfterReservationInsert
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    UPDATE Seats
    SET AvailabilityStatus = 'Booked', ReservationID = NEW.ReservationID
    WHERE RailNumber = NEW.RailNumber AND SeatNumber = NEW.SeatNumber;
END //
DELIMITER ;

-- 2. Trigger to Automatically Assign Default Payment Status
DELIMITER //
CREATE TRIGGER BeforePaymentInsert
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.PaymentStatus IS NULL THEN
        SET NEW.PaymentStatus = 'Pending';
    END IF;
END //
DELIMITER ;

-- User Management and Security

-- Create a new user
CREATE USER 'rail_admin'@'localhost' IDENTIFIED BY 'password';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON ORRS.* TO 'rail_admin'@'localhost';

-- Create a read-only user
CREATE USER 'rail_viewer'@'localhost' IDENTIFIED BY 'password';

-- Grant read-only privileges
GRANT SELECT ON ORRS.* TO 'rail_viewer'@'localhost';
