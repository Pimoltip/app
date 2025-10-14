# 📱 Planner App

Flutter application for managing schedules, projects, and events with user authentication system.

## Features

- 🔐 User Authentication (Login/Register)
- 📅 Calendar and Event Management
- 📋 Project Management with Progress Tracking
- 📊 Dashboard with Statistics
- 💾 Local SQLite Database

## Application Structure

### Main Application (main.dart)
- **MyApp**: Main widget that defines the application structure
- **Theme**: Uses green color scheme with Material Design
- **Navigation**: Routes-based navigation system
- **Initial Route**: Login page as the entry point

### Page Routes
- `/login` - Login page (entry point)
- `/signup` - User registration page
- `/dashboard` - Main dashboard after login
- `/calendar` - General calendar view
- `/home` - Project-specific calendar
- `/add` - Add new events
- `/new_project` - Create new projects
- `/weekly` - Weekly view with selected day
- `/appointment` - Appointment management

## Pages Overview

### Login Page
- **Purpose**: User authentication entry point
- **Features**:
  - Auto-login verification on app startup
  - Email and password validation
  - Error handling and user feedback
  - Navigation to dashboard on successful login
  - Link to registration page

### Add Event Page
- **Purpose**: Create and manage events
- **Features**:
  - Date and time selection
  - Event title and description input
  - Recurring event support for weekly events
  - Deadline management for recurring events
  - Loading indicators during save operations
  - Integration with EventRepository

### Dashboard Page
- **Purpose**: Main application overview
- **Features**:
  - Project progress overview
  - Recent events display
  - Quick navigation to other pages
  - User profile information

### Calendar Pages
- **Purpose**: Event visualization and management
- **Features**:
  - Monthly calendar view
  - Event display and interaction
  - Date navigation
  - Integration with Important Day model for special dates

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── event.dart
│   ├── user.dart
│   ├── project.dart
│   └── important_day.dart
├── pages/
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── dashboard_page.dart
│   ├── calendar_page.dart
│   ├── project_calendar.dart
│   ├── appoinment_page.dart
│   ├── add_event_page.dart
│   └── new_project_page.dart
├── services/
│   └── auth_service.dart
└── repo/
    ├── database_service.dart
    ├── user_repository.dart
    ├── event_repository.dart
    └── project_repository.dart
```

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## Usage

1. Register a new account or login
2. View dashboard for project overview
3. Create new projects
4. Manage events and appointments
5. Track project progress

## Technologies Used

- Flutter
- SQLite
- SharedPreferences
- Material Design

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Data Models

### Event Model
- **Purpose**: Stores event data with support for recurring events
- **Key Features**:
  - Basic event properties (title, description, date, user association)
  - Recurring event support with weekday selection
  - Deadline management for recurring events
  - Database integration with SQLite
  - JSON serialization support
- **Recurring System**: Supports multiple weekdays (1=Monday, 7=Sunday) with optional deadline

### User Model
- **Purpose**: Manages user authentication and profile data
- **Key Features**:
  - User authentication support
  - Profile management (email, username, password)
  - Database integration
  - JSON serialization
  - Security features (password handling)

### Project Model
- **Purpose**: Manages project data with progress tracking
- **Key Features**:
  - Project information (name, tag, progress 0-100%)
  - Team management (members list)
  - Deadline tracking
  - Progress monitoring
  - Database integration

### Important Day Model
- **Purpose**: Manages special days and holidays
- **Key Features**:
  - Color-coded display support
  - JSON integration from assets
  - Calendar integration
  - Visual indicators for special dates

## Services

### Authentication Service
- **Purpose**: Manages user login/logout and session handling
- **Key Features**:
  - User Authentication (Login/Logout)
  - Session Management using SharedPreferences
  - User Registration
  - Session Validation & Expiration (30 days)
  - Email Verification
  - Persistent Login State
- **Technical Details**:
  - Uses SharedPreferences for local session storage
  - Integrates with UserRepository for user data management
  - Supports asynchronous operations
  - Automatic session expiration handling

### Database Service
- **Purpose**: Manages SQLite database operations
- **Key Features**:
  - Cross-platform support (Desktop: Windows/Linux/macOS, Mobile)
  - Database schema management
  - Version control and migration
  - Singleton pattern implementation
- **Database Schema**:
  - **Events Table**: Stores event data with recurring support
  - **Users Table**: Stores user authentication data
  - **Projects Table**: Stores project information and progress

## Repository Layer

### User Repository
- **Purpose**: Manages user data operations
- **Key Features**:
  - CRUD Operations (Create, Read, Update, Delete)
  - User Authentication & Validation
  - User Search by Email/Username
  - Data validation and error handling
  - User Management features

### Event Repository
- **Purpose**: Manages event data operations
- **Key Features**:
  - Event CRUD operations
  - Recurring event management
  - Date-based filtering
  - User-specific event retrieval

### Project Repository
- **Purpose**: Manages project data operations
- **Key Features**:
  - Project CRUD operations
  - Progress tracking
  - Team management
  - Deadline management

## License

This project is licensed under the MIT License.