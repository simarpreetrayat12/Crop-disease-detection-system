package com.cropdetection.repository;

import com.cropdetection.entity.Prediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Prediction entity
 * Provides CRUD operations and custom database queries
 */
@Repository
public interface PredictionRepository extends JpaRepository<Prediction, Long> {

    /**
     * Find all predictions ordered by creation date (newest first)
     * @return List of predictions
     */
    List<Prediction> findAllByOrderByCreatedAtDesc();

    /**
     * Find predictions by disease name
     * @param disease Disease name
     * @return List of predictions with the specified disease
     */
    List<Prediction> findByDiseaseOrderByCreatedAtDesc(String disease);

    /**
     * Find predictions with confidence >= minConfidence
     * @param minConfidence Minimum confidence threshold
     * @return List of high-confidence predictions
     */
    List<Prediction> findByConfidenceGreaterThanEqualOrderByCreatedAtDesc(Double minConfidence);
}
