# FlashForge: AI-Powered Learning Companion

FlashForge is an AI-powered flashcard application that uses open-source Hugging Face models to automatically generate study materials from user content.

## Features

- AI-powered flashcard generation from text input
- Support for multiple languages (English, Spanish, Turkish)
- Spaced repetition and active recall learning methods
- Personalized study paths
- Offline study capabilities
- Analytics dashboard

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **AI Models:** Hugging Face (BART, T5, DistilBERT, NLLB-200)
- **Local Storage:** Hive

## Getting Started

### Prerequisites

1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Set up [Firebase](https://firebase.google.com/docs/flutter/setup)
3. Get a [Hugging Face API Key](https://huggingface.co/settings/tokens)

### Installation

1. Clone this repository
```
git clone https://github.com/yourusername/flashforge.git
```

2. Install dependencies
```
flutter pub get
```

3. Setup environment variables for API keys

4. Run the app
```
flutter run
```

## Project Structure

```
lib/
├── main.dart            # Entry point
├── app/                 # App-specific implementations
├── config/              # Configuration files
├── core/                # Core business logic
├── data/                # Data handling (api, repositories)
├── domain/              # Domain entities and interfaces
├── presentation/        # UI layer
└── utils/               # Utility functions
```

## Development Roadmap

- [x] Project Setup
- [ ] Basic UI Implementation
- [ ] Firebase Integration
- [ ] Hugging Face API Integration
- [ ] Flashcard Generation Logic
- [ ] Spaced Repetition System
- [ ] Offline Mode
- [ ] Multilingual Support
- [ ] Analytics Dashboard
- [ ] Collaborative Features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
x