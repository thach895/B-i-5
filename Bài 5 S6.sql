CREATE DATABASE HotelSystem;
USE HotelSystem;
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_name VARCHAR(100)
);
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT,
    status VARCHAR(20),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);
INSERT INTO Rooms (room_id, room_name) VALUES
(1, 'Standard'),
(2, 'Deluxe'),
(3, 'Suite'),
(4, 'Single'),
(5, 'Double'),
(6, 'VIP');
INSERT INTO Bookings (room_id, status) VALUES
(1, 'COMPLETED'),
(1, 'CANCELLED'),
(2, 'COMPLETED'),
(3, 'PENDING'),
(3, 'COMPLETED'),
(NULL, 'CANCELLED');

SELECT r.room_id, r.room_name
FROM Rooms r
LEFT JOIN Bookings b 
    ON r.room_id = b.room_id
WHERE b.room_id IS NULL;