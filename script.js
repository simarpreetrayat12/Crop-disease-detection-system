// ============================================
// Crop Disease Detection - JavaScript
// ============================================

// Configuration
const API_URL = 'http://localhost:9090/api';
const UPLOAD_ENDPOINT = `${API_URL}/predict`;
const HISTORY_ENDPOINT = `${API_URL}/history`;
const HEALTH_ENDPOINT = `${API_URL}/health`;

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    checkAuthStatus();
});

// ============================================
// AUTHENTICATION FUNCTIONS
// ============================================

function showSection(section) {
    // Hide all full-page sections
    document.getElementById('welcomePage').classList.remove('active');
    document.getElementById('loginPage').classList.remove('active');
    document.getElementById('registerPage').classList.remove('active');
    document.getElementById('appContainer').classList.remove('active');
    
    // Show selected section
    if (section === 'welcome') {
        document.getElementById('welcomePage').classList.add('active');
    } else if (section === 'login') {
        document.getElementById('loginPage').classList.add('active');
    } else if (section === 'register') {
        document.getElementById('registerPage').classList.add('active');
    } else if (section === 'app') {
        document.getElementById('appContainer').classList.add('active');
    }
}

function checkAuthStatus() {
    // Check if user is logged in (from localStorage)
    const user = localStorage.getItem('currentUser');
    if (user) {
        loginUser(JSON.parse(user), true);
    } else {
        showSection('welcome');
    }
}

function handleLogin(event) {
    event.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    
    // Validate credentials
    if (email && password) {
        const user = {
            email: email,
            name: email.split('@')[0]
        };
        
        // Save to localStorage
        localStorage.setItem('currentUser', JSON.stringify(user));
        
        loginUser(user, false);
    } else {
        alert('Please enter both email and password');
    }
}

function handleRegister(event) {
    event.preventDefault();
    
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const confirmPassword = document.getElementById('registerConfirm').value;
    
    if (password !== confirmPassword) {
        alert('Passwords do not match');
        return;
    }
    
    if (name && email && password) {
        const user = {
            email: email,
            name: name
        };
        
        // Save to localStorage
        localStorage.setItem('currentUser', JSON.stringify(user));
        
        loginUser(user, false);
    } else {
        alert('Please fill in all fields');
    }
}

function loginUser(user, isRestore) {
    // Update user info display
    document.getElementById('userInfo').textContent = `Welcome, ${user.name}!`;
    
    // Clear form fields
    if (!isRestore) {
        document.getElementById('loginEmail').value = '';
        document.getElementById('loginPassword').value = '';
        document.getElementById('registerName').value = '';
        document.getElementById('registerEmail').value = '';
        document.getElementById('registerPassword').value = '';
        document.getElementById('registerConfirm').value = '';
    }
    
    // Show app and hide auth pages
    showSection('app');
}

function handleLogout() {
    // Clear user data
    localStorage.removeItem('currentUser');
    
    // Reset form fields
    document.getElementById('loginEmail').value = '';
    document.getElementById('loginPassword').value = '';
    document.getElementById('registerName').value = '';
    document.getElementById('registerEmail').value = '';
    document.getElementById('registerPassword').value = '';
    document.getElementById('registerConfirm').value = '';
    
    // Show welcome page
    showSection('welcome');
}

// ============================================
// APP FUNCTIONS
// ============================================

// DOM Elements
const imageInput = document.getElementById('imageInput');
const previewContainer = document.getElementById('previewContainer');
const previewImage = document.getElementById('previewImage');
const loadingSpinner = document.getElementById('loadingSpinner');
const resultContainer = document.getElementById('resultContainer');
const errorContainer = document.getElementById('errorContainer');
const uploadArea = document.querySelector('.upload-area');
const historyContainer = document.getElementById('historyContainer');

// Page Navigation
function showPage(pageName) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });
    
    // Remove active class from all nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Show selected page
    const page = document.getElementById(pageName + 'Page');
    if (page) {
        page.classList.add('active');
    }
    
    // Add active class to clicked button
    event.target.classList.add('active');
    
    // Load history if history page is opened
    if (pageName === 'history') {
        loadHistory();
    }
}

// Image Selection
function handleImageSelect(event) {
    const file = event.target.files[0];
    
    if (!file) {
        hideError();
        return;
    }
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showError('Please select a valid image file (JPG, PNG, GIF)');
        return;
    }
    
    // Validate file size (10MB)
    if (file.size > 10 * 1024 * 1024) {
        showError('File size must be less than 10 MB');
        return;
    }
    
    // Show preview
    const reader = new FileReader();
    reader.onload = function(e) {
        previewImage.src = e.target.result;
        previewContainer.style.display = 'block';
        resultContainer.style.display = 'none';
        hideError();
    };
    reader.readAsDataURL(file);
}

