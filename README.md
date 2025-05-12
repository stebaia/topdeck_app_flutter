# TopDeck App Flutter

A Flutter application for tracking Yu-Gi-Oh! card decks, tournaments, and matches.

## Features

- User authentication (email/password)
- User profiles
- Deck management
- Match history
- Tournament organization
- Friend system

## Supabase Integration

This project uses Supabase as its backend, with the following tables:

- `profiles`: User profiles with personal information
- `decks`: Card decks created by users
- `deck_cards`: Individual cards within decks
- `matches`: Game matches between players
- `tournaments`: Organized tournaments
- `tournament_participants`: Users participating in tournaments
- `tournament_matches`: Matches within tournaments
- `friends`: Friend relationships between users
- `skills`: Player ratings in different formats

## Authentication

The app uses Supabase Auth for email and password authentication. When a user registers:

1. A new user is created in Supabase Auth
2. A profile is created in the `profiles` table using the Auth user ID
3. The app maintains authentication state with a BLoC pattern

Authentication features:
- Sign up with email/password
- Log in with email/password
- Password reset via email
- Profile management
- Session persistence

## Architecture

The app follows a clean architecture approach with:

1. **Models**: Data classes that represent database entities
2. **Repositories**: Interfaces that define data access operations
3. **Services**: Implementations that interact with the Supabase API
4. **BLoC**: State management for the application

## Setup

1. Clone the repository
2. Get dependencies: `flutter pub get`
3. Run build_runner to generate the necessary files: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Update `lib/network/supabase_config.dart` with your Supabase URL and anon key
5. Run the app: `flutter run`

## Code Generation

This project uses code generation for:
- JSON serialization: `json_serializable`
- Routing: `auto_route`

Run the following command to generate the necessary files:

```
flutter pub run build_runner build --delete-conflicting-outputs
```
