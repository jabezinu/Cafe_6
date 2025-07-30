# Design Document - User Authentication & Profile System

## Overview

The User Authentication & Profile System implements secure JWT-based authentication with comprehensive user management capabilities. The system follows RESTful API design principles and provides a seamless user experience across registration, login, profile management, and password recovery.

## Architecture

### Backend Architecture (Rails API)
- **Authentication Controller**: Handles login, registration, logout, and token refresh
- **Users Controller**: Manages user profile operations
- **Password Reset Controller**: Handles password recovery flow
- **JWT Service**: Manages token generation, validation, and expiration
- **User Model**: ActiveRecord model with validations and secure password handling

### Frontend Architecture (React)
- **Authentication Context**: Global state management for user authentication status
- **Auth Components**: Login, Register, Profile, and Password Reset forms
- **Protected Routes**: Route guards for authenticated-only pages
- **HTTP Interceptors**: Automatic token attachment and refresh handling
- **Local Storage Service**: Secure token storage and retrieval

## Components and Interfaces

### Backend API Endpoints

#### Authentication Endpoints
```
POST /api/auth/register
POST /api/auth/login
DELETE /api/auth/logout
POST /api/auth/refresh
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

#### User Profile Endpoints
```
GET /api/users/profile
PUT /api/users/profile
```

### Frontend Components

#### Core Authentication Components
- `LoginForm`: Email/password login with validation
- `RegisterForm`: User registration with confirmation
- `ProfileForm`: Editable user profile information
- `PasswordResetForm`: Password recovery interface
- `AuthProvider`: Context provider for authentication state

#### Utility Components
- `ProtectedRoute`: Route wrapper for authenticated access
- `AuthGuard`: Component-level authentication check
- `LoadingSpinner`: Loading states during auth operations

## Data Models

### User Model (Backend)
```ruby
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone_number, presence: true, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }
  validates :password, length: { minimum: 6 }, if: :password_required?
  
  # Attributes: email, full_name, phone_number, password_digest, created_at, updated_at
end
```

### Frontend User State
```javascript
interface User {
  id: number;
  email: string;
  fullName: string;
  phoneNumber: string;
  createdAt: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
```

### JWT Token Structure
```json
{
  "user_id": 123,
  "email": "user@example.com",
  "exp": 1640995200,
  "iat": 1640908800
}
```

## Error Handling

### Backend Error Responses
- **400 Bad Request**: Invalid input data or validation errors
- **401 Unauthorized**: Invalid credentials or expired token
- **422 Unprocessable Entity**: Validation failures with detailed messages
- **500 Internal Server Error**: Unexpected server errors

### Frontend Error Handling
- Form validation with real-time feedback
- Network error handling with retry mechanisms
- Token expiration handling with automatic refresh
- User-friendly error messages for all scenarios

### Error Response Format
```json
{
  "error": "Validation failed",
  "details": {
    "email": ["has already been taken"],
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

## Testing Strategy

### Backend Testing (RSpec)
- **Model Tests**: User validation, password encryption, and associations
- **Controller Tests**: Authentication endpoints, authorization, and error handling
- **Integration Tests**: Complete authentication flows and API responses
- **Security Tests**: JWT token validation, password hashing, and session management

### Frontend Testing (Jest/React Testing Library)
- **Component Tests**: Form validation, user interactions, and state changes
- **Integration Tests**: Authentication flows and API integration
- **Context Tests**: Authentication state management and persistence
- **Route Tests**: Protected route behavior and redirects

### Test Coverage Goals
- Backend: 90%+ coverage for authentication logic
- Frontend: 85%+ coverage for authentication components
- End-to-end: Critical user journeys (register → login → profile update)

## Security Considerations

### Password Security
- BCrypt hashing with appropriate cost factor
- Password strength validation
- Secure password reset tokens with expiration

### JWT Security
- Short token expiration (15 minutes) with refresh tokens
- Secure token storage (httpOnly cookies for production)
- Token blacklisting for logout

### Input Validation
- Server-side validation for all inputs
- SQL injection prevention through parameterized queries
- XSS prevention through proper data sanitization

### Rate Limiting
- Login attempt limiting (5 attempts per 15 minutes)
- Registration rate limiting (3 registrations per hour per IP)
- Password reset request limiting (1 request per 5 minutes per email)