-- Auto-initialization script for H2 database
-- This script is automatically executed when the application starts

CREATE TABLE IF NOT EXISTS predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    disease VARCHAR(100) NOT NULL,
    confidence DOUBLE,
    solution LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_disease ON predictions(disease);
CREATE INDEX IF NOT EXISTS idx_created_at ON predictions(created_at);
CREATE INDEX IF NOT EXISTS idx_confidence ON predictions(confidence);
