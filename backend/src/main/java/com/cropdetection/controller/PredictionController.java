package com.cropdetection.controller;

import com.cropdetection.controller.dto.PredictionResponse;
import com.cropdetection.service.PredictionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST Controller for crop disease prediction API
 * Handles image upload and prediction history requests
 */
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class PredictionController {

    @Autowired
    private PredictionService predictionService;

    /**
     * POST endpoint to upload image and predict disease
     * @param imageFile Image file from frontend
     * @return Prediction result with disease, confidence, and solution
     */
    @PostMapping("/predict")
    public ResponseEntity<?> predictDisease(@RequestParam("image") MultipartFile imageFile) {
        try {
            System.out.println("\n📥 Received image upload: " + imageFile.getOriginalFilename());
            
            // Process image and get prediction
            PredictionResponse prediction = predictionService.predictDisease(imageFile);
            
            // Return successful response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", prediction);
            response.put("message", "Disease prediction successful");
            
            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            // Handle validation errors
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Invalid file: " + e.getMessage());
            
            System.err.println("❌ Validation error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);

        } catch (IOException e) {
            // Handle IO errors
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error processing image: " + e.getMessage());
            
            System.err.println("❌ IO error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);

        } catch (Exception e) {
            // Handle unexpected errors
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Unexpected error: " + e.getMessage());
            
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * GET endpoint to retrieve all prediction history
     * @return List of all predictions sorted by date (newest first)
     */
    @GetMapping("/history")
    public ResponseEntity<?> getPredictionHistory() {
        try {
            System.out.println("\n📜 Fetching prediction history...");
            
            List<PredictionResponse> predictions = predictionService.getAllPredictions();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", predictions);
            response.put("total", predictions.size());
            response.put("message", "Predictions retrieved successfully");
            
            System.out.println("✓ Retrieved " + predictions.size() + " predictions");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error retrieving history: " + e.getMessage());
            
            System.err.println("❌ Error retrieving history: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * GET endpoint to retrieve predictions by disease name
     * @param disease Disease name to filter by
     * @return List of predictions for the specified disease
     */
    @GetMapping("/history/disease")
    public ResponseEntity<?> getPredictionsByDisease(@RequestParam String disease) {
        try {
            System.out.println("\n🔍 Fetching predictions for disease: " + disease);
            
            List<PredictionResponse> predictions = predictionService.getPredictionsByDisease(disease);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", predictions);
            response.put("total", predictions.size());
            response.put("disease", disease);
            
            System.out.println("✓ Found " + predictions.size() + " predictions for " + disease);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error retrieving predictions: " + e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * GET endpoint to retrieve high-confidence predictions
     * @param minConfidence Minimum confidence threshold (0-100)
     * @return List of predictions meeting the confidence threshold
     */
    @GetMapping("/history/confidence")
    public ResponseEntity<?> getHighConfidencePredictions(@RequestParam Double minConfidence) {
        try {
            if (minConfidence < 0 || minConfidence > 100) {
                throw new IllegalArgumentException("Confidence must be between 0 and 100");
            }

            System.out.println("\n📊 Fetching high-confidence predictions (>= " + minConfidence + "%)");
            
            List<PredictionResponse> predictions = predictionService.getHighConfidencePredictions(minConfidence);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", predictions);
            response.put("total", predictions.size());
            response.put("minConfidence", minConfidence);
            
            System.out.println("✓ Found " + predictions.size() + " high-confidence predictions");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error retrieving predictions: " + e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * GET endpoint for health check
     * @return Status message
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Crop Disease Detection API");
        response.put("totalPredictions", predictionService.getTotalPredictions());
        System.out.println("✓ Health check successful");
        return ResponseEntity.ok(response);
    }

    /**
     * GET endpoint for API info
     * @return API documentation
     */
    @GetMapping("/info")
    public ResponseEntity<?> getApiInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("service", "Crop Disease Detection System");
        info.put("version", "1.0.0");
        info.put("endpoints", new HashMap<String, String>() {{
            put("POST /api/predict", "Upload image and predict disease");
            put("GET /api/history", "Get all predictions");
            put("GET /api/history/disease", "Get predictions by disease name");
            put("GET /api/history/confidence", "Get high-confidence predictions");
            put("GET /api/health", "Health check");
            put("GET /api/info", "API information");
        }});
        return ResponseEntity.ok(info);
    }
}
