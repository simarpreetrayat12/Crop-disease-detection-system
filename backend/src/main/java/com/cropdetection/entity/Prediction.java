package com.cropdetection.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * JPA Entity for storing crop disease predictions
 * Maps to 'predictions' table in MySQL database
 */
@Entity
@Table(name = "predictions")
@NoArgsConstructor
@AllArgsConstructor
public class Prediction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Path to the uploaded image file
     */
    @Column(name = "image_path", nullable = false)
    private String imagePath;

    /**
     * Detected crop disease name (e.g., "Leaf Spot", "Powdery Mildew")
     */
    @Column(name = "disease", nullable = false)
    private String disease;

    /**
     * Confidence percentage of the prediction (0-100)
     */
    @Column(name = "confidence")
    private Double confidence;

    /**
     * Treatment suggestion for the detected disease
     */
    @Column(name = "solution", columnDefinition = "LONGTEXT")
    private String solution;

    /**
     * Timestamp when the prediction was created
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * Set timestamp before persisting
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getDisease() {
        return disease;
    }

    public void setDisease(String disease) {
        this.disease = disease;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public String getSolution() {
        return solution;
    }

    public void setSolution(String solution) {
        this.solution = solution;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Prediction{" +
                "id=" + id +
                ", imagePath='" + imagePath + '\'' +
                ", disease='" + disease + '\'' +
                ", confidence=" + confidence +
                ", solution='" + solution + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
