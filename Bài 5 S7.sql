CREATE DATABASE CourseStore;
USE CourseStore;

CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO Courses (title, price)
VALUES
('SQL Basic', 500000),
('Python Backend', 300000),
('ReactJS', 450000),
('Machine Learning', 700000),
('Docker DevOps', 550000);


SELECT
    title,
    price,
    price - (
        SELECT AVG(price)
        FROM Courses
    ) AS Price_Difference
FROM Courses;