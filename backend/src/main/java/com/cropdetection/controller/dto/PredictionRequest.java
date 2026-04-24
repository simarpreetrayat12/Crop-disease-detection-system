package com.cropdetection.controller.dto;

/**
 * DTO for prediction response from Python AI API
 */
public class PredictionRequest {
    public String disease;
    public Double confidence;
    public String solution;

    public PredictionRequest() {}

    public PredictionRequest(String disease, Double confidence, String solution) {
        this.disease = disease;
        this.confidence = confidence;
        this.solution = solution;
    }

    public String getDisease() { return disease; }
    public void setDisease(String disease) { this.disease = disease; }

    public Double getConfidence() { return confidence; }
    public void setConfidence(Double confidence) { this.confidence = confidence; }

    public String getSolution() { return solution; }
    public void setSolution(String solution) { this.solution = solution; }
}
