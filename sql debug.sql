-- Insert into Reservations
INSERT INTO Reservations (ReservationID, RailNumber, SeatNumber, ReservationDate)
VALUES
(1, 5, 22, '2023-04-15 14:30:00'),
(2, 1, 15, '2023-04-16 09:00:00'),
(3, 2, 8, '2023-04-17 17:45:00');

-- Insert into Seats
INSERT INTO Seats (RailNumber, SeatNumber, AvailabilityStatus, ReservationID)
VALUES
(5, 22, 'Booked', 1),
(1, 15, 'Booked', 2),
(2, 8, 'Available', NULL),
(3, 12, 'Available', NULL);

-- Insert into Payments
INSERT INTO Payments (PaymentID, ReservationID, PaymentStatus, Amount)
VALUES
(1, 1, 'Completed', 150.00),
(2, 2, 'Pending', 120.00),
(3, 3, 'Cancelled', 0.00);