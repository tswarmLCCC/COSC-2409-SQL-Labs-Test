CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name TEXT,
    major TEXT
);

INSERT INTO students (name, major) VALUES 
('Alice Smith', 'Computer Science'),
('Bob Jones', 'Information Systems');
