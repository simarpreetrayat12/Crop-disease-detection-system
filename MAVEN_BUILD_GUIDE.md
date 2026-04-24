# 🔧 Maven Build & Verification Guide

## Prerequisites Check

Before building, verify you have the required tools:

### Check Java Version
```bash
java -version
```
✅ Must show **Java 17 or higher**

### Check Maven Installation
```bash
mvn -version
```
✅ Must show **Maven 3.6 or higher**

### Check MySQL Connection
```bash
mysql --version
mysql -u root -p
# Then type: exit
```
✅ Must connect successfully

---

## Building the Project

### Option 1: Clean Build (Recommended for First Time)
```bash
cd backend
mvn clean install
```

**What this does:**
- Removes old build artifacts (`target/` folder)
- Downloads all dependencies
- Compiles Java source code
- Runs tests (if any)
- Creates JAR file

**Expected Output (at the end):**
```
[INFO] BUILD SUCCESS
[INFO] Total time: XX.XXX s
[INFO] Finished at: 2026-04-04T10:30:45Z
```

### Option 2: Quick Build (Skip Tests)
```bash
mvn clean install -DskipTests
```

---

## Database Setup

### Step 1: Create Database
```bash
# Open MySQL terminal
mysql -u root -p

# Run setup script
source backend/database/setup.sql;

# Or run manually
CREATE DATABASE crop_disease_db;
USE crop_disease_db;
```

### Step 2: Verify Database Created
```bash
SHOW DATABASES;
USE crop_disease_db;
SHOW TABLES;
DESCRIBE predictions;
```

---

## Running the Application

### Option 1: Maven Run
```bash
cd backend
mvn spring-boot:run
```

### Option 2: Running JAR Directly
```bash
cd backend
java -jar target/crop-disease-detection-1.0.0.jar
```

### Expected Console Output
```
================================================
🌾 Crop Disease Detection System Started
📍 Server running at http://localhost:8080
================================================
```

---

## Verification Tests

Once application is running, verify each endpoint:

### Test 1: Health Check
```bash
curl http://localhost:8080/api/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "service": "Crop Disease Detection API",
  "totalPredictions": 0
}
```

### Test 2: API Info
```bash
curl http://localhost:8080/api/info
```

**Expected Response:**
```json
{
  "service": "Crop Disease Detection System",
  "version": "1.0.0",
  "endpoints": {
    "POST /api/predict": "Upload image and predict disease",
    "GET /api/history": "Get all predictions",
    ...
  }
}
```

### Test 3: Get History (Empty)
```bash
curl http://localhost:8080/api/history
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Predictions retrieved successfully",
  "total": 0,
  "data": []
}
```

---

## Troubleshooting Build Issues

### Issue: "Command not found: mvn"
**Solution:** Maven not in PATH
```bash
# Download Maven from https://maven.apache.org/
# Add to system PATH
# Verify: mvn -version
```

### Issue: "Java version mismatch"
**Solution:** Install Java 17+
```bash
# Download from https://www.oracle.com/java/
# Or use OpenJDK: https://adoptium.net/
java -version  # Verify
```

### Issue: "Cannot connect to MySQL"
**Solution:** Start MySQL server
```bash
# Windows
net start MySQL80

# macOS
brew services start mysql

# Linux
sudo systemctl start mysql
```

### Issue: "BUILD FAILURE - Dependencies not found"
**Solution:** Clear Maven cache
```bash
cd backend
mvn clean install -U
```

### Issue: "Target directory permission denied"
**Solution:** Clear target and rebuild
```bash
rm -rf target/
mvn clean install
```

---

## IDE Integration (Optional)

### Using IntelliJ IDEA
1. Open project folder as Maven project
2. IDE auto-downloads dependencies
3. Right-click `pom.xml` → Run Maven Build
4. Run `CropDiseaseDetectionApplication.java`

### Using Eclipse
1. File → Import → Existing Maven Projects
2. Select project folder
3. Eclipse auto-configures classpath
4. Right-click → Run As → Spring Boot App

### Using VS Code
1. Install "Extension Pack for Java"
2. Install "Spring Boot Extension Pack"
3. Open terminal in project folder
4. Run: `mvn spring-boot:run`

---

## Maven Useful Commands

```bash
# Download dependencies
mvn dependency:resolve

# Display dependency tree
mvn dependency:tree

# Clean build artifacts
mvn clean

# Compile only (no packaging)
mvn compile

# Run tests
mvn test

# Skip tests during build
mvn install -DskipTests

# Create executable JAR
mvn package

# View project info
mvn help:describe -Ddetail=true
```

---

## Project Structure Verification

After successful build, verify this structure:

```
backend/
├── target/
│   ├── crop-disease-detection-1.0.0.jar    # Executable JAR
│   ├── classes/                             # Compiled classes
│   └── ...
├── src/
│   ├── main/
│   │   ├── java/.../                        # All Java files
│   │   └── resources/
│   │       └── application.properties       # Configuration
│   └── test/
├── uploads/                                  # Image storage
├── pom.xml                                   # Maven config
└── README.md
```

---

## Performance Notes

- **Build Time:** 30-60 seconds (first time, with downloads)
- **Startup Time:** 5-10 seconds
- **Memory:** ~300-500 MB

---

## Continuous Development

During development, keep running:
```bash
mvn spring-boot:run
```

The application will:
- Hot-reload Java changes (with DevTools)
- Show live logs in console
- Auto-restart on file changes
- Display clear error messages

---

## Production Build

To create production-ready JAR:

```bash
cd backend
mvn clean package -DskipTests
```

Result:
```
backend/target/crop-disease-detection-1.0.0.jar
```

Run with:
```bash
java -jar crop-disease-detection-1.0.0.jar
```

---

## Dependency Management

View all project dependencies:
```bash
mvn dependency:tree
```

Update dependencies:
1. Edit versions in `pom.xml`
2. Run: `mvn clean install -U`

---

## Configuration for Different Environments

### Development
```properties
server.port=8080
spring.jpa.show-sql=true
logging.level.com.cropdetection=DEBUG
```

### Production
```properties
server.port=8080
spring.jpa.show-sql=false
logging.level.com.cropdetection=INFO
spring.datasource.url=jdbc:mysql://prod-host:3306/crop_disease_db
```

---

## Next Steps After Verification

1. ✅ Verify build succeeds
2. ✅ Verify application starts
3. ✅ Verify health endpoint responds
4. ✅ Verify database connection works
5. ⏳ Create Frontend
6. ⏳ Build Python AI Model
7. ⏳ Test image upload endpoint

---

## Common Success Indicators

✅ Console shows "BUILD SUCCESS"
✅ Application starts without errors
✅ `http://localhost:8080/api/health` responds
✅ Database connection established
✅ Logs show "Crop Disease Detection System Started"

---

## Support Commands

### View application logs
```bash
# Maven run shows logs in console

# JAR run - output to file
java -jar crop-disease-detection-1.0.0.jar > app.log 2>&1 &

# Tail logs
tail -f app.log
```

### Stop application
```bash
# Ctrl+C in terminal (graceful shutdown)
# Or kill process
# Windows: taskkill /F /PID <PID>
# Unix: kill -9 <PID>
```

---

**Ready to build? Run:** `mvn clean install` in the backend folder!
