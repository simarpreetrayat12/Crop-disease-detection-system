package com.cropdetection.controller.dto;

/**
 * DTO for API responses
 */
public class PredictionResponse {
    private Long id;
    private String imagePath;
    private String disease;
    private Double confidence;
    private String solution;
    private String createdAt;

    public PredictionResponse() {}

    public PredictionResponse(Long id, String imagePath, String disease, Double confidence, String solution, String createdAt) {
        this.id = id;
        this.imagePath = imagePath;
        this.disease = disease;
        this.confidence = confidence;
        this.solution = solution;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getDisease() { return disease; }
    public void setDisease(String disease) { this.disease = disease; }

    public Double getConfidence() { return confidence; }
    public void setConfidence(Double confidence) { this.confidence = confidence; }

    public String getSolution() { return solution; }
    public void setSolution(String solution) { this.solution = solution; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
