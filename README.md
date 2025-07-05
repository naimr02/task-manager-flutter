# Task Manager

A modern mobile task manager app built with Flutter. Organize your tasks, set priorities, assign categories, and track your productivity on the go.

## Features

- User authentication (login/logout)
- Create, edit, and delete tasks
- Set task status (pending, in progress, completed, cancelled)
- Assign priorities (low, medium, high, urgent)
- Set due dates and reminders
- Categorize tasks with custom colors
- Responsive and intuitive UI
- Persistent login with secure token storage

## Screenshots

<!-- Add screenshots here if available -->

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A running backend API compatible with the app (see `lib/services/api_service.dart` for API endpoints)
- Android/iOS device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/task_manager.git
   cd task_manager
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Configure API Endpoint:**
   - Update the `baseUrl` and `webUrl` in `lib/services/api_service.dart` to match your backend server.

4. **Run the app:**
   ```sh
   flutter run
   ```

## Folder Structure

- `lib/models/` - Data models (Task, Category, User)
- `lib/screens/` - UI screens (Login, Task List, Add/Edit Task)
- `lib/services/` - API service for backend communication

## API

This app expects a RESTful API with endpoints for authentication, tasks, and categories. See `lib/services/api_service.dart` for details.

## Customization

- **Theme:** Easily change the color scheme in `main.dart`.
- **Categories:** Add or modify categories in the backend; the app fetches them dynamically.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)
