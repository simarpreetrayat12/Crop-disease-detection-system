/* ============================================
   Crop Disease Detection - Complete JavaScript
   Handles 7-page frontend with authentication
   ============================================ */

// Configuration
const API_URL = 'http://localhost:9090/api';
const UPLOAD_ENDPOINT = `${API_URL}/predict`;
const HISTORY_ENDPOINT = `${API_URL}/history`;
const HEALTH_ENDPOINT = `${API_URL}/health`;

// Global State
let currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;
let currentPrediction = null;
let allPredictions = [];

// ============================================
// PAGE NAVIGATION
// ============================================

/**
 * Show a specific page and hide others
 * @param {string} pageName - ID of page to show
 */
function showPage(pageName) {
    // Check if user is logged in for protected pages
    const protectedPages = ['upload', 'result', 'history', 'profile'];
    if (protectedPages.includes(pageName) && !currentUser) {
        alert('Please login first to access this page');
        showPage('login');
        return;
    }
    
    // Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });
    
    // Show selected page
    const page = document.getElementById(pageName);
    if (page) {
        page.classList.add('active');
    }
    
    // Update active navbar button
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Find and activate the correct button
    const navButtons = document.querySelectorAll('.nav-btn');
    navButtons.forEach((btn, index) => {
        const pageNames = ['home', 'upload', 'history', 'profile', 'login', 'register', 'logout'];
        if (pageNames[index] === pageName) {
            btn.classList.add('active');
        }
    });
    
    // Load data if needed
    if (pageName === 'history') {
        loadHistory();
    } else if (pageName === 'profile') {
        loadProfile();
    }
    
    // Scroll to top
    window.scrollTo(0, 0);
    
    console.log(`📄 Switched to page: ${pageName}`);
    updateNavbarVisibility();
}

// ============================================
// AUTHENTICATION
// ============================================

/**
 * Update navbar visibility based on login status
 */
function updateNavbarVisibility() {
    const isLoggedIn = currentUser !== null;
    
    document.getElementById('uploadNavBtn').style.display = isLoggedIn ? 'block' : 'none';
    document.getElementById('historyNavBtn').style.display = isLoggedIn ? 'block' : 'none';
    document.getElementById('profileNavBtn').style.display = isLoggedIn ? 'block' : 'none';
    document.getElementById('loginNavBtn').style.display = isLoggedIn ? 'none' : 'block';
    document.getElementById('registerNavBtn').style.display = isLoggedIn ? 'none' : 'block';
    document.getElementById('logoutNavBtn').style.display = isLoggedIn ? 'block' : 'none';
}

/**
 * Handle user login
 */
function handleLogin(event) {
    event.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errorDiv = document.getElementById('loginError');
    
    // Simple validation - in production, this would call a backend API
    if (!email || !password) {
        errorDiv.textContent = '❌ Please enter email and password';
        errorDiv.style.display = 'block';
        return false;
    }
    
    // Mock login - store user in localStorage
    currentUser = {
        id: Math.random().toString(36).substring(7),
        email: email,
        name: email.split('@')[0],
        phone: '',
        state: '',
        createdAt: new Date().toLocaleDateString()
    };
    
    localStorage.setItem('currentUser', JSON.stringify(currentUser));
    
    console.log('✅ User logged in:', currentUser);
    
    // Hide form and show success
    document.getElementById('loginForm').reset();
    errorDiv.style.display = 'none';
    
    // Redirect to home
    alert('✅ Login successful! Welcome, ' + currentUser.name);
    updateNavbarVisibility();
    showPage('home');
    
    return false;
}

/**
 * Handle user registration
 */
function handleRegister(event) {
    event.preventDefault();
    
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const phone = document.getElementById('registerPhone').value;
    const state = document.getElementById('registerState').value;
    const errorDiv = document.getElementById('registerError');
    
    // Validation
    if (!email || !password || !name) {
        errorDiv.textContent = '❌ Please fill in all required fields';
        errorDiv.style.display = 'block';
        return false;
    }
    
    if (password.length < 6) {
        errorDiv.textContent = '❌ Password must be at least 6 characters';
        errorDiv.style.display = 'block';
        return false;
    }
    
    // Create user
    currentUser = {
        id: Math.random().toString(36).substring(7),
        name: name,
        email: email,
        phone: phone,
        state: state,
        createdAt: new Date().toLocaleDateString()
    };
    
    localStorage.setItem('currentUser', JSON.stringify(currentUser));
    
    console.log('✅ Account created:', currentUser);
    
    // Reset form
    document.getElementById('registerForm').reset();
    errorDiv.style.display = 'none';
    
    // Redirect
    alert('✅ Account created successfully! Welcome, ' + currentUser.name);
    updateNavbarVisibility();
    showPage('home');
    
    return false;
}

/**
 * Logout user
 */
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        currentUser = null;
        localStorage.removeItem('currentUser');
        console.log('🚪 User logged out');
        updateNavbarVisibility();
        showPage('home');
    }
}

