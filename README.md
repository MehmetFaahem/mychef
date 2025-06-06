# MyChef AI - AI-Powered Recipe Generator

A beautiful, modern Flutter app that generates personalized recipes using AI based on ingredients you have available.

## ✨ Features

### 🔥 Manual Ingredient Input
- Clean, intuitive interface for adding ingredients
- Smart ingredient suggestions from recent ingredients
- Easy ingredient management with visual chips

### 🤖 AI-Powered Recipe Generation
- Generate personalized recipes based on your available ingredients
- Customize recipes with dietary preferences (Vegetarian, Vegan, Gluten-Free, Keto, Paleo)
- Choose cuisine types (Italian, Mexican, Asian, Indian, Mediterranean, American)
- Set difficulty levels (Easy, Medium, Hard)
- Specify serving sizes (1-8 people)

### 📱 Modern UI/UX Design
- Stunning gradient splash screen with smooth animations
- Material 3 design with beautiful purple-pink color scheme
- Responsive cards with elevation and shadows
- Smooth transitions and animations throughout the app
- Modern typography and spacing

### 💾 Recipe Management
- Save favorite recipes for later access
- Browse saved recipes with search functionality
- View detailed recipe instructions with step-by-step guidance
- Bookmark recipes with visual feedback

### 🎨 Design Highlights
- **Color Scheme**: Modern purple gradient (`#6C5CE7` primary, `#FF6B9D` secondary)
- **Typography**: Roboto font family with carefully crafted text styles
- **Components**: Rounded corners, subtle shadows, and premium feel
- **Animations**: Fade, scale, and slide animations for enhanced UX

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mychef.git
   cd mychef
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Clean Architecture Structure
```
lib/
├── data/
│   ├── models/           # Data models (Recipe, RecipeStep, etc.)
│   ├── repositories/     # Data layer logic
│   └── services/         # External services (AI, HTTP)
├── presentation/
│   ├── screens/          # UI screens
│   ├── widgets/          # Reusable UI components
│   └── providers/        # State management (Riverpod)
└── main.dart            # App entry point
```

### State Management
- **Riverpod**: Modern, type-safe state management
- **StateNotifier**: For complex state handling
- **Provider**: For dependency injection

### Key Dependencies
- `flutter_riverpod`: State management
- `google_generative_ai`: AI recipe generation
- `shared_preferences`: Local storage
- `sqflite`: Database management
- `http`: Network requests
- `json_annotation`: JSON serialization

## 🎯 Recent Updates

### ✅ Removed Camera Functionality
- Eliminated camera scan feature for ingredient detection
- Removed camera-related dependencies (`camera`, `google_ml_kit`, `image_picker`)
- Simplified user flow to focus on manual input only

### 🎨 Modernized Design
- Complete UI overhaul with contemporary design principles
- New color scheme with gradient backgrounds
- Enhanced card designs with better shadows and spacing
- Improved typography and visual hierarchy
- Added smooth animations and transitions

### 🚀 Enhanced Splash Screen
- Beautiful gradient background with brand colors
- Smooth fade, scale, and slide animations
- Professional loading experience
- Automatic navigation to main screen

## 📱 Screens Overview

### 1. Splash Screen
- Animated logo with gradient background
- Loading indicator with brand messaging
- Smooth transition to main app

### 2. Ingredient Input Screen
- Welcome section with gradient card
- Clean ingredient input with smart suggestions
- Recent ingredients as filter chips
- Selected ingredients management
- Recipe preferences customization
- AI generation button with loading states

### 3. Recipe Cards
- Modern card design with gradient headers
- Recipe information display (time, difficulty, ingredients)
- Save/bookmark functionality
- Quick action buttons

### 4. Recipe Details (Cooking Screen)
- Step-by-step cooking instructions
- Timer functionality for cooking steps
- Navigation between recipe steps
- Completion tracking

## 🛠️ Development

### Code Style
- Follows Dart/Flutter best practices
- Material 3 design guidelines
- Clean Architecture principles
- Comprehensive error handling

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Google AI for recipe generation capabilities
- Material Design team for design inspiration
- Contributors and community feedback

---

**Built with ❤️ using Flutter**
