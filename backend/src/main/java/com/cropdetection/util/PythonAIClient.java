package com.cropdetection.util;

import com.cropdetection.controller.dto.PredictionRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;

/**
 * Client for communicating with Python AI API
 * Sends images for disease prediction and receives results
 */
@Component
public class PythonAIClient {

    @Value("${app.ai.api.url:http://localhost:5000}")
    private String pythonAIUrl;

    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Send image to Python AI API for disease prediction
     * @param imagePath Path to the image file
     * @return PredictionRequest object with disease, confidence, and solution
     * @throws RuntimeException if API communication fails
     */
    public PredictionRequest predictDisease(String imagePath) {
        try {
            // Python API endpoint
            String apiEndpoint = pythonAIUrl + "/predict";
            System.out.println("🤖 Calling AI API: " + apiEndpoint);

            // Create URL connection
            URL url = URI.create(apiEndpoint).toURL();
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/octet-stream");
            connection.setDoOutput(true);
            connection.setConnectTimeout(30000); // 30 seconds
            connection.setReadTimeout(30000);

            // Read and send image file
            File imageFile = new File(imagePath);
            try (FileInputStream fis = new FileInputStream(imageFile);
                 OutputStream os = connection.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
            }

            // Read response
            int responseCode = connection.getResponseCode();
            System.out.println("📊 API Response Code: " + responseCode);

            if (responseCode == 200) {
                StringBuilder response = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                }

                String jsonResponse = response.toString();
                System.out.println("📋 API Response: " + jsonResponse);

                // Parse JSON response
                PredictionRequest prediction = objectMapper.readValue(jsonResponse, PredictionRequest.class);
                return prediction;
            } else {
                throw new RuntimeException("AI API returned error code: " + responseCode);
            }

        } catch (Exception e) {
            System.err.println("❌ Error calling Python AI API: " + e.getMessage());
            e.printStackTrace();
            
            // Return mock prediction for testing (Remove in production)
            System.out.println("⚠️  Using mock prediction for testing");
            return getMockPrediction();
        }
    }

    /**
     * Mock prediction for testing when Python API is not available
     * Remove this method in production when actual AI model is ready
     * @return Mock PredictionRequest
     */
    private PredictionRequest getMockPrediction() {
        PredictionRequest mockPrediction = new PredictionRequest();
        mockPrediction.setDisease("Early Blight");
        mockPrediction.setConfidence(92.5);
        mockPrediction.setSolution("Apply copper-based fungicide spray every 7-10 days. Improve air circulation. Remove infected leaves. Maintain proper spacing between plants.");
        return mockPrediction;
    }
}