/**
 * Load and display user profile
 */
function loadProfile() {
    if (!currentUser) {
        showPage('login');
        return;
    }
    
    // Update profile information
    document.getElementById('profileName').textContent = currentUser.name;
    document.getElementById('profileEmail').textContent = currentUser.email;
    document.getElementById('profilePhone').textContent = currentUser.phone || 'Not provided';
    document.getElementById('profileState').textContent = currentUser.state || 'Not provided';
    document.getElementById('profileDate').textContent = currentUser.createdAt;
    
    // Calculate statistics (mock data)
    document.getElementById('totalPredictions').textContent = allPredictions.length;
    
    if (allPredictions.length > 0) {
        const avgConfidence = (allPredictions.reduce((sum, p) => sum + p.confidence, 0) / allPredictions.length).toFixed(1);
        document.getElementById('avgConfidence').textContent = avgConfidence + '%';
    }
    
    console.log('👤 Profile loaded');
}

// ============================================
// UPLOAD FUNCTIONALITY
// ============================================

// DOM Elements
const imageInput = document.getElementById('imageInput');
const uploadBox = document.getElementById('uploadBox');
const previewContainer = document.getElementById('previewContainer');
const previewImage = document.getElementById('previewImage');
const fileName = document.getElementById('fileName');
const loadingSpinner = document.getElementById('loadingSpinner');
const errorMessage = document.getElementById('errorMessage');

// Image input change handler
imageInput.addEventListener('change', handleImageSelect);

/**
 * Handle image file selection
 * @param {Event} event - File input change event
 */
function handleImageSelect(event) {
    const file = event.target.files[0];
    
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showError('Please select a valid image file (JPG, PNG, GIF, BMP)');
        return;
    }
    
    // Validate file size (10MB)
    const maxSize = 10 * 1024 * 1024;
    if (file.size > maxSize) {
        showError('File size exceeds 10 MB limit');
        return;
    }
    
    // Display preview
    const reader = new FileReader();
    reader.onload = function(e) {
        previewImage.src = e.target.result;
        fileName.textContent = `📄 ${file.name}`;
        previewContainer.style.display = 'block';
        hideError();
        
        console.log(`✅ Image selected: ${file.name} (${(file.size / 1024).toFixed(2)} KB)`);
    };
    reader.readAsDataURL(file);
}

/**
 * Clear selected image
 */
function clearImage() {
    imageInput.value = '';
    previewContainer.style.display = 'none';
    previewImage.src = '';
    fileName.textContent = '';
    hideError();
    console.log('🗑️ Image cleared');
}

/**
 * Upload image and get prediction from backend
 */
async function uploadImage() {
    const file = imageInput.files[0];
    
    if (!file) {
        showError('Please select an image first');
        return;
    }
    
    // Show loading state
    loadingSpinner.style.display = 'block';
    hideError();
    document.getElementById('uploadBtnText').textContent = 'Uploading...';
    
    try {
        // Create FormData for multipart upload
        const formData = new FormData();
        formData.append('image', file);
        
        console.log('📤 Uploading image to backend...');
        
        // Call backend API
        const response = await fetch(UPLOAD_ENDPOINT, {
            method: 'POST',
            body: formData,
            // Note: Don't set Content-Type; browser will set it automatically for FormData
        });
        
        const data = await response.json();
        
        if (!response.ok || !data.success) {
            throw new Error(data.message || `HTTP ${response.status}: Prediction failed`);
        }
        
        if (data.data) {
            // Store prediction and show result page
            currentPrediction = data.data;
            displayResult(data.data);
            showPage('result');
            console.log('✅ Prediction successful:', data.data);
        } else {
            throw new Error('No prediction data received');
        }
        
    } catch (error) {
        console.error('❌ Upload error:', error);
        showError(`Error: ${error.message}`);
    } finally {
        loadingSpinner.style.display = 'none';
        document.getElementById('uploadBtnText').textContent = '🚀 Predict Disease';
    }
}

// ============================================
// RESULT DISPLAY
// ============================================

/**
 * Display prediction result on result page
 * @param {Object} prediction - Prediction object from backend
 */
function displayResult(prediction) {
    const resultContainer = document.getElementById('resultContainer');
    const noResultMessage = document.getElementById('noResultMessage');
    
    // Update result cards
    document.getElementById('resultDisease').textContent = prediction.disease || 'Unknown Disease';
    document.getElementById('resultConfidence').textContent = `${prediction.confidence}%`;
    document.getElementById('resultSolution').textContent = prediction.solution || 'No treatment information available';
    document.getElementById('resultImage').src = previewImage.src;
    
    // Update confidence bar
    const confidenceBar = document.getElementById('confidenceBarFill');
    if (confidenceBar) {
        confidenceBar.style.setProperty('--confidence', `${prediction.confidence}%`);
        confidenceBar.style.width = `${prediction.confidence}%`;
    }
    
    // Show result container
    resultContainer.style.display = 'block';
    noResultMessage.style.display = 'none';
    
    console.log('📊 Result displayed');
}

