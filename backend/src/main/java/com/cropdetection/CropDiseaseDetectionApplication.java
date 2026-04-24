package com.cropdetection;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main application class for Crop Disease Detection System
 * Starts the Spring Boot application with embedded Tomcat server
 * Default port: 8080
 */
@SpringBootApplication
public class CropDiseaseDetectionApplication {

    public static void main(String[] args) {
        SpringApplication.run(CropDiseaseDetectionApplication.class, args);
        System.out.println("\n================================================");
        System.out.println("🌾 Crop Disease Detection System Started");
        System.out.println("📍 Server running at http://localhost:8080");
        System.out.println("================================================\n");
    }
}
