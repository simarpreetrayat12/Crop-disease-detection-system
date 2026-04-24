package com.cropdetection.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * Utility class for handling image uploads
 * Saves uploaded images to disk and manages file operations
 */
@Component
public class ImageUploadUtil {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    // Allowed image file extensions
    private static final String[] ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "bmp"};
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB

    /**
     * Save uploaded image file to disk
     * @param file MultipartFile from user upload
     * @return Absolute path to saved image
     * @throws IOException if file operations fail
     * @throws IllegalArgumentException if file is invalid
     */
    public String saveImage(MultipartFile file) throws IOException {
        // Validate file
        validateFile(file);

        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
            System.out.println("📁 Created upload directory: " + uploadPath.toAbsolutePath());
        }

        // Generate unique filename to prevent conflicts
        String originalFilename = file.getOriginalFilename();
        String fileExtension = getFileExtension(originalFilename);
        String uniqueFilename = UUID.randomUUID() + "." + fileExtension;

        // Save file to disk
        Path filePath = uploadPath.resolve(uniqueFilename);
        Files.copy(file.getInputStream(), filePath);

        return filePath.toAbsolutePath().toString();
    }

    /**
     * Validate uploaded file
     * @param file File to validate
     * @throws IllegalArgumentException if validation fails
     */
    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File size exceeds maximum limit of 10 MB");
        }

        String filename = file.getOriginalFilename();
        if (filename == null || filename.isEmpty()) {
            throw new IllegalArgumentException("Invalid filename");
        }

        String extension = getFileExtension(filename).toLowerCase();
        boolean isAllowed = false;
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (extension.equals(allowed)) {
                isAllowed = true;
                break;
            }
        }

        if (!isAllowed) {
            throw new IllegalArgumentException("File type not allowed. Only image files are permitted");
        }
    }

    /**
     * Extract file extension from filename
     * @param filename Original filename
     * @return File extension without dot
     */
    private String getFileExtension(String filename) {
        int lastDot = filename.lastIndexOf(".");
        if (lastDot == -1) {
            return "";
        }
        return filename.substring(lastDot + 1);
    }

    /**
     * Delete image file from disk
     * @param imagePath Path to image file
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteImage(String imagePath) {
        try {
            Path path = Paths.get(imagePath);
            if (Files.exists(path)) {
                Files.delete(path);
                System.out.println("🗑️  Image deleted: " + imagePath);
                return true;
            }
        } catch (IOException e) {
            System.err.println("Error deleting image: " + e.getMessage());
        }
        return false;
    }
}