// Clear Preview
function clearPreview() {
    imageInput.value = '';
    previewContainer.style.display = 'none';
    resultContainer.style.display = 'none';
    previewImage.src = '';
    hideError();
}

// Upload Image and Get Prediction
async function uploadImage() {
    const file = imageInput.files[0];
    
    if (!file) {
        showError('Please select an image first');
        return;
    }
    
    // Show loading
    loadingSpinner.style.display = 'block';
    resultContainer.style.display = 'none';
    hideError();
    
    try {
        // Create FormData
        const formData = new FormData();
        formData.append('image', file);
        
        console.log('📤 Uploading image to backend...');
        
        // Call backend API
        const response = await fetch(UPLOAD_ENDPOINT, {
            method: 'POST',
            body: formData
        });
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || 'Prediction failed');
        }
        
        const data = await response.json();
        
        if (data.success && data.data) {
            // Display result
            showResult(data.data);
            console.log('✅ Prediction received:', data.data);
        } else {
            throw new Error(data.message || 'Invalid response from server');
        }
        
    } catch (error) {
        console.error('❌ Error:', error);
        showError(`Error: ${error.message}. Make sure the backend is running at ${API_URL}`);
    } finally {
        loadingSpinner.style.display = 'none';
    }
}

// Display Prediction Result
function showResult(prediction) {
    document.getElementById('resultDisease').textContent = prediction.disease || 'Unknown';
    document.getElementById('resultConfidence').innerHTML = 
        `<span style="color: #4caf50; font-weight: 600;">${prediction.confidence}%</span>`;
    document.getElementById('resultSolution').textContent = prediction.solution || 'No solution available';
    
    resultContainer.style.display = 'block';
    
    // Scroll to result
    resultContainer.scrollIntoView({ behavior: 'smooth' });
}

// Reset Upload
function resetUpload() {
    clearPreview();
}

// Show Error
function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    errorContainer.style.display = 'block';
}

// Hide Error
function hideError() {
    errorContainer.style.display = 'none';
}

// Load Prediction History
async function loadHistory() {
    historyContainer.innerHTML = '<p class="loading-text">Loading predictions...</p>';
    
    try {
        console.log('📜 Fetching prediction history...');
        
        const response = await fetch(HISTORY_ENDPOINT);
        
        if (!response.ok) {
            throw new Error('Failed to fetch history');
        }
        
        const data = await response.json();
        
        if (data.success && data.data && data.data.length > 0) {
            // Display history items
            let html = '';
            
            data.data.forEach(prediction => {
                html += `
                    <div class="history-item">
                        <div class="history-item-header">
                            <div class="history-disease">🦠 ${prediction.disease}</div>
                            <div class="history-confidence">${prediction.confidence}% Confidence</div>
                        </div>
                        <div class="history-date">📅 ${prediction.createdAt}</div>
                        <div class="history-solution"><strong>💊 Solution:</strong> ${prediction.solution}</div>
                    </div>
                `;
            });
            
            historyContainer.innerHTML = html;
            console.log(`✅ Loaded ${data.data.length} predictions`);
        } else {
            historyContainer.innerHTML = '<p class="loading-text">No predictions yet. Upload an image to get started!</p>';
        }
        
    } catch (error) {
        console.error('❌ Error loading history:', error);
        historyContainer.innerHTML = `
            <p class="loading-text" style="color: #f44336;">
                Error loading history. Make sure the backend is running at ${API_URL}
            </p>
        `;
    }
}

// Drag and Drop
uploadArea.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadArea.classList.add('drag-over');
});

uploadArea.addEventListener('dragleave', () => {
    uploadArea.classList.remove('drag-over');
});

uploadArea.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadArea.classList.remove('drag-over');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        imageInput.files = files;
        handleImageSelect({ target: { files: files } });
    }
});

// Health Check on Load
async function checkBackendHealth() {
    try {
        console.log('🏥 Checking backend health...');
        const response = await fetch(HEALTH_ENDPOINT);
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ Backend is running:', data);
            return true;
        }
    } catch (error) {
        console.warn('⚠️  Backend is not running at', API_URL);
        console.warn('Make sure to start the backend with: mvn spring-boot:run');
    }
    return false;
}

// Initialize on Page Load
window.addEventListener('DOMContentLoaded', () => {
    console.log('\n' + '='.repeat(50));
    console.log('🌾 Crop Disease Detection System');
    console.log('='.repeat(50));
    checkBackendHealth();
    
    // Add keyboard support
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && previewContainer.style.display !== 'none') {
            uploadImage();
        }
    });
});

// Log API URL for debugging
console.log('📍 API URL:', API_URL);
