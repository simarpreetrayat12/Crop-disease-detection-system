package com.cropdetection.service;

import com.cropdetection.controller.dto.PredictionRequest;
import com.cropdetection.controller.dto.PredictionResponse;
import com.cropdetection.entity.Prediction;
import com.cropdetection.repository.PredictionRepository;
import com.cropdetection.util.ImageUploadUtil;
import com.cropdetection.util.PythonAIClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service class for crop disease prediction
 * Handles business logic for image upload, AI prediction, and storing results
 */
@Service
public class PredictionService {

    @Autowired
    private PredictionRepository predictionRepository;

    @Autowired
    private PythonAIClient pythonAIClient;

    @Autowired
    private ImageUploadUtil imageUploadUtil;

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * Process image upload and predict disease
     * @param imageFile Image file uploaded by user
     * @return PredictionResponse with disease prediction
     * @throws IOException if image processing fails
     */
    public PredictionResponse predictDisease(MultipartFile imageFile) throws IOException {
        // Validate image file
        if (imageFile.isEmpty()) {
            throw new IllegalArgumentException("Image file cannot be empty");
        }

        // Save image to disk
        String imagePath = imageUploadUtil.saveImage(imageFile);
        System.out.println("✓ Image saved at: " + imagePath);

        // Send image to Python AI API for prediction
        PredictionRequest aiResponse = pythonAIClient.predictDisease(imagePath);
        System.out.println("✓ AI Prediction: " + aiResponse.getDisease() + " (" + aiResponse.getConfidence() + "%)");

        // Create and save prediction to database
        Prediction prediction = new Prediction();
        prediction.setImagePath(imagePath);
        prediction.setDisease(aiResponse.getDisease());
        prediction.setConfidence(aiResponse.getConfidence());
        prediction.setSolution(aiResponse.getSolution());

        Prediction savedPrediction = predictionRepository.save(prediction);
        System.out.println("✓ Prediction saved to database with ID: " + savedPrediction.getId());

        // Convert to response DTO
        return convertToResponse(savedPrediction);
    }

    /**
     * Retrieve all predictions from database
     * @return List of PredictionResponse objects
     */
    public List<PredictionResponse> getAllPredictions() {
        List<Prediction> predictions = predictionRepository.findAllByOrderByCreatedAtDesc();
        return predictions.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Retrieve predictions by disease name
     * @param disease Disease name
     * @return List of matching predictions
     */
    public List<PredictionResponse> getPredictionsByDisease(String disease) {
        List<Prediction> predictions = predictionRepository.findByDiseaseOrderByCreatedAtDesc(disease);
        return predictions.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get high-confidence predictions
     * @param minConfidence Minimum confidence threshold (0-100)
     * @return List of predictions meeting the threshold
     */
    public List<PredictionResponse> getHighConfidencePredictions(Double minConfidence) {
        List<Prediction> predictions = predictionRepository.findByConfidenceGreaterThanEqualOrderByCreatedAtDesc(minConfidence);
        return predictions.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get total number of predictions
     * @return Count of all predictions
     */
    public long getTotalPredictions() {
        return predictionRepository.count();
    }

    /**
     * Convert Prediction entity to response DTO
     * @param prediction Prediction entity
     * @return PredictionResponse DTO
     */
    private PredictionResponse convertToResponse(Prediction prediction) {
        return new PredictionResponse(
                prediction.getId(),
                prediction.getImagePath(),
                prediction.getDisease(),
                prediction.getConfidence(),
                prediction.getSolution(),
                prediction.getCreatedAt().format(formatter)
        );
    }
}
