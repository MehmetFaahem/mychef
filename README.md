# MyChef - AI Recipe Generator

A Flutter based mobile application that generates recipes using AI from ingredients, with camera integration for ingredient recognition.

## Features

- AI-powered recipe generation using Google's Generative AI
- Ingredient recognition through camera integration
- Local storage for favorite recipes
- Modern and intuitive user interface
- Cross-platform support (iOS, Android, Web)

## Tech Stack

- **Framework**: Flutter
- **State Management**: Flutter Riverpod
- **AI/ML**: Google Generative AI, Google ML Kit
- **Storage**: SQLite, Shared Preferences
- **Navigation**: Go Router
- **Camera**: Camera Plugin, Image Picker

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A Google AI API key (for recipe generation)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/MehmetFaahem/mychef.git
   cd mychef
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Set up your environment variables:

   - Create a `.env` file in the root directory
   - Add your Google AI API key:
     ```
     GOOGLE_AI_API_KEY=your_api_key_here
     ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
mychef/
├── lib/               # Source code
├── assets/           # Images and other assets
├── test/             # Unit and widget tests
└── pubspec.yaml      # Dependencies and configurations
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
