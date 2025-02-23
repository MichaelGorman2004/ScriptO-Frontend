# ScriptO - iOS Digital Note-Taking App

## Overview
ScriptO is a sophisticated iOS note-taking application built with SwiftUI that combines traditional note-taking with advanced drawing capabilities. The app provides a seamless user experience for creating, managing, and editing digital handwritten notes with a focus on security and performance.

## Features

### Core Functionality
- **Digital Note Taking**
  - Create and edit digital notes
  - Handwriting and drawing support
  - Real-time stroke rendering
  - Pressure-sensitive drawing (when supported)
  - Multiple stroke properties (color, width)

### User Management
- **Secure Authentication**
  - User registration with email
  - JWT token-based authentication
  - Secure token storage
  - Automatic session management

### Note Organization
- **Note Management**
  - Title and subject categorization
  - Tag-based organization
  - Automatic save functionality
  - Creation and modification timestamps

## Technical Architecture

### Frontend Components
- **SwiftUI Views**
  - `ContentView`: Main application interface
  - `DrawingCanvas`: Custom drawing implementation
  - Authentication views (Login/Register)

### Core Services
- **API Layer**
  - `APIClient`: Centralized networking service
  - RESTful API communication
  - Comprehensive error handling
  - Debug logging system

- **Authentication**
  - `AuthManager`: Authentication service
  - `TokenManager`: JWT token management
  - Secure token storage
  - Session persistence

### Data Models
- **Note Structure**
  - `Note`: Primary note container
  - `NoteElement`: Drawing element wrapper
  - `StrokePoint`: Drawing coordinate system
  - `StrokeProperties`: Stroke styling

## Setup and Development

### Requirements
- iOS 18.2+
- Xcode 16.2+
- Swift 5.0+

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ScriptO.git
   ```

2. Open the project in Xcode:
   ```bash
   cd ScriptO
   open ScriptO-Frontend.xcodeproj
   ```

3. Configure the development environment:
   - Update `APIClient.baseURL` in `APIClient.swift`
   - Set up your development team in Xcode
   - Configure your provisioning profile

4. Build and run the project

### Configuration
The app can be configured through several key files:
- `APIClient.swift`: API endpoint configuration
- `AuthManager.swift`: Authentication settings
- `TokenManager.swift`: Token storage configuration

## API Integration

### Backend Requirements
The app expects a REST API with the following endpoints:
- POST `/api/v1/auth/login`: User authentication
- POST `/api/v1/users/register`: User registration
- POST `/api/v1/notes`: Note creation
- GET `/api/v1/notes`: Note retrieval

### Authentication Flow
1. User registers/logs in
2. Server returns JWT token
3. Token stored securely via TokenManager
4. Subsequent requests include token in Authorization header

## Security Features
- Secure token storage using UserDefaults
- JWT authentication
- HTTPS communication
- Input validation and sanitization
- Automatic token refresh (planned)

## Testing
The project includes:
- Unit tests for business logic
- UI tests for interface validation
- Integration tests for API communication

## Contributing

### Development Process
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

### Code Style
- Follow Swift style guidelines
- Maintain existing documentation patterns
- Include unit tests for new features

## License
[Your License Here]

## Support
For support, please:
- Open an issue on GitHub
- Contact the development team at [email]
- Check the documentation at [docs_url]

## Acknowledgments
- SwiftUI framework
- The Swift community
- [Other acknowledgments]

## Version History
- 1.0.0: Initial release
  - Basic note-taking functionality
  - User authentication
  - Drawing capabilities

## Roadmap
- [ ] Offline support
- [ ] Cloud synchronization
- [ ] Collaborative editing
- [ ] Advanced drawing tools
- [ ] Export functionality
