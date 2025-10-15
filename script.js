// Chat state
let conversationId = generateConversationId();
let messageHistory = [];

// DOM elements
const chatWindow = document.getElementById('chatWindow');
const messageInput = document.getElementById('messageInput');
const sendBtn = document.getElementById('sendBtn');
const clearBtn = document.getElementById('clearBtn');
const charCounter = document.getElementById('charCounter');
const regulationsBtn = document.getElementById('regulationsBtn');
const regulationsSpan = document.getElementById('regulationsSpan');
const regulationsModal = document.getElementById('regulationsModal');
const closeModal = document.getElementById('closeModal');
const closeModalBtn = document.getElementById('closeModalBtn');
const welcomeMessage = document.getElementById('welcomeMessage');
const welcomeScreen = document.getElementById('welcomeScreen');
const startChatBtn = document.getElementById('startChatBtn');
const chatHeader = document.getElementById('chatHeader');
const chatContainer = document.getElementById('chatContainer');

const sessionId = 'd1e66b95-c6fd-488b-b5ac-d52bbef25c78';

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Hide chat elements initially
    chatHeader.classList.add('hidden');
    chatContainer.classList.add('hidden');
    
    // Setup event listeners
    setupEventListeners();
});

function setupEventListeners() {
    // Start chat button
    startChatBtn.addEventListener('click', startChat);
    
    // Send message on button click
    sendBtn.addEventListener('click', sendMessage);
    
    // Send message on Enter key (Shift+Enter for new line)
    messageInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    // Auto-resize textarea
    messageInput.addEventListener('input', () => {
        updateCharCounter();
        autoResizeTextarea();
    });
    
    // Clear conversation
    clearBtn.addEventListener('click', clearConversation);
    
    // Regulations modal
    regulationsBtn.addEventListener('click', () => {
        regulationsModal.classList.add('show');
    }); 
    
    regulationsSpan.addEventListener('click', () => {
        regulationsModal.classList.add('show');
    });
    
    closeModal.addEventListener('click', () => {
        regulationsModal.classList.remove('show');
    });
    
    closeModalBtn.addEventListener('click', () => {
        regulationsModal.classList.remove('show');
    });
    
    // Close modal on outside click
    regulationsModal.addEventListener('click', (e) => {
        if (e.target === regulationsModal) {
            regulationsModal.classList.remove('show');
        }
    });
}

function startChat() {
    // Hide welcome screen
    welcomeScreen.classList.add('hidden');
    
    // Show chat elements
    chatHeader.classList.remove('hidden');
    chatContainer.classList.remove('hidden');
    
    // Focus on input field
    messageInput.focus();
}

function updateCharCounter() {
    const length = messageInput.value.length;
    charCounter.textContent = `${length}/300`;
    
    // Update counter styling based on character count
    charCounter.classList.remove('warning', 'limit');
    if (length >= 300) {
        charCounter.classList.add('limit');
    } else if (length >= 250) {
        charCounter.classList.add('warning');
    }
}

function autoResizeTextarea() {
    messageInput.style.height = 'auto';
    messageInput.style.height = Math.min(messageInput.scrollHeight, 120) + 'px';
}

