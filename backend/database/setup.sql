-- ===============================================
-- Database Setup Script for Crop Disease Detection
-- ===============================================
-- Run this script in MySQL to create the database and tables

-- Create database
CREATE DATABASE IF NOT EXISTS crop_disease_db;

-- Use the database
USE crop_disease_db;

-- Create predictions table
CREATE TABLE IF NOT EXISTS predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    disease VARCHAR(100) NOT NULL,
    confidence DOUBLE,
    solution LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_disease (disease),
    INDEX idx_created_at (created_at),
    INDEX idx_confidence (confidence)
);

-- Sample query to view all predictions
-- SELECT * FROM predictions ORDER BY created_at DESC;

-- Query to get statistics
-- SELECT disease, COUNT(*) as count, AVG(confidence) as avg_confidence 
-- FROM predictions GROUP BY disease;

print "✓ Database and tables created successfully!";