// ============================================
// HISTORY FUNCTIONALITY
// ============================================

/**
 * Load and display prediction history from backend
 */
async function loadHistory() {
    const historyTableBody = document.getElementById('historyTableBody');
    const emptyMessage = document.getElementById('emptyHistoryMessage');
    const historyError = document.getElementById('historyError');
    
    // Show loading state
    historyTableBody.innerHTML = '<tr><td colspan="5" class="empty-message">Loading predictions...</td></tr>';
    historyError.style.display = 'none';
    
    try {
        console.log('📜 Fetching prediction history...');
        
        const response = await fetch(HISTORY_ENDPOINT);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: Failed to fetch history`);
        }
        
        const data = await response.json();
        
        if (data.success && data.data && Array.isArray(data.data) && data.data.length > 0) {
            // Build table rows
            let html = '';
            data.data.forEach((prediction, index) => {
                const truncatedSolution = prediction.solution.substring(0, 100) + '...';
                html += `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${prediction.createdAt}</td>
                        <td><strong>${prediction.disease}</strong></td>
                        <td>
                            <span style="background: #3498db; color: white; padding: 3px 8px; border-radius: 3px;">
                                ${prediction.confidence}%
                            </span>
                        </td>
                        <td>${truncatedSolution}</td>
                    </tr>
                `;
            });
            
            historyTableBody.innerHTML = html;
            emptyMessage.style.display = 'none';
            console.log(`✅ Loaded ${data.data.length} predictions`);
            allPredictions = data.data;
            
        } else {
            // No predictions
            historyTableBody.innerHTML = '<tr><td colspan="5" class="empty-message">No predictions yet</td></tr>';
            emptyMessage.style.display = 'block';
        }
        
    } catch (error) {
        console.error('❌ History error:', error);
        historyError.style.display = 'block';
        historyError.textContent = `Error loading history: ${error.message}`;
        historyTableBody.innerHTML = '<tr><td colspan="5" class="empty-message">Failed to load history</td></tr>';
    }
}

/**
 * Clear all history from backend
 */
async function clearAllHistory() {
    if (!confirm('Are you sure you want to clear all prediction history? This cannot be undone.')) {
        return;
    }
    
    // This endpoint would need to be implemented in backend if needed
    // For now, just reload to refresh
    console.log('🗑️ Clearing history...');
    loadHistory();
}

// ============================================
// ERROR HANDLING
// ============================================

/**
 * Show error message
 * @param {string} message - Error message to display
 */
function showError(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = 'block';
    console.error('⚠️', message);
}

/**
 * Hide error message
 */
function hideError() {
    errorMessage.style.display = 'none';
}

// ============================================
// DRAG & DROP
// ============================================

// Prevent default drag behaviors
['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    uploadBox.addEventListener(eventName, preventDefaults, false);
});

function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
}

// Highlight on drag
['dragenter', 'dragover'].forEach(eventName => {
    uploadBox.addEventListener(eventName, highlight, false);
});

['dragleave', 'drop'].forEach(eventName => {
    uploadBox.addEventListener(eventName, unhighlight, false);
});

function highlight(e) {
    uploadBox.style.borderColor = '#f39c12';
    uploadBox.style.backgroundColor = '#fffacd';
}

function unhighlight(e) {
    uploadBox.style.borderColor = '#3498db';
    uploadBox.style.backgroundColor = '#f8f9fa';
}

// Handle drop
uploadBox.addEventListener('drop', handleDrop, false);

function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    imageInput.files = files;
    handleImageSelect({ target: { files: files } });
}

// ============================================
// INITIALIZATION
// ============================================

/**
 * Check if backend is running
 */
async function checkBackendHealth() {
    try {
        console.log('🏥 Checking backend health...');
        const response = await fetch(HEALTH_ENDPOINT);
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ Backend is running:', data);
            document.getElementById('backendStatus').textContent = '✅ Connected';
            return true;
        }
    } catch (error) {
        console.warn('⚠️  Backend not available at', API_URL);
        document.getElementById('backendStatus').textContent = '❌ Disconnected';
    }
    return false;
}

/**
 * Initialize application on page load
 */
window.addEventListener('DOMContentLoaded', () => {
    console.log('\n' + '='.repeat(60));
    console.log('🌾 CROP DISEASE DETECTION SYSTEM WITH AUTH');
    console.log('='.repeat(60));
    console.log('🌐 API URL:', API_URL);
    if (currentUser) {
        console.log('👤 Logged in as:', currentUser.name);
    }
    console.log('='.repeat(60) + '\n');
    
    // Update navbar visibility based on login status
    updateNavbarVisibility();
    
    // Check backend health
    checkBackendHealth();
    
    // Show home page by default
    setTimeout(() => showPage('home'), 100);
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.key === 'Enter') {
        const uploadBtn = document.querySelector('[onclick="uploadImage()"]');
        if (uploadBtn && uploadBtn.offsetParent !== null) { // visible
            uploadImage();
        }
    }
});