function generateConversationId() {
    return 'conv_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

async function sendMessage() {
    const message = messageInput.value.trim();
    
    // Validate message
    if (!message) {
        return;
    }
    
    // Disable input while sending
    messageInput.disabled = true;
    sendBtn.disabled = true;
    
    // Clear input
    messageInput.value = '';
    updateCharCounter();
    autoResizeTextarea();
    
    // Remove welcome message if it exists
    welcomeMessage.style.display = 'none';
    
    // Display user message
    displayUserMessage(message);
    
    // Show loading indicator
    const loadingElement = showLoading();
    
    try {
        // Simulate API call (replace with actual API call)
        const response = await getChatResponse(message);
        
        // Remove loading indicator
        loadingElement.remove();
        
        // Display bot response
        displayBotMessage(response);
        
        // Store message in history
        messageHistory.push({
            user: message,
            bot: response,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Error sending message:', error);
        loadingElement.remove();
        displayBotMessage({
            text: 'Przepraszamy, wystąpił błąd. Spróbuj ponownie.',
            source: null
        });
    } finally {
        // Re-enable input
        messageInput.disabled = false;
        sendBtn.disabled = false;
        messageInput.focus();
    }
}

function displayUserMessage(text) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message user';
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = text;
    
    messageDiv.appendChild(contentDiv);
    chatWindow.appendChild(messageDiv);
    
    // Scroll to bottom
    scrollToBottom();
}

function displayBotMessage(response) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message bot';
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = response.text;
    
    messageDiv.appendChild(contentDiv);
    
    // Add source if available
    if (response.source) {
        const sourceDiv = document.createElement('div');
        sourceDiv.className = 'message-source';
        sourceDiv.innerHTML = `Źródło: <a href="${response.source.url}" target="_blank">${response.source.title}</a>`;
        messageDiv.appendChild(sourceDiv);
    }
    
    // Add feedback buttons
    const feedbackDiv = createFeedbackButtons(messageDiv);
    messageDiv.appendChild(feedbackDiv);
    
    chatWindow.appendChild(messageDiv);
    
    // Scroll to bottom
    scrollToBottom();
}

function createFeedbackButtons(messageDiv) {
    const feedbackDiv = document.createElement('div');
    feedbackDiv.className = 'feedback';
    
    const thumbsUpBtn = document.createElement('button');
    thumbsUpBtn.className = 'feedback-btn';
    thumbsUpBtn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path>
        </svg>
        <span>Pomocne</span>
    `;
    thumbsUpBtn.setAttribute('data-feedback', 'positive');
    
    const thumbsDownBtn = document.createElement('button');
    thumbsDownBtn.className = 'feedback-btn';
    thumbsDownBtn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17"></path>
        </svg>
        <span>Nie pomocne</span>
    `;
    thumbsDownBtn.setAttribute('data-feedback', 'negative');
    
    // Add click handlers
    thumbsUpBtn.addEventListener('click', () => handleFeedback(thumbsUpBtn, thumbsDownBtn, 'positive', messageDiv));
    thumbsDownBtn.addEventListener('click', () => handleFeedback(thumbsDownBtn, thumbsUpBtn, 'negative', messageDiv));
    
    feedbackDiv.appendChild(thumbsUpBtn);
    feedbackDiv.appendChild(thumbsDownBtn);
    
    return feedbackDiv;
}

function handleFeedback(clickedBtn, otherBtn, feedbackType, messageDiv) {
    // Get message ID (could be based on timestamp or index)
    const messageId = Array.from(chatWindow.querySelectorAll('.message.bot')).indexOf(messageDiv);
    
    // Check if this button is already active
    const isActive = clickedBtn.classList.contains('active');
    
    if (isActive) {
        // Deactivate if clicking the same button
        clickedBtn.classList.remove('active', feedbackType);
        sendFeedbackToAPI(messageId, null); // Remove feedback
    } else {
        // Deactivate the other button if it's active
        if (otherBtn.classList.contains('active')) {
            otherBtn.classList.remove('active', 'positive', 'negative');
        }
        
        // Activate this button
        clickedBtn.classList.add('active', feedbackType);
        sendFeedbackToAPI(messageId, feedbackType);
    }
}

async function sendFeedbackToAPI(messageId, feedbackType) {
    try {
        // Simulate API call to send feedback
        console.log(`Feedback for message ${messageId}: ${feedbackType}`);
        
        // In a real implementation, you would send this to your backend:
        // await fetch('/api/feedback', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({
        //         conversationId: conversationId,
        //         messageId: messageId,
        //         feedback: feedbackType
        //     })
        // });
        
    } catch (error) {
        console.error('Error sending feedback:', error);
    }
}

function showLoading() {
    const loadingDiv = document.createElement('div');
    loadingDiv.className = 'message bot';
    loadingDiv.id = 'loading-indicator';
    
    const loadingContent = document.createElement('div');
    loadingContent.className = 'loading';
    loadingContent.innerHTML = `
        <span>Przygotowuję odpowiedź</span>
        <div class="loading-dots">
            <div class="loading-dot"></div>
            <div class="loading-dot"></div>
            <div class="loading-dot"></div>
        </div>
    `;
    
    loadingDiv.appendChild(loadingContent);
    chatWindow.appendChild(loadingDiv);
    
    scrollToBottom();
    
    return loadingDiv;
}

function clearConversation() {
    // Confirm before clearing
    if (messageHistory.length > 0) {
        if (!confirm('Czy na pewno chcesz wyczyścić konwersację?')) {
            return;
        }
    }
    
    // Clear chat window while preserving logo2
    chatWindow.innerHTML = `
        <div class="welcome-message" id="welcomeMessage">
            <img src="assets/logo.png" alt="SprawdzAI" class="logo2">
            <p>Witaj! Jestem Twoim asystentem T-Mobile. Jak mogę Ci pomóc?</p>
        </div>
    `;
    
    // Reset conversation
    conversationId = generateConversationId();
    messageHistory = [];
    
    // Focus on input
    messageInput.focus();
}

function scrollToBottom() {
    chatWindow.scrollTop = chatWindow.scrollHeight;
}

// Call backend API
async function getChatResponse(userMessage) {
    try {
        const response = await fetch('https://sprawdzai-1089571743905.europe-west4.run.app/run_sse', {
            method: 'POST',
            mode: 'cors', // Enable CORS
            credentials: 'omit', // Don't send credentials
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
            body: JSON.stringify({
                "appName": "sprawdzai",
                "userId": "user",
                "sessionId": sessionId,
                "newMessage": {
                    "role": "user",
                    "parts": [
                    {
                        "text": userMessage
                    }
                    ]
                },
                "streaming": false,
                "stateDelta": null
                })
            });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        console.log('response:', response)

        const data = await response.json();
        
        // Return response in expected format
        return {
            text: data.text || 'Przepraszam, wystąpił problem z odpowiedzią.',
            source: data.source || null
        };
        
    } catch (error) {
        console.error('Error calling API:', error);
        
        // Return error message to user
        return {
            text: 'Przepraszam, wystąpił błąd podczas łączenia z serwerem. Spróbuj ponownie za chwilę.',
            source: null
        };
    }
}

// Handle page visibility - start new conversation when page is reopened
document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
        // Page is now visible - could trigger new conversation
        // Uncomment if you want to clear on each page visit:
        // clearConversation();
    }
});

// Start new conversation on page load
window.addEventListener('load', () => {
    conversationId = generateConversationId();
    console.log('New conversation started:', conversationId);
});
