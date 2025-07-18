# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Generate code (JSON serialization, routing, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build for release
flutter build apk --release
flutter build ios --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Code Generation
This project uses extensive code generation for:
- **JSON serialization** (`json_serializable`) - Models have `.g.dart` files
- **Routing** (`auto_route`) - `app_router.gr.dart` is generated
- **Dependency injection** parts in `dependency_injector.dart`

Always run `flutter pub run build_runner build --delete-conflicting-outputs` after:
- Creating new model classes with `@JsonSerializable`
- Modifying existing model classes
- Adding new routes to `app_router.dart`

## Architecture Overview

### Clean Architecture Pattern
The app follows a clean architecture approach with clear separation of concerns:

1. **Models** (`lib/model/entities/`) - Data classes extending `BaseModel`
2. **Services** (`lib/network/service/`) - API communication layer
3. **Repositories** (`lib/repositories/`) - Data access abstraction
4. **State Management** (`lib/state_management/`) - BLoC pattern implementation
5. **UI** (`lib/ui/`) - Flutter widgets and pages
6. **Dependency Injection** (`lib/di/`) - Provider-based DI setup

### Key Architecture Principles
- All models extend `BaseModel` and use `@JsonSerializable`
- Services have abstract interfaces with concrete implementations
- Repositories abstract data access using service interfaces
- State management follows BLoC pattern (BLoC for complex flows, Cubit for simple state)
- Dependency injection uses Provider (not GetIt)

## Backend Integration

### Supabase Backend
The app uses **Supabase** as its backend with:
- **Authentication**: Email/password + Google Sign-In
- **Database**: PostgreSQL with real-time subscriptions
- **Edge Functions**: Server-side business logic
- **Storage**: File uploads (if needed)

### Database Schema
Key tables include:
- `profiles` - User profiles
- `decks` - Card decks 
- `matches` - Game matches with ELO integration
- `tournaments` - Tournament system with Swiss pairing
- `tournament_participants` - Tournament participation
- `tournament_matches` - Tournament match results
- `friends` - Friend relationships
- `user_elo` - ELO rating system

### Edge Functions
Critical business logic is handled server-side via Edge Functions:
- **Swiss Pairing System** (`/functions/v1/swiss-pairing-system/`)
- **ELO Rating System** (`/functions/v1/update-elo-after-match`)
- **Tournament Management** (`/functions/v1/tournament-helpers/`)
- **Match Operations** (`/functions/v1/delete-match`)

## State Management

### BLoC Pattern Implementation
- **BLoC** for complex state flows (AuthBloc, TournamentBloc, MatchWizardBloc)
- **Cubit** for simple state management (ThemeCubit, DecksCubit, EloCubit)
- Events and States are properly typed with sealed classes where appropriate

### Key State Management Components
```dart
// BLoC usage example
context.read<AuthBloc>().add(LoginEvent(email, password));

// Cubit usage example  
context.read<EloCubit>().loadUserProfile(userId);

// State listening
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) => switch (state) {
    AuthenticatedState() => HomePage(),
    UnauthenticatedState() => LoginPage(),
    AuthLoadingState() => LoadingIndicator(),
  },
);
```

## Dependency Injection

### Provider-Based DI
The app uses **Provider** for dependency injection, configured in `lib/di/`:
- Services are registered as providers
- Repositories depend on services
- BLoCs/Cubits depend on repositories
- UI components access dependencies via `context.read<T>()`

### Service Locator Pattern
```dart
// Access services
final authService = context.read<AuthService>();
final tournamentRepo = context.read<TournamentRepository>();
final eloCubit = context.read<EloCubit>();
```

## Routing

### Auto Route Configuration
Uses `auto_route` package for type-safe routing:
- Routes defined in `lib/routers/app_router.dart`
- Generated routes in `app_router.gr.dart`
- Authentication guard for protected routes (`AuthGuard`)

### Route Navigation
```dart
// Navigate to page
context.router.push(const TournamentDetailsRoute());

// Navigate with parameters
context.router.push(UserProfileRoute(userId: 'user123'));

// Replace current route
context.router.replace(const HomeRoute());
```

## Tournament System

### Swiss Pairing System
The tournament system is fully implemented with:
- **Models**: `Tournament`, `TournamentParticipant`, `TournamentMatch`
- **Services**: Swiss pairing algorithms via Edge Functions
- **State Management**: `TournamentBloc` and `TournamentOperationsBloc`
- **ELO Integration**: Tournament matches affect ELO ratings

### Tournament Flow
1. Create tournament (public/private with invite codes)
2. Players join tournament
3. Swiss pairing generates match pairings
4. Players complete matches
5. System calculates standings and advances rounds
6. Tournament completion awards ELO bonuses

## ELO Rating System

### ELO Implementation
Comprehensive ELO system with:
- **Base Rating**: 1200
- **K-factors**: 40 (calibration), 20 (tournament), 10 (friendly)
- **Tournament bonuses**: +50 (winner), +25 (top 4)
- **Formats**: Advanced, Speed, Draft, etc.

### ELO Usage
```dart
// Create tournament match (affects ELO)
eloCubit.createTournamentMatch(
  player1Id: 'user1',
  player2Id: 'user2',
  winnerId: 'user1',
  format: 'Advanced',
  tournamentId: 'tournament123',
  round: 1,
);

// Load user profile with ELO data
eloCubit.loadUserProfile(userId: 'user123');
```

## Testing

### Test Structure
- **Unit Tests**: `test/` directory for isolated component testing
- **Integration Tests**: `test/tournament_integration_test.dart` for flow testing
- **Widget Tests**: Test UI components in isolation

### Testing Tools
- `flutter_test` for unit and widget tests
- `bloc_test` for BLoC testing
- `mockito` for mocking dependencies
- `http_mock_adapter` for API mocking

## Localization

### i18n Support
- **English** (`lib/l10n/app_en.arb`)
- **Italian** (`lib/l10n/app_it.arb`)
- Generated localization files in `lib/l10n/`

### Usage
```dart
// Access localized strings
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcome);
```

## Common Development Patterns

### Creating New Features
1. **Model**: Create entity in `lib/model/entities/` extending `BaseModel`
2. **Service**: Create abstract service interface and implementation
3. **Repository**: Create repository with service dependency
4. **State Management**: Create BLoC or Cubit for state management
5. **UI**: Build Flutter widgets consuming the state
6. **DI**: Register dependencies in `lib/di/`
7. **Routing**: Add routes if needed

### Error Handling
- Services return `Future<T>` and throw exceptions
- Repositories catch and handle service exceptions
- BLoCs/Cubits emit error states
- UI displays error messages to users

### Data Flow
UI → BLoC/Cubit → Repository → Service → Supabase → Edge Functions
The reverse flow brings data back to the UI through state emissions.

## Security Considerations

### Authentication
- All API calls include JWT authentication
- Protected routes use `AuthGuard`
- Sensitive operations validated server-side

### Data Validation
- Server-side validation in Edge Functions
- Client-side validation for UX
- No sensitive data stored client-side

## Configuration

### Environment Setup
1. Update `lib/network/supabase_config.dart` with your Supabase credentials
2. Configure OAuth providers in Supabase dashboard
3. Deploy Edge Functions to Supabase

### Required Environment Variables
- Supabase URL and anon key (hardcoded in `supabase_config.dart`)
- OAuth client IDs for Google Sign-In