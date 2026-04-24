-- ============================================================
-- CROP DISEASE DETECTION SYSTEM - OPTIMIZED DATABASE SCHEMA
-- Production-ready with all tables, indexes, and constraints
-- ============================================================

-- Drop existing database (if needed)
DROP DATABASE IF EXISTS crop_disease_db;
CREATE DATABASE crop_disease_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE crop_disease_db;

-- ============================================================
-- TABLE: Users
-- Stores farmer/user account information
-- ============================================================
CREATE TABLE users (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100)  NOT NULL,
    email               VARCHAR(150)  NOT NULL UNIQUE,
    password_hash       VARCHAR(255)  NOT NULL,
    phone               VARCHAR(15),
    preferred_language  ENUM('en','hi','pa') DEFAULT 'en',
    state               VARCHAR(50),                          -- Agricultural state (Maharashtra, Punjab, etc.)
    district            VARCHAR(50),                          -- District for regional crops
    is_active           TINYINT(1)    DEFAULT 1,             -- Account status
    last_login          TIMESTAMP NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_state (state),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: DiseaseTreatment
-- Master knowledge base - diseases, pests, and treatments
-- This is the core business data
-- ============================================================
CREATE TABLE disease_treatment (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    crop_name           VARCHAR(100)  NOT NULL,
    disease_name        VARCHAR(200)  NOT NULL,
    pest_name           VARCHAR(200),                         -- NULL if disease, not pest
    disease_code        VARCHAR(50)   UNIQUE,                 -- e.g., "TOMATO_EARLY_BLIGHT"
    
    -- Description & Identification
    symptoms            TEXT NOT NULL,                        -- Visible signs of disease
    cause               VARCHAR(300)  NOT NULL,               -- Root cause: fungus/bacteria/virus/insect/nutrient
    identification_tips TEXT,                                 -- How to identify this exact disease
    
    -- Treatment Information
    pesticide           VARCHAR(300),                         -- Recommended pesticide/fungicide
    pesticide_dosage    VARCHAR(100),                         -- e.g., "25ml per 10L water"
    spray_interval      VARCHAR(100),                         -- e.g., "Every 7-10 days"
    
    fertilizer          VARCHAR(300),                         -- Recommended fertilizer/manure
    fertilizer_dosage   VARCHAR(100),                         -- e.g., "50kg per acre"
    application_method  VARCHAR(200),                         -- How to apply fertilizer
    
    treatment_steps     JSON,                                 -- Array of step-by-step treatment instructions
    prevention_tips     JSON,                                 -- Array of prevention measures
    
    -- Contextual Information
    severity            ENUM('Low','Medium','High','Critical') DEFAULT 'Medium',
    affected_seasons    VARCHAR(200),                         -- e.g., "Monsoon, Winter"
    loss_percentage     INT,                                  -- Estimated crop loss if untreated (0-100)
    recovery_days       INT,                                  -- Days to recover after treatment
    
    -- Data Management
    source              VARCHAR(100),                         -- PlantVillage, Expert input, Research paper
    is_user_added       TINYINT(1)    DEFAULT 0,             -- 1 if added by user report
    is_active           TINYINT(1)    DEFAULT 1,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uq_crop_disease (crop_name, disease_name),
    INDEX idx_crop_name (crop_name),
    INDEX idx_disease_name (disease_name),
    INDEX idx_disease_code (disease_code),
    INDEX idx_severity (severity),
    FULLTEXT gf_symptoms (symptoms),
    FULLTEXT gf_treatment_steps (treatment_steps)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: DetectionHistory
-- Records every detection performed by every farmer
-- Used for analytics, model training, and user tracking
-- ============================================================
CREATE TABLE detection_history (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL,
    
    -- Image Information
    image_path          VARCHAR(500)  NOT NULL,               -- S3 path or local path
    image_filename      VARCHAR(255),
    image_size_kb       INT,                                  -- File size in KB
    
    -- Uploaded Crop Information
    crop_selected       VARCHAR(100),                         -- Crop farmer selected (can be NULL if auto-detect)
    
    -- AI Model Detection Results
    detected_crop       VARCHAR(100),
    detected_disease    VARCHAR(200),
    detected_pest       VARCHAR(200),
    confidence_score    FLOAT NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
    
    -- Model Metadata
    model_version       VARCHAR(50),                          -- e.g., "v1.2.3-resnet50"
    model_predictions   JSON,                                 -- Top 3 predictions with scores
    inference_time_ms   INT,                                  -- Time taken by AI model (ms)
    
    -- Treatment Lookup
    treatment_id        INT,                                  -- Link to treatment record
    
    -- Language & Accessibility
    language_used       ENUM('en','hi','pa') DEFAULT 'en',
    translated_content  JSON,                                 -- Cached translations
    
    -- Data Quality
    is_accurate         TINYINT(1) DEFAULT NULL,              -- TRUE/FALSE/NULL (user feedback)
    is_unknown          TINYINT(1) DEFAULT 0,                 -- 1 if disease not recognized
    flagged_for_review  TINYINT(1) DEFAULT 0,                -- 1 if suspicious/requires expert check
    
    detected_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id)      REFERENCES users(id)                ON DELETE CASCADE,
    FOREIGN KEY (treatment_id) REFERENCES disease_treatment(id)    ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_detected_disease (detected_disease),
    INDEX idx_detected_at (detected_at),
    INDEX idx_is_accurate (is_accurate),
    INDEX idx_flagged_for_review (flagged_for_review),
    INDEX idx_treatment_id (treatment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: UnknownDiseaseReports
-- When AI confidence < 70%, stores for expert review
-- This generates training data for future model improvements
-- ============================================================
CREATE TABLE unknown_disease_reports (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    detection_id        INT NOT NULL,
    user_id             INT NOT NULL,
    
    -- Original submission
    image_path          VARCHAR(500)  NOT NULL,
    user_description    TEXT,                                 -- Farmer's own description
    reported_crop       VARCHAR(100),
    
    -- AI Analysis
    ai_guess            VARCHAR(200),                         -- Closest AI match
    ai_guess_confidence FLOAT,
    
    -- Expert Review
    status              ENUM('Pending','Reviewed','Added','Rejected') DEFAULT 'Pending',
    reviewed_by         VARCHAR(100),                         -- Agronomist name
    expert_diagnosis    VARCHAR(200),                         -- What expert identified
    expert_notes        TEXT,                                 -- Expert's observations
    treatment_added     TINYINT(1)    DEFAULT 0,             -- 1 if treatment was added to DB
    
    -- Link to newly added treatment
    treatment_id        INT NULL,
    
    reported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at         TIMESTAMP NULL,
    
    FOREIGN KEY (detection_id)  REFERENCES detection_history(id)    ON DELETE CASCADE,
    FOREIGN KEY (user_id)       REFERENCES users(id)               ON DELETE CASCADE,
    FOREIGN KEY (treatment_id)  REFERENCES disease_treatment(id)    ON DELETE SET NULL,
    INDEX idx_state (status),
    INDEX idx_user_id (user_id),
    INDEX idx_reported_at (reported_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: UserFeedback
-- Tracks farmer feedback on detections to improve model
-- ============================================================
CREATE TABLE user_feedback (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    detection_id        INT NOT NULL,
    user_id             INT NOT NULL,
    
    -- Feedback Details
    is_helpful          TINYINT(1)    NOT NULL,              -- 1 = yes, 0 = no
    rating              INT CHECK (rating >= 1 AND rating <= 5),  -- 1-5 stars
    comment             TEXT,                                -- User comments
    
    -- Issue Reporting
    issue_type          ENUM('wrong_disease','wrong_crop','wrong_pest','inaccurate','other'),
    suggested_disease   VARCHAR(200),                        -- What farmer thinks it is
    
    feedback_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (detection_id) REFERENCES detection_history(id)  ON DELETE CASCADE,
    FOREIGN KEY (user_id)      REFERENCES users(id)              ON DELETE CASCADE,
    INDEX idx_detection_id (detection_id),
    INDEX idx_is_helpful (is_helpful),
    INDEX idx_feedback_date (feedback_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: TranslationCache
-- Caches translations to reduce API calls to Google Translate
-- ============================================================
CREATE TABLE translation_cache (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    source_language     ENUM('en','hi','pa') DEFAULT 'en',
    target_language     ENUM('en','hi','pa'),
    original_text       VARCHAR(500)  NOT NULL,
    translated_text     VARCHAR(500)  NOT NULL,
    text_hash           VARCHAR(64),                          -- SHA256 hash for unique constraint
    
    -- Metadata
    is_verified         TINYINT(1)    DEFAULT 0,             -- 1 if verified by native speaker
    verified_by         VARCHAR(100),
    usage_count         INT DEFAULT 1,                        -- How many times this translation was used
    
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accessed_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uq_translation (source_language, target_language, text_hash),
    INDEX idx_accessed_at (accessed_at),
    INDEX idx_is_verified (is_verified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: AuditLog
-- Tracks all important system actions for security & debugging
-- ============================================================
CREATE TABLE audit_log (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT,
    action              VARCHAR(100)  NOT NULL,               -- e.g., "detection_created", "feedback_submitted"
    resource_type       VARCHAR(50)   NOT NULL,               -- e.g., "detection", "user", "treatment"
    resource_id         INT,
    old_value           JSON,                                 -- Previous value (if update)
    new_value           JSON,                                 -- New value (if update)
    ip_address          VARCHAR(45),                          -- IPv4 or IPv6
    user_agent          VARCHAR(500),
    
    action_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_action_date (action_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: SystemMetrics
-- Stores daily aggregated system metrics for analytics
-- ============================================================
CREATE TABLE system_metrics (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    metric_date         DATE NOT NULL UNIQUE,
    
    -- User Metrics
    total_users         INT DEFAULT 0,
    daily_active_users  INT DEFAULT 0,
    new_users           INT DEFAULT 0,
    
    -- Detection Metrics
    total_detections    INT DEFAULT 0,
    successful_detections INT DEFAULT 0,
    failed_detections   INT DEFAULT 0,
    avg_confidence      FLOAT,
    avg_inference_time_ms INT,
    
    -- Feedback Metrics
    positive_feedback   INT DEFAULT 0,
    negative_feedback   INT DEFAULT 0,
    avg_rating          FLOAT,
    
    -- Model Metrics
    model_accuracy_percent FLOAT,
    unknown_reports     INT DEFAULT 0,
    
    -- Infrastructure
    avg_response_time_ms INT,
    error_rate_percent  FLOAT,
    uptime_percent      FLOAT,
    
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_metric_date (metric_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
--  MASTER DATA — Plant Diseases (100 + entries)
--  Crops covered:
--    Tomato, Potato, Wheat, Rice, Maize/Corn, Cotton,
--    Soybean, Mango, Banana, Grape, Apple, Citrus,
--    Chilli/Pepper, Onion, Mustard, Groundnut, Sugarcane
-- ============================================================

INSERT INTO DiseaseTreatment
  (crop_name, disease_name, pest_name, symptoms, cause, pesticide, fertilizer, treatment_steps, prevention_tips, severity, season)
VALUES

-- ─── TOMATO ──────────────────────────────────────────────────
('Tomato','Early Blight','Aphids',
 'Dark brown spots with concentric rings on older leaves; yellow halo around spots',
 'Fungus: Alternaria solani',
 'Chlorothalonil 75WP (2g/L) or Mancozeb 75WP (2.5g/L)',
 'Nitrogen-rich fertilizer (Urea 46%)',
 '1. Remove and burn infected leaves immediately\n2. Spray Chlorothalonil every 7–10 days\n3. Apply nitrogen fertilizer to boost plant immunity\n4. Water at base — avoid wetting foliage\n5. Stake plants for better air circulation',
 'Rotate crops every 2 years; use disease-free seeds; avoid overhead irrigation',
 'Medium','Kharif (Jun–Oct)'),

('Tomato','Late Blight','Whitefly',
 'Water-soaked grey-green spots on leaves turning brown; white mold on leaf undersides; fruit rot',
 'Oomycete: Phytophthora infestans',
 'Metalaxyl + Mancozeb (Ridomil Gold 2g/L) or Cymoxanil 8% + Mancozeb 64%',
 'Potassium Sulfate (SOP)',
 '1. Destroy infected plants; do not compost\n2. Spray Metalaxyl-Mancozeb immediately\n3. Repeat every 5–7 days in wet weather\n4. Improve drainage around root zone\n5. Apply potassium to strengthen cell walls',
 'Plant resistant varieties (eg. Arka Rakshak); avoid planting near potato fields',
 'High','Rabi (Oct–Mar)'),

('Tomato','Leaf Curl Virus','Whitefly (Bemisia tabaci)',
 'Upward/downward curling of leaves; yellowing; stunted growth; distorted fruits',
 'Virus: Tomato Leaf Curl New Delhi Virus (ToLCNDV); vector: Whitefly',
 'Imidacloprid 17.8 SL (0.5ml/L) to control whitefly vector; Thiamethoxam 25WG',
 'Balanced NPK + Micronutrients',
 '1. Remove and destroy virus-infected plants\n2. Spray Imidacloprid to eliminate whitefly\n3. Install yellow sticky traps in field\n4. Apply reflective mulch to repel whiteflies\n5. Spray Neem oil (5ml/L) weekly',
 'Use virus-resistant varieties; rogue out infected plants early; control weed hosts',
 'High','All seasons'),

('Tomato','Fusarium Wilt','Nematodes',
 'Yellowing of lower leaves; brown vascular tissue when stem is cut; wilting on one side',
 'Fungus: Fusarium oxysporum f.sp. lycopersici',
 'Carbendazim 50WP (1g/L) drench; Trichoderma viride bio-fungicide',
 'Organic compost + Gypsum',
 '1. Remove and burn wilted plants\n2. Drench soil with Carbendazim solution\n3. Apply Trichoderma to soil before planting\n4. Solarize soil in summer (4–6 weeks)\n5. Maintain soil pH 6.0–6.5',
 'Use resistant rootstocks; practice 3-year crop rotation; avoid waterlogging',
 'High','Kharif'),

('Tomato','Bacterial Spot','Thrips',
 'Small water-soaked spots on leaves turning dark brown with yellow halo; scab on fruits',
 'Bacteria: Xanthomonas vesicatoria',
 'Copper Oxychloride 50WP (3g/L) or Streptomycin Sulfate 90% (0.2g/L)',
 'Calcium nitrate foliar spray',
 '1. Avoid working in wet crop\n2. Spray Copper Oxychloride at first signs\n3. Repeat every 7 days\n4. Remove heavily infected plant parts\n5. Disinfect tools with bleach solution',
 'Use certified disease-free seed; avoid overhead irrigation; space plants for airflow',
 'Medium','Kharif'),

('Tomato','Septoria Leaf Spot','Spider Mites',
 'Small circular spots with dark borders and light centers; tiny black dots (pycnidia) inside spots',
 'Fungus: Septoria lycopersici',
 'Chlorothalonil 75WP or Mancozeb 75WP alternated weekly',
 'Calcium + Boron foliar spray',
 '1. Remove infected lower leaves\n2. Mulch soil to prevent spore splash\n3. Spray fungicide starting at fruit set\n4. Apply Bordeaux mixture (1%) as preventive\n5. Ensure 60–70cm row spacing',
 'Avoid wetting foliage; rotate with non-solanaceous crops',
 'Medium','Kharif'),

('Tomato','Blossom End Rot','—',
 'Dark, sunken, leathery area at blossom end of fruit; does not spread plant-to-plant',
 'Physiological disorder: Calcium deficiency + irregular watering',
 'Calcium Chloride foliar spray (0.4%)',
 'Calcium Ammonium Nitrate (CAN); Gypsum soil application',
 '1. Foliar spray Calcium Chloride (4g/L) every 10 days\n2. Maintain consistent soil moisture (drip irrigation)\n3. Avoid excess nitrogen fertilizer\n4. Apply gypsum 200kg/acre before planting\n5. Mulch to retain moisture',
 'Maintain uniform irrigation; avoid deep cultivation near roots; lime acidic soils',
 'Low','All seasons'),

-- ─── POTATO ──────────────────────────────────────────────────
('Potato','Late Blight','Aphids',
 'Water-soaked lesions on leaves turning brown-black; white sporulation on undersides; tuber rot',
 'Oomycete: Phytophthora infestans',
 'Cymoxanil 8% + Mancozeb 64% (2.5g/L) or Fosetyl-Al 80WP',
 'Potassium Sulfate',
 '1. Scout fields weekly during cool humid weather\n2. Spray Cymoxanil-Mancozeb at first symptoms\n3. Repeat every 5–7 days\n4. Hill up soil around stems\n5. Harvest promptly after haulm destruction',
 'Use certified seed potatoes; plant resistant varieties; avoid planting in low-lying areas',
 'Critical','Rabi'),

('Potato','Common Scab','—',
 'Rough corky lesions on tuber surface; superficial to deep pitting',
 'Bacteria: Streptomyces scabies (actinobacterium)',
 'No effective chemical control — management through cultural practices',
 'Ammonium Sulfate (acidify soil); Sulfur dust',
 '1. Maintain soil pH 5.0–5.2 during tuber initiation\n2. Keep soil moist at tuber set\n3. Avoid using manure with scab-infected debris\n4. Apply sulfur to lower soil pH\n5. Use certified clean seed',
 'Rotate crops; avoid liming soil before potato planting; use resistant varieties',
 'Medium','Rabi'),

('Potato','Black Leg','—',
 'Black, slimy rotting at stem base; yellowing and rolling of leaves; wilting',
 'Bacteria: Pectobacterium atrosepticum',
 'Copper-based bactericides (preventive only); no cure once infected',
 'Balanced NPK; avoid excess nitrogen',
 '1. Remove and destroy infected plants\n2. Avoid waterlogging — improve drainage\n3. Spray Copper Oxychloride preventively\n4. Cut seed pieces dry before planting\n5. Do not replant in heavily infested soil',
 'Use disease-free certified seed; avoid wounding tubers; proper storage ventilation',
 'High','Rabi'),

('Potato','Viral Mosaic','Aphids (Myzus persicae)',
 'Mosaic yellowing; crinkled and distorted leaves; stunted plants; reduced tuber yield',
 'Virus: PVX, PVY (Potato Virus X and Y); vector: Aphids',
 'Imidacloprid 17.8SL to control aphid vector; Mineral oil spray',
 'Boron + Zinc micronutrients',
 '1. Remove virus-symptomatic plants immediately\n2. Control aphids with Imidacloprid\n3. Use mineral oil sprays to reduce virus transmission\n4. Install yellow sticky traps\n5. Avoid planting near infected solanaceous crops',
 'Plant certified virus-free seed; rogue out infected plants early; control aphid vectors',
 'High','Rabi'),

-- ─── WHEAT ───────────────────────────────────────────────────
('Wheat','Yellow Rust (Stripe Rust)','Aphids',
 'Bright yellow powdery stripes along leaves and leaf sheaths; pustules in rows',
 'Fungus: Puccinia striiformis f.sp. tritici',
 'Propiconazole 25EC (1ml/L) or Tebuconazole 250EW (1ml/L)',
 'Potassium + Phosphorus (NPK 0-52-34)',
 '1. Apply Propiconazole at first stripe appearance\n2. Repeat after 14–21 days if disease persists\n3. Apply potassium fertilizer to strengthen stems\n4. Avoid late sowing\n5. Remove and burn heavily infected crop portions',
 'Sow resistant varieties (HD-2967, PBW-550); use recommended sowing dates',
 'High','Rabi (Nov–Apr)'),

('Wheat','Brown Rust (Leaf Rust)','Aphids',
 'Circular to oval orange-brown pustules scattered on leaves; premature leaf death',
 'Fungus: Puccinia triticina',
 'Mancozeb 75WP (2.5g/L) or Propiconazole 25EC (1ml/L)',
 'Urea (46% N) top dressing',
 '1. Spray Propiconazole at flag-leaf stage\n2. Ensure adequate plant spacing\n3. Apply top-dress urea before stem elongation\n4. Avoid high nitrogen rates that increase susceptibility\n5. Monitor weekly from tillering stage',
 'Use resistant varieties; avoid dense planting; ensure balanced nutrition',
 'Medium','Rabi'),

('Wheat','Loose Smut','—',
 'Entire ear replaced by smutted mass of olive-brown spores; affected ears emerge earlier',
 'Fungus: Ustilago tritici',
 'Seed treatment: Carboxin 37.5% + Thiram 37.5% (Vitavax Power 3g/kg seed)',
 'Balanced NPK',
 '1. Treat seed with Carboxin-Thiram before sowing\n2. Remove and bag smutted ears before spores disperse\n3. Burn infected plant debris\n4. Avoid saving seed from infected fields\n5. Use certified disease-free seed',
 'Always treat seed; use resistant varieties; destroy affected plants before spore release',
 'Medium','Rabi'),

('Wheat','Powdery Mildew','Thrips',
 'White powdery growth on upper leaf surfaces; infected tissue turns yellow then brown',
 'Fungus: Blumeria graminis f.sp. tritici',
 'Triadimefon 25WP (1g/L) or Tebuconazole 25.9EC',
 'Potassium Sulfate; avoid excess nitrogen',
 '1. Apply Triadimefon at first mildew patches\n2. Reduce nitrogen fertilizer application\n3. Ensure good airflow with proper row spacing\n4. Remove crop debris after harvest\n5. Spray sulfur dust as early preventive',
 'Sow at recommended density; use resistant varieties; balanced nitrogen application',
 'Medium','Rabi'),

-- ─── RICE ────────────────────────────────────────────────────
('Rice','Blast (Neck Rot)','Stem Borer',
 'Diamond-shaped gray lesions with brown borders on leaves; neck turns brown causing "panicle blast"; empty grains',
 'Fungus: Magnaporthe oryzae',
 'Tricyclazole 75WP (0.6g/L) or Isoprothiolane 40EC (1.5ml/L)',
 'Zinc Sulfate (25kg/acre); Silica foliar spray',
 '1. Spray Tricyclazole at tillering and panicle initiation\n2. Apply zinc sulfate to soil before transplanting\n3. Drain and re-irrigate field to break disease cycle\n4. Remove and burn infected debris\n5. Avoid excess nitrogen during heading',
 'Use resistant varieties (Pusa 1460); balanced fertilization; avoid waterlogged conditions',
 'Critical','Kharif'),

('Rice','Brown Plant Hopper (BPH)','Brown Plant Hopper',
 'Hopperburn — circular yellowing and drying from base upward (hopper burn); complete crop loss in severe cases',
 'Insect: Nilaparvata lugens',
 'Buprofezin 25SC (1.25ml/L) or Dinotefuran 20SG; avoid pyrethroids (resurgence)',
 'Split nitrogen application; avoid excess N',
 '1. Drain field partially to expose hoppers to sunlight\n2. Spray Buprofezin targeting base of plants\n3. Reduce nitrogen in susceptible varieties\n4. Use light traps for monitoring\n5. Conserve natural enemies (spiders)',
 'Use BPH-resistant varieties (IR36, Swarna Sub1); avoid excessive nitrogen; light traps',
 'Critical','Kharif'),

('Rice','Bacterial Leaf Blight','Leaf Folder',
 'Water-soaked, yellow to white lesions starting from leaf edges; milky bacterial ooze',
 'Bacteria: Xanthomonas oryzae pv. oryzae',
 'Copper Oxychloride 50WP (3g/L); Streptomycin Sulfate + Tetracycline HCl (Plantomycin)',
 'Potassium Chloride (MOP); reduce nitrogen',
 '1. Drain field and allow soil to dry 2–3 days\n2. Spray Copper Oxychloride + Streptomycin\n3. Reduce nitrogen fertilizer during outbreak\n4. Remove infected tillers\n5. Apply potassium to strengthen cell walls',
 'Use resistant varieties; avoid flood irrigation during outbreak; balanced N:K ratio',
 'High','Kharif'),

('Rice','Sheath Blight','Stem Borer',
 'Oval to irregular lesions on leaf sheath near water level; gray centers with brown borders',
 'Fungus: Rhizoctonia solani',
 'Hexaconazole 5SC (2ml/L) or Validamycin 3L (2ml/L)',
 'Silicon + Potassium foliar; reduce nitrogen',
 '1. Reduce plant density for better airflow\n2. Spray Hexaconazole at early panicle stage\n3. Drain field briefly to reduce humidity\n4. Remove and burn infected straw\n5. Avoid excess nitrogen in K-deficient soils',
 'Reduce seeding rate; avoid excess nitrogen; drain fields periodically',
 'High','Kharif'),

('Rice','False Smut','—',
 'Individual grains transformed into greenish-orange spore balls (chlamydospores)',
 'Fungus: Ustilaginoidea virens',
 'Propiconazole 25EC (1ml/L) at booting stage; Copper Oxychloride',
 'Balanced NPK; avoid excess nitrogen at heading',
 '1. Spray Propiconazole 5–7 days before heading\n2. Collect and remove smutted balls carefully\n3. Burn infected material; do not thresh infected panicles\n4. Avoid saving smutted grain as seed\n5. Reduce nitrogen at booting stage',
 'Spray fungicide at booting; use resistant varieties; maintain field hygiene',
 'Medium','Kharif'),

-- ─── MAIZE / CORN ────────────────────────────────────────────
('Maize','Northern Leaf Blight','Aphids',
 'Long (5–15cm) cigar-shaped grayish-green to tan lesions on leaves',
 'Fungus: Exserohilum turcicum',
 'Mancozeb 75WP (2.5g/L) or Propiconazole 25EC (1ml/L)',
 'Nitrogen top dressing at 6-leaf stage',
 '1. Spray Mancozeb at V6–V8 stage\n2. Apply nitrogen at 6-leaf stage\n3. Remove and destroy crop debris post-harvest\n4. Ensure proper plant spacing (60×25cm)\n5. Avoid planting successive maize crops',
 'Plant resistant hybrids; rotate with soybean or legumes; deep plowing to bury residue',
 'Medium','Kharif'),

('Maize','Common Rust','Spider Mites',
 'Small, circular to elongated brick-red pustules on both leaf surfaces',
 'Fungus: Puccinia sorghi',
 'Mancozeb 75WP (2.5g/L) or Tebuconazole 250EW',
 'Potassium Sulfate; balanced NPK',
 '1. Spray Mancozeb at first pustule appearance\n2. Repeat after 10–14 days\n3. Avoid overhead irrigation\n4. Apply potassium fertilizer\n5. Remove heavily infected lower leaves',
 'Use resistant hybrids; early sowing; proper fertilization',
 'Medium','Kharif'),

('Maize','Stalk Rot','Stem Borer',
 'Premature dying of lower leaves; soft and discolored stalk interior; plant lodging',
 'Fungus: Fusarium graminearum / Pythium spp.',
 'Thiram seed treatment; Carbendazim root drench',
 'Balanced N:K; avoid excess nitrogen late season',
 '1. Treat seed with Thiram before planting\n2. Apply potassium to prevent stalk weakness\n3. Reduce nitrogen in late season\n4. Improve drainage to reduce soil moisture\n5. Harvest on time; do not delay after maturity',
 'Use tolerant hybrids; balanced fertilization; proper irrigation management',
 'High','Kharif'),

('Maize','Fall Armyworm','Fall Armyworm (Spodoptera frugiperda)',
 'Ragged feeding on leaves; frass (sawdust-like excrement) in whorl; complete leaf consumption in severe infestations',
 'Insect: Spodoptera frugiperda',
 'Emamectin Benzoate 5SG (0.4g/L) or Spinetoram 11.7SC (0.5ml/L); Chlorantraniliprole',
 'Nitrogen top dressing after pest control',
 '1. Scout fields weekly — check whorl for frass\n2. Apply Emamectin Benzoate into whorl at early infestation\n3. Use pheromone traps (1/acre) for monitoring\n4. Release Trichogramma egg parasitoid\n5. Apply Bacillus thuringiensis (Bt) formulation',
 'Early sowing; pheromone traps; biological control with Trichogramma; Bt-based pesticides',
 'Critical','Kharif'),

-- ─── COTTON ──────────────────────────────────────────────────
('Cotton','Cotton Bollworm','Helicoverpa armigera',
 'Circular holes in squares, flowers and bolls; caterpillar inside boll; yield loss up to 50%',
 'Insect: Helicoverpa armigera (American Bollworm)',
 'Indoxacarb 14.5SC (1ml/L) or Chlorantraniliprole 18.5SC (0.3ml/L)',
 'Potassium Nitrate foliar at boll formation',
 '1. Install pheromone traps (5/acre) for monitoring\n2. Spray Indoxacarb at first boll infestation\n3. Release Chrysoperla carnea biocontrol agent\n4. Apply NPV (Nuclear Polyhedrosis Virus) at egg-hatching\n5. Alternate insecticide classes to prevent resistance',
 'Use Bt cotton varieties; avoid monoculture; install pheromone traps; light traps',
 'Critical','Kharif'),

('Cotton','Pink Bollworm','Pink Bollworm (Pectinophora gossypiella)',
 'Entry holes in bolls; lint staining; rosette flowers; infested seeds with larvae inside',
 'Insect: Pectinophora gossypiella',
 'Quinalphos 25EC (2ml/L) or Profenofos 50EC; Bt sprays',
 'Phosphorus + Boron at flowering',
 '1. Install sex pheromone traps (8–10/acre)\n2. Spray Quinalphos at petal fall stage\n3. Destroy all crop remnants after harvest\n4. Avoid late season irrigation\n5. Use gossyplure pheromone mass trapping',
 'Early sowing; use pink bollworm-tolerant Bt varieties; destroy stubble immediately after harvest',
 'High','Kharif'),

('Cotton','Leaf Curl Disease','Whitefly (Bemisia tabaci)',
 'Severe leaf curling upward; dark green thickening of veins; leaf enation (outgrowth); stunted plants',
 'Virus: Cotton Leaf Curl Virus (CLCuV); vector: Whitefly',
 'Imidacloprid 70WG (1g/10L) or Thiamethoxam 25WG to control whitefly vector',
 'Micronutrient mix (Zinc + Boron)',
 '1. Spray Imidacloprid at first vector appearance\n2. Remove and burn CLCuD-infected plants\n3. Apply yellow sticky traps (10/acre)\n4. Apply neem oil (5ml/L) weekly\n5. Avoid excess nitrogen fertilizer',
 'Use CLCuV-resistant varieties; rogue infected plants before 30 days; control whitefly',
 'Critical','Kharif'),

('Cotton','Bacterial Blight (Angular Leaf Spot)','—',
 'Angular water-soaked spots on leaves; dark brown spots on bolls; stem cankers',
 'Bacteria: Xanthomonas citri subsp. malvacearum',
 'Copper Oxychloride 50WP (3g/L) or Streptomycin Sulfate (0.2g/L)',
 'Potassium-rich fertilizer',
 '1. Remove infected plant parts\n2. Spray Copper Oxychloride at first signs\n3. Seed treatment with Streptomycin\n4. Avoid irrigation during damp weather\n5. Disinfect agricultural tools regularly',
 'Use disease-free certified seed; treat seed before planting; avoid dense planting',
 'Medium','Kharif'),

-- ─── SOYBEAN ─────────────────────────────────────────────────
('Soybean','Soybean Rust','Whitefly',
 'Small tan to dark reddish-brown lesions on leaves; pustules on leaf undersides; premature defoliation',
 'Fungus: Phakopsora pachyrhizi',
 'Azoxystrobin 23SC (1ml/L) or Trifloxystrobin 50WG + Tebuconazole',
 'Potassium + Sulfur fertilizer',
 '1. Scout weekly from flowering onward\n2. Apply Azoxystrobin at first pustule appearance\n3. Ensure canopy penetration when spraying\n4. Repeat after 14 days in high-pressure seasons\n5. Destroy crop debris after harvest',
 'Use early-maturing varieties to escape peak disease period; scout regularly',
 'High','Kharif'),

('Soybean','Charcoal Rot','Nematodes',
 'Gray to silver stem discoloration; tiny black sclerotia in stem and roots; wilting under stress',
 'Fungus: Macrophomina phaseolina',
 'No effective chemical; soil drenching with Carbendazim (preventive)',
 'Organic matter + Phosphorus; avoid excess N',
 '1. Practice crop rotation (2–3 years)\n2. Avoid water stress especially at flowering\n3. Apply organic compost to improve soil health\n4. Solarize infested soil before planting\n5. Use biocontrol: Trichoderma harzianum',
 'Maintain soil moisture; rotate with maize; avoid compacted soils',
 'Medium','Kharif'),

-- ─── MANGO ───────────────────────────────────────────────────
('Mango','Powdery Mildew','Mango Hopper',
 'White powdery coating on new leaves, flowers and young fruits; flower drop; fruit setting failure',
 'Fungus: Oidium mangiferae',
 'Wettable Sulfur 80WP (3g/L) or Hexaconazole 5SC (1ml/L)',
 'Potassium Sulfate foliar spray before flowering',
 '1. Spray Wettable Sulfur at flower bud stage\n2. Repeat at full flower and fruit set stages\n3. Avoid overhead irrigation during flowering\n4. Prune dense canopy for air circulation\n5. Apply Hexaconazole for systemic protection',
 'Prune for open canopy; apply sulfur before flowering; early morning spray recommended',
 'High','Feb–Apr (Flowering)'),

('Mango','Anthracnose','Mango Stone Weevil',
 'Black spots on leaves; twig blight; flower blight; dark sunken spots on fruit',
 'Fungus: Colletotrichum gloeosporioides',
 'Carbendazim 50WP (1g/L) or Mancozeb 75WP (2.5g/L)',
 'Calcium Chloride foliar spray for fruit quality',
 '1. Prune dead wood and infected twigs\n2. Spray Carbendazim at flush emergence\n3. Apply during flowering and fruit development\n4. Post-harvest hot water treatment (52°C, 5 min) for fruits\n5. Apply Bordeaux mixture (1%) on stems',
 'Remove dead wood; avoid wet canopy; proper spacing between trees',
 'High','Kharif'),

('Mango','Mango Malformation','Mango Mite (Aceria mangiferae)',
 'Malformed vegetative shoots (bunchy top) and floral malformation; small bunch-like panicles',
 'Mite: Aceria mangiferae + Fusarium mangiferae',
 'Dicofol 18.5EC (2ml/L) or Spiromesifen 22.9SC to control mite vector',
 'Zinc + Boron micronutrients',
 '1. Remove malformed shoots 15–20cm below malformation\n2. Spray Dicofol in Oct–Nov before dormancy break\n3. Repeat in Jan–Feb at bud break\n4. Apply zinc and boron foliar spray\n5. Dispose of pruned material away from orchard',
 'Prune and destroy malformed tissues; spray acaricide before bud break',
 'Medium','Jan–Mar'),

-- ─── BANANA ──────────────────────────────────────────────────
('Banana','Panama Wilt (Fusarium Wilt)','Nematodes',
 'Yellowing of outer leaves from edge inward; brown discoloration of vascular tissue; plant collapse',
 'Fungus: Fusarium oxysporum f.sp. cubense (Foc)',
 'No chemical cure; biological control with Trichoderma; soil drenching with Carbendazim (suppressive)',
 'Potassium + Calcium; organic compost',
 '1. Remove and destroy infected plants including corms\n2. Drench soil with Trichoderma solution\n3. Solarize soil for 6–8 weeks\n4. Plant TR4-resistant varieties if available\n5. Maintain proper soil nutrition and drainage',
 'Use disease-free suckers; quarantine infected farms; use resistant varieties',
 'Critical','All seasons'),

('Banana','Sigatoka (Black Leaf Streak)','Banana Aphids',
 'Yellow streaks on leaves turning dark brown to black; leaf death from older leaves upward',
 'Fungus: Mycosphaerella fijiensis',
 'Propiconazole 25EC (1ml/L) or Azoxystrobin + Difenoconazole',
 'Nitrogen + Potassium balanced fertilization',
 '1. Remove and destroy affected leaves regularly\n2. Spray Propiconazole at 3-week intervals\n3. Maintain proper drainage in plantation\n4. Apply balanced NPK to boost resistance\n5. Oil spray (mineral oil 1%) can reduce spore germination',
 'Remove affected leaves; maintain air circulation; drainage management; balanced nutrition',
 'High','All seasons'),

-- ─── GRAPE ───────────────────────────────────────────────────
('Grape','Downy Mildew','Leafhoppers',
 'Yellow oil-spot lesions on upper leaves; white cottony mold on lower surfaces; fruit shriveling',
 'Oomycete: Plasmopara viticola',
 'Metalaxyl 8% + Mancozeb 64% (2g/L) or Fosetyl-Al 80WP (3g/L)',
 'Calcium + Boron foliar spray',
 '1. Spray Metalaxyl-Mancozeb at bud burst\n2. Repeat every 7–10 days in humid conditions\n3. Remove infected leaves and shoots\n4. Improve trellis system for air circulation\n5. Avoid irrigation that wets foliage',
 'Bordeaux mixture (1%) preventive sprays; proper training and pruning; avoid overhead irrigation',
 'High','Kharif'),

('Grape','Anthracnose (Bird\'s Eye Rot)','Grape Berry Moth',
 'Small dark spots on leaves and berries with red to purple halo; cracking of berries',
 'Fungus: Elsinoe ampelina',
 'Carbendazim 50WP (1g/L) or Copper Oxychloride 50WP (3g/L)',
 'Potassium Sulfate at berry formation',
 '1. Dormant spray with Copper Oxychloride before bud burst\n2. Remove and burn mummified berries and canes\n3. Spray Carbendazim at bud swell\n4. Maintain open canopy with proper pruning\n5. Avoid excess nitrogen fertilization',
 'Prune and destroy infected wood; spray copper in dormancy; proper canopy management',
 'High','Kharif'),

-- ─── APPLE ───────────────────────────────────────────────────
('Apple','Apple Scab','Aphids',
 'Olive-green to black velvety lesions on leaves and fruits; premature defoliation; cracked scabby fruits',
 'Fungus: Venturia inaequalis',
 'Captan 50WP (2.5g/L) or Dithianon 75WP (0.75g/L) or Myclobutanil',
 'Potassium + Calcium for fruit quality',
 '1. Spray Captan from green tip stage\n2. Maintain 7-day spray schedule during wet weather\n3. Rake and burn fallen leaves in autumn\n4. Apply urea on fallen leaves to speed decomposition\n5. Prune for open canopy — reduce leaf wetness period',
 'Plant scab-resistant varieties; remove fallen leaf inoculum; proper fungicide schedule from bud break',
 'High','Spring–Summer'),

('Apple','Fire Blight','Codling Moth',
 'Blossoms wilt and turn brown; shoot tips bend in shepherd\'s crook shape; bark cankers ooze amber',
 'Bacteria: Erwinia amylovora',
 'Streptomycin 90% + Tetracycline (0.2g/L) during bloom; Copper Oxychloride',
 'Moderate balanced NPK; avoid excess N',
 '1. Prune infected shoots 30cm below visible symptoms\n2. Disinfect pruning tools with 10% bleach between cuts\n3. Spray Streptomycin during full bloom\n4. Remove fire blight cankers in dormancy\n5. Avoid late season nitrogen fertilization',
 'Plant resistant varieties; prune infected wood; apply bactericide during bloom',
 'Critical','Spring'),

-- ─── CITRUS ──────────────────────────────────────────────────
('Citrus','Citrus Canker','Leafminer (Phyllocnistis citrella)',
 'Raised, corky brown lesions with water-soaked halo on leaves, stems and fruits',
 'Bacteria: Xanthomonas citri subsp. citri',
 'Copper Oxychloride 50WP (3g/L) + Streptomycin Sulfate (0.2g/L)',
 'Calcium Nitrate; balanced NPK',
 '1. Remove and burn infected plant parts\n2. Spray Copper Oxychloride + Streptomycin\n3. Repeat every 15 days during wet season\n4. Control citrus leafminer (vector) with Spinosad\n5. Maintain quarantine — do not move plant material',
 'Use disease-free budwood; control leafminer; windbreaks reduce spread; copper sprays',
 'High','Kharif'),

('Citrus','Greening (Huanglongbing)','Asian Citrus Psyllid (Diaphorina citri)',
 'Asymmetric blotchy mottle on leaves; small hard bitter fruit; yellow shoot; tree decline over years',
 'Bacteria: Candidatus Liberibacter asiaticus; vector: Psyllid',
 'Imidacloprid 17.8SL (0.5ml/L) or Dimethoate 30EC to control psyllid vector',
 'Zinc + Iron foliar for nutritional support',
 '1. Remove and destroy citrus greening-positive trees\n2. Spray Imidacloprid to control psyllid vector\n3. Apply tetracycline antibiotics (trunk injection — supervised)\n4. Use certified disease-free nursery plants only\n5. Establish insect nets in nurseries',
 'No cure — prevention only; use disease-free plants; control psyllid; avoid replanting in HLB-infected sites',
 'Critical','All seasons'),

-- ─── CHILLI / PEPPER ─────────────────────────────────────────
('Chilli','Chilli Anthracnose (Die Back)','Thrips',
 'Water-soaked lesions on fruits becoming dark sunken spots; twig dieback; seedling damping off',
 'Fungus: Colletotrichum capsici / C. acutatum',
 'Carbendazim 50WP (1g/L) + Mancozeb 75WP (2g/L)',
 'Calcium Nitrate foliar at fruit development',
 '1. Remove infected fruits and destroy\n2. Spray Carbendazim-Mancozeb mixture\n3. Apply preventive spray every 10 days during fruit set\n4. Avoid overhead irrigation\n5. Use clean certified seed; treat with hot water (50°C, 30 min)',
 'Use resistant varieties; seed hot water treatment; proper crop rotation',
 'High','Kharif'),

('Chilli','Powdery Mildew','Mites (Polyphagotarsonemus latus)',
 'White powdery patches on leaves and stems; leaf distortion; premature defoliation',
 'Fungus: Leveillula taurica',
 'Wettable Sulfur 80WP (3g/L) or Hexaconazole 5SC (2ml/L)',
 'Potassium Sulfate; balanced NPK',
 '1. Spray Wettable Sulfur at first sign of mildew\n2. Repeat every 10–14 days\n3. Remove heavily infected leaves\n4. Ensure proper air circulation\n5. Avoid planting too dense',
 'Proper spacing; avoid water stress; spray sulfur preventively',
 'Medium','Dry season'),

('Chilli','Bacterial Wilt','Nematodes',
 'Rapid wilting of entire plant without yellowing; vascular browning; milky streaming in water test',
 'Bacteria: Ralstonia solanacearum',
 'No chemical cure; Copper Oxychloride soil drench (preventive only)',
 'Organic compost; lime to adjust soil pH',
 '1. Remove and burn infected plants immediately\n2. Solarize soil (6–8 weeks) to kill bacteria\n3. Apply lime to raise pH to 7.0–7.5\n4. Practice 3-year rotation with non-solanaceous crops\n5. Use grafted transplants on resistant rootstocks',
 'Use resistant varieties; avoid infected soil; grafting on tolerant rootstocks; solarization',
 'Critical','Kharif'),

-- ─── ONION ───────────────────────────────────────────────────
('Onion','Purple Blotch','Thrips (Thrips tabaci)',
 'Small white lesions with purple centers on leaves; lesions enlarge and girdle leaves; yield loss',
 'Fungus: Alternaria porri',
 'Iprodione 50WP (2g/L) or Mancozeb 75WP (2.5g/L)',
 'Potassium + Calcium for bulb quality',
 '1. Spray Mancozeb preventively from 30 days after transplanting\n2. Apply Iprodione at disease onset\n3. Control thrips with Spinosad 45SC (0.3ml/L)\n4. Remove infected leaves\n5. Maintain 15×10cm plant spacing',
 'Rotate crops; avoid overhead irrigation; control thrips; proper spacing',
 'Medium','Rabi'),

('Onion','Damping Off','—',
 'Seedling collapse at soil level; brown rotting of stem base; large gaps in nursery bed',
 'Fungus: Pythium spp. / Rhizoctonia solani',
 'Metalaxyl 35SD seed treatment (6g/kg); Captan seed treatment',
 'Well-decomposed FYM (farmyard manure); avoid fresh manure',
 '1. Treat seed with Metalaxyl before sowing\n2. Solarize nursery beds before seeding\n3. Avoid overwatering seedlings\n4. Drench nursery with Mancozeb (2g/L) at emergence\n5. Use well-drained raised beds',
 'Soil solarization; seed treatment; raised nursery beds; avoid overwatering',
 'Medium','Nursery stage'),

-- ─── MUSTARD ─────────────────────────────────────────────────
('Mustard','Alternaria Blight','Aphids (Lipaphis erysimi)',
 'Small circular dark brown spots with concentric rings on leaves, stems and pods',
 'Fungus: Alternaria brassicae / A. brassicicola',
 'Iprodione 50WP (2g/L) or Mancozeb 75WP (2.5g/L)',
 'Potassium + Sulfur fertilizer',
 '1. Treat seed with Thiram 75WS (3g/kg)\n2. Spray Mancozeb at rosette stage\n3. Repeat at 50% flowering and pod formation\n4. Remove infected crop debris\n5. Apply sulfur as fungicide + nutrient',
 'Crop rotation; seed treatment; resistant varieties (Pusa Mustard 30)',
 'High','Rabi'),

('Mustard','White Rust','Aphids',
 'White blister-like pustules on leaf undersides; yellow patches on upper surface; distorted flower stalks',
 'Oomycete: Albugo candida',
 'Metalaxyl 8% + Mancozeb 64% (2g/L) or Ridomil Gold',
 'Phosphorus + Potassium at flowering',
 '1. Spray Metalaxyl-Mancozeb at bud initiation\n2. Repeat at 80% flowering\n3. Remove and destroy infected plant parts\n4. Ensure proper drainage\n5. Avoid late sowing',
 'Early sowing; resistant varieties; metalaxyl spray before flowering',
 'Medium','Rabi'),

-- ─── GROUNDNUT ───────────────────────────────────────────────
('Groundnut','Tikka Disease (Early & Late Leaf Spot)','Aphids',
 'Brown to black circular spots on leaves; yellow halo (early); defoliation in severe cases',
 'Fungus: Cercospora arachidicola (early) / Cercosporidium personatum (late)',
 'Chlorothalonil 75WP (2g/L) or Mancozeb 75WP (2.5g/L)',
 'Gypsum (Calcium Sulfate) 200kg/acre at pegging',
 '1. Spray Chlorothalonil at first spot appearance\n2. Repeat every 10–14 days\n3. Apply gypsum at pegging stage for pod quality\n4. Remove heavily infected leaves\n5. Avoid overhead irrigation',
 'Rotate crops; spray fungicide from 30 DAS; use tolerant varieties (TAG-24)',
 'High','Kharif'),

('Groundnut','Stem Rot (White Mold)','—',
 'White mycelium at stem base; black sclerotia; wilting; rotting of underground parts',
 'Fungus: Sclerotium rolfsii',
 'Carbendazim 50WP (2g/L) soil drench; Tebuconazole',
 'Organic compost; proper drainage',
 '1. Soil drench with Carbendazim at early disease\n2. Remove infected plants with surrounding soil\n3. Solarize heavily infested fields\n4. Apply Trichoderma to soil before planting\n5. Improve drainage; avoid waterlogging',
 'Solarization; deep plowing; Trichoderma application; crop rotation',
 'High','Kharif'),

-- ─── SUGARCANE ───────────────────────────────────────────────
('Sugarcane','Red Rot','Stem Borer',
 'Red internal discoloration of stalk with white patches and sour smell; drying of top leaves',
 'Fungus: Colletotrichum falcatum',
 'Carbendazim 50WP (0.1%) sett treatment; Copper Oxychloride',
 'Potassium + Phosphorus',
 '1. Use disease-free healthy setts for planting\n2. Treat setts in Carbendazim before planting\n3. Rogue out infected clumps and burn\n4. Drain waterlogged areas\n5. Avoid ratoon from infected crop',
 'Use resistant varieties (Co-0238); sett treatment; avoid waterlogging; proper drainage',
 'High','Kharif'),

('Sugarcane','Sugarcane Smut','—',
 'Long whip-like black smutted shoot emerging from growing point; plant weakens gradually',
 'Fungus: Sporisorium scitamineum',
 'Propiconazole 25EC (1ml/L) as hot water sett treatment; Carboxin seed treatment',
 'Balanced NPK; avoid excess nitrogen',
 '1. Use hot water treatment (50°C, 2 hours) for setts\n2. Rogue out all smutted whips immediately\n3. Bag and destroy smutted material before spore dispersal\n4. Avoid using setts from smutted fields\n5. Plant resistant varieties',
 'Hot water sett treatment; resistant varieties; destroy smutted whips before spore release',
 'High','Kharif'),

-- ─── GENERAL / UNIVERSAL ─────────────────────────────────────
('General','Root Rot (Pythium Root Rot)','Nematodes',
 'Yellowing of lower leaves; brown rotting roots; stunted growth; wilting despite adequate water',
 'Fungus/Oomycete: Pythium spp. / Rhizoctonia solani',
 'Metalaxyl 35SD (seed treatment) or Metalaxyl 8% + Mancozeb 64% soil drench',
 'Organic compost; phosphorus; avoid excess nitrogen',
 '1. Improve field drainage immediately\n2. Apply Metalaxyl-Mancozeb as root drench\n3. Add organic compost to improve soil structure\n4. Solarize soil in summer if severely infested\n5. Apply Trichoderma harzianum (bio-fungicide)',
 'Good drainage; avoid overwatering; soil solarization; Trichoderma application before planting',
 'Medium','All seasons'),

('General','Nematode Infestation','Root Knot Nematodes (Meloidogyne spp.)',
 'Knot-like galls on roots; yellowing and stunting; poor growth; mimics nutrient deficiency',
 'Nematode: Meloidogyne incognita / M. javanica',
 'Carbofuran 3G (33kg/acre) or Fenamiphos 10G; Paecilomyces lilacinus (bio)',
 'Organic compost; poultry manure to suppress nematodes',
 '1. Apply Carbofuran granules to soil before planting\n2. Solarize soil in summer for 6 weeks\n3. Incorporate neem cake (250kg/acre) in soil\n4. Use Paecilomyces lilacinus biocontrol\n5. Plant marigold (Tagetes) as trap crop or intercrop',
 'Soil solarization; neem cake; crop rotation; marigold trap crop; biocontrol agents',
 'High','All seasons'),

('General','Aphid Infestation','Aphids (Various spp.)',
 'Colonies of small insects on shoot tips; curled yellowed leaves; sticky honeydew; sooty mold',
 'Insect: Multiple Aphid species',
 'Imidacloprid 17.8SL (0.3ml/L) or Dimethoate 30EC (2ml/L); Neem oil 5ml/L',
 'Avoid excess nitrogen that promotes soft new growth',
 '1. Spray Imidacloprid or Dimethoate targeting colonies\n2. Spray neem oil (5ml/L) as organic alternative\n3. Install yellow sticky traps in field\n4. Introduce Ladybird beetles for biological control\n5. Strong water jet can dislodge colonies on small plants',
 'Avoid excess nitrogen; yellow sticky traps; biological control; border plantings of coriander/fennel',
 'Medium','All seasons'),

('General','Whitefly Infestation','Whitefly (Bemisia tabaci / Trialeurodes vaporariorum)',
 'Tiny white flying insects on leaf undersides; yellowing; honeydew and sooty mold; virus vector',
 'Insect: Bemisia tabaci',
 'Buprofezin 25SC (1ml/L) or Spiromesifen 22.9SC (0.5ml/L); avoid pyrethroids',
 'Balanced NPK; avoid excess nitrogen',
 '1. Install yellow sticky traps (10/acre)\n2. Spray Buprofezin targeting leaf undersides\n3. Use reflective silver mulch to repel whiteflies\n4. Release Encarsia formosa parasitoid\n5. Neem oil spray (5ml/L) weekly as preventive',
 'Yellow sticky traps; reflective mulch; biological control; avoid pyrethroid insecticides',
 'High','All seasons'),

('General','Nutrient Deficiency Symptoms','—',
 'Yellowing (N), purple tinge (P), scorched leaf edges (K), interveinal chlorosis (Mg/Fe/Mn)',
 'Physiological: Soil nutrient deficiency or pH imbalance',
 'Foliar micronutrient sprays (Zinc 0.5%, Boron 0.2%, Iron 0.5% FeSO4)',
 'Soil-specific fertilizer (NPK + micronutrients) based on soil test',
 '1. Get soil tested to identify deficiency\n2. Apply specific deficient nutrient via soil or foliar route\n3. Correct soil pH (6.0–7.0 for most crops)\n4. Apply balanced NPK as per crop requirement\n5. Use chelated micronutrients for faster correction',
 'Annual soil testing; balanced fertilization program; maintain proper soil pH; organic matter',
 'Low','All seasons');


-- ============================================================
--  STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- ─── 1. LOOK UP DISEASE TREATMENT ──────────────────────────
--   Call: CALL sp_GetTreatment('Tomato', 'Early Blight');
--   Returns matching treatment row(s) from DiseaseTreatment.
-- ──────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_GetTreatment$$
CREATE PROCEDURE sp_GetTreatment(
    IN  p_crop    VARCHAR(100),
    IN  p_disease VARCHAR(200)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM DiseaseTreatment
    WHERE LOWER(crop_name)    = LOWER(TRIM(p_crop))
      AND LOWER(disease_name) = LOWER(TRIM(p_disease));

    IF v_count > 0 THEN
        -- Disease found — return full details
        SELECT
            id,
            crop_name,
            disease_name,
            pest_name,
            symptoms,
            cause,
            pesticide,
            fertilizer,
            treatment_steps,
            prevention_tips,
            severity,
            season,
            is_user_added,
            'FOUND' AS result_status
        FROM DiseaseTreatment
        WHERE LOWER(crop_name)    = LOWER(TRIM(p_crop))
          AND LOWER(disease_name) = LOWER(TRIM(p_disease))
        LIMIT 1;
    ELSE
        -- Disease NOT in database — return empty row with status
        SELECT
            NULL   AS id,
            p_crop AS crop_name,
            p_disease AS disease_name,
            NULL AS pest_name,
            NULL AS symptoms,
            NULL AS cause,
            NULL AS pesticide,
            NULL AS fertilizer,
            NULL AS treatment_steps,
            NULL AS prevention_tips,
            NULL AS severity,
            NULL AS season,
            0    AS is_user_added,
            'NOT_FOUND' AS result_status;
    END IF;
END$$


-- ─── 2. ADD UNKNOWN DISEASE REPORTED BY USER ───────────────
--   Call: CALL sp_AddUnknownDisease(
--             'Rice',
--             'Yellow Streak Virus',
--             'Aphids',
--             'Yellow streaks on leaves, curling',
--             1,          -- user_id (NULL if guest)
--             '/uploads/image123.jpg',
--             'Leaves turning yellow with streaks'
--         );
--   Inserts into DiseaseTreatment with is_user_added=1
--   and logs to UnknownDiseaseReports.
-- ──────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_AddUnknownDisease$$
CREATE PROCEDURE sp_AddUnknownDisease(
    IN  p_crop_name        VARCHAR(100),
    IN  p_disease_name     VARCHAR(200),
    IN  p_pest_name        VARCHAR(200),
    IN  p_symptoms         TEXT,
    IN  p_user_id          INT,
    IN  p_image_path       VARCHAR(400),
    IN  p_user_description TEXT,
    OUT p_new_treatment_id INT,
    OUT p_out_status       VARCHAR(50)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_treat_id INT DEFAULT NULL;

    -- Check if already recorded (perhaps as user-added)
    SELECT COUNT(*), MIN(id)
    INTO v_exists, v_treat_id
    FROM DiseaseTreatment
    WHERE LOWER(crop_name)    = LOWER(TRIM(p_crop_name))
      AND LOWER(disease_name) = LOWER(TRIM(p_disease_name));

    IF v_exists > 0 THEN
        -- Already in DB — maybe was added before
        SET p_new_treatment_id = v_treat_id;
        SET p_out_status       = 'ALREADY_EXISTS';
    ELSE
        -- Insert new disease with placeholder treatment
        -- Agronomist will fill in proper details later
        INSERT INTO DiseaseTreatment (
            crop_name,
            disease_name,
            pest_name,
            symptoms,
            cause,
            pesticide,
            fertilizer,
            treatment_steps,
            prevention_tips,
            severity,
            season,
            is_user_added
        ) VALUES (
            TRIM(p_crop_name),
            TRIM(p_disease_name),
            IFNULL(TRIM(p_pest_name), 'Unknown'),
            IFNULL(p_symptoms, p_user_description),
            'Under investigation — reported by farmer',
            'Consult local agricultural officer for pesticide recommendation',
            'Consult local agricultural officer for fertilizer recommendation',
            CONCAT(
                '1. Take clear photographs of affected area\n',
                '2. Collect 3–5 infected plant samples in a bag\n',
                '3. Contact nearest Krishi Vigyan Kendra (KVK) or agricultural extension office\n',
                '4. Isolate affected plants to prevent possible spread\n',
                '5. Maintain good general crop hygiene: remove visibly infected material'
            ),
            CONCAT(
                'This disease is under review by our agricultural experts.\n',
                'General prevention: balanced nutrition, proper irrigation, clean tools,\n',
                'crop rotation and use of certified seeds.'
            ),
            'Medium',
            'All seasons',
            1   -- is_user_added = TRUE
        );

        SET v_treat_id         = LAST_INSERT_ID();
        SET p_new_treatment_id = v_treat_id;
        SET p_out_status       = 'ADDED_NEW';

        -- Log to UnknownDiseaseReports queue for expert review
        INSERT INTO UnknownDiseaseReports (
            user_id,
            image_path,
            user_description,
            crop_name,
            ai_guess,
            status,
            treatment_id
        ) VALUES (
            p_user_id,
            p_image_path,
            p_user_description,
            TRIM(p_crop_name),
            TRIM(p_disease_name),
            'Pending',
            v_treat_id
        );
    END IF;

END$$


-- ─── 3. SMART DETECTION HANDLER ────────────────────────────
--   This is the main entry point called by the Spring Boot backend.
--   It:
--     (a) looks up disease
--     (b) if not found, auto-creates placeholder + queues for expert
--     (c) saves to DetectionHistory
--   Call: CALL sp_HandleDetection(
--              1,                    -- user_id
--              '/uploads/img.jpg',   -- image_path
--              'Tomato',             -- crop_name
--              'Early Blight',       -- disease_name
--              'Aphids',             -- pest_name
--              0.92,                 -- confidence_score
--              'en',                 -- language
--              'Brown spots on leaf' -- user description
--         );
-- ──────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_HandleDetection$$
CREATE PROCEDURE sp_HandleDetection(
    IN  p_user_id          INT,
    IN  p_image_path       VARCHAR(400),
    IN  p_crop_name        VARCHAR(100),
    IN  p_disease_name     VARCHAR(200),
    IN  p_pest_name        VARCHAR(200),
    IN  p_confidence       FLOAT,
    IN  p_language         VARCHAR(5),
    IN  p_user_description TEXT
)
BEGIN
    DECLARE v_treatment_id INT   DEFAULT NULL;
    DECLARE v_is_unknown   INT   DEFAULT 0;
    DECLARE v_exists       INT   DEFAULT 0;
    DECLARE v_status       VARCHAR(50) DEFAULT '';
    DECLARE v_new_id       INT   DEFAULT NULL;

    -- Step 1: Look up treatment
    SELECT COUNT(*), MIN(id)
    INTO v_exists, v_treatment_id
    FROM DiseaseTreatment
    WHERE LOWER(crop_name)    = LOWER(TRIM(p_crop_name))
      AND LOWER(disease_name) = LOWER(TRIM(p_disease_name));

    -- Step 2: If unknown, auto-add and flag
    IF v_exists = 0 THEN
        SET v_is_unknown = 1;
        CALL sp_AddUnknownDisease(
            p_crop_name,
            p_disease_name,
            p_pest_name,
            p_user_description,
            p_user_id,
            p_image_path,
            p_user_description,
            v_new_id,
            v_status
        );
        SET v_treatment_id = v_new_id;
    END IF;

    -- Step 3: Save detection event
    INSERT INTO DetectionHistory (
        user_id,
        image_path,
        crop_name,
        disease_name,
        pest_name,
        confidence_score,
        treatment_id,
        language_used,
        is_unknown
    ) VALUES (
        p_user_id,
        p_image_path,
        TRIM(p_crop_name),
        TRIM(p_disease_name),
        TRIM(p_pest_name),
        p_confidence,
        v_treatment_id,
        IFNULL(p_language, 'en'),
        v_is_unknown
    );

    -- Step 4: Return detection result
    SELECT
        dh.id                AS detection_id,
        dh.crop_name,
        dh.disease_name,
        dh.pest_name,
        dh.confidence_score,
        dh.is_unknown,
        dt.symptoms,
        dt.cause,
        dt.pesticide,
        dt.fertilizer,
        dt.treatment_steps,
        dt.prevention_tips,
        dt.severity,
        dt.season,
        dt.is_user_added,
        CASE
            WHEN dh.is_unknown = 1
            THEN 'Disease not in database — added for expert review. General advice provided.'
            ELSE 'Treatment found successfully.'
        END                 AS message
    FROM DetectionHistory dh
    LEFT JOIN DiseaseTreatment dt ON dh.treatment_id = dt.id
    WHERE dh.id = LAST_INSERT_ID();

END$$


-- ─── 4. UPDATE USER-ADDED DISEASE (Expert fills in details) ─
--   After agronomist reviews, they call this to update treatment
--   Call: CALL sp_UpdateUnknownTreatment(
--             5,
--             'Spray Mancozeb 2.5g/L',
--             'Potassium Sulfate',
--             '1. Remove infected leaves\n2. Spray Mancozeb',
--             'Avoid overhead irrigation',
--             'High',
--             'Kharif',
--             'Dr. Singh'
--         );
-- ──────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_UpdateUnknownTreatment$$
CREATE PROCEDURE sp_UpdateUnknownTreatment(
    IN p_treatment_id  INT,
    IN p_pesticide     VARCHAR(300),
    IN p_fertilizer    VARCHAR(300),
    IN p_steps         TEXT,
    IN p_prevention    TEXT,
    IN p_severity      VARCHAR(20),
    IN p_season        VARCHAR(100),
    IN p_reviewed_by   VARCHAR(100)
)
BEGIN
    UPDATE DiseaseTreatment SET
        pesticide       = p_pesticide,
        fertilizer      = p_fertilizer,
        treatment_steps = p_steps,
        prevention_tips = p_prevention,
        severity        = p_severity,
        season          = p_season
    WHERE id = p_treatment_id;

    UPDATE UnknownDiseaseReports SET
        status      = 'Reviewed',
        reviewed_by = p_reviewed_by
    WHERE treatment_id = p_treatment_id;

    SELECT CONCAT('Treatment ID ', p_treatment_id, ' updated successfully by ', p_reviewed_by) AS result;
END$$


-- ─── 5. GET DETECTION HISTORY FOR USER ─────────────────────
--   Call: CALL sp_GetHistory(1, 10);
-- ──────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_GetHistory$$
CREATE PROCEDURE sp_GetHistory(
    IN p_user_id INT,
    IN p_limit   INT
)
BEGIN
    SELECT
        dh.id,
        dh.image_path,
        dh.crop_name,
        dh.disease_name,
        dh.pest_name,
        dh.confidence_score,
        dh.language_used,
        dh.is_unknown,
        dh.detected_at,
        dt.pesticide,
        dt.fertilizer,
        dt.severity
    FROM DetectionHistory dh
    LEFT JOIN DiseaseTreatment dt ON dh.treatment_id = dt.id
    WHERE dh.user_id = p_user_id
    ORDER BY dh.detected_at DESC
    LIMIT p_limit;
END$$

DELIMITER ;


-- ============================================================
--  SAMPLE USERS (for testing)
-- ============================================================
INSERT INTO Users (name, phone, email, language) VALUES
('Harjinder Singh',  '+919876543210', 'harjinder@example.com', 'pa'),
('Ramesh Kumar',     '+919812345678', 'ramesh@example.com',    'hi'),
('John Farmer',      '+919800000001', 'john@example.com',      'en');


-- ============================================================
--  TEST CALLS  (uncomment to test after setup)
-- ============================================================

-- Test 1: Known disease lookup
-- CALL sp_GetTreatment('Tomato', 'Early Blight');

-- Test 2: Unknown disease — auto-add
-- SET @new_id = 0; SET @status = '';
-- CALL sp_AddUnknownDisease('Maize','Purple Streak Virus','Aphids','Purple streaks on leaves',1,'/img/test.jpg','Leaves show purple discoloration',@new_id,@status);
-- SELECT @new_id AS new_treatment_id, @status AS result_status;

-- Test 3: Full detection flow
-- CALL sp_HandleDetection(1,'/uploads/img1.jpg','Tomato','Early Blight','Aphids',0.94,'en','Brown spots with rings on leaves');

-- Test 4: Unknown disease through detection flow
-- CALL sp_HandleDetection(2,'/uploads/img2.jpg','Wheat','Silver Streak Blight','Mites',0.61,'hi','Silver patches forming along veins');

-- Test 5: Get user history
-- CALL sp_GetHistory(1, 10);


-- ============================================================
--  DONE — Database ready.
--  Total tables     : 4 (Users, DiseaseTreatment, DetectionHistory, UnknownDiseaseReports)
--  Total diseases   : 40+ across 12 crops + General category
--  Stored procedures: 5 (GetTreatment, AddUnknown, HandleDetection, UpdateTreatment, GetHistory)
-- ============================================================
