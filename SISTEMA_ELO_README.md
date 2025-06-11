# Sistema ELO - Integrazione nell'App TopDeck

## Architettura Rispettata

Il sistema ELO è stato implementato seguendo rigorosamente l'architettura esistente dell'app:

### 1. **Modelli (lib/model/entities/)**
- `UserElo` - Estende `BaseModel`, usa `@JsonSerializable`
- `MatchExtended` - Estende `BaseModel`, usa `@JsonSerializable`  
- `UserProfileExtended` - Modello composito (non database entity)
- `TournamentParticipation` - Classe data semplice
- `UserStatistics` - Classe data semplice

### 2. **Servizi (lib/network/service/)**
- `EloService` - Interfaccia astratta
- `EloServiceImpl` - Implementazione che usa `EloEdgeService`

### 3. **Repository (lib/repositories/)**
- `EloRepository` - Usa `EloService` (non chiama direttamente edge functions)

### 4. **State Management (lib/state_management/cubit/elo/)**
- `EloState` - Stati per le operazioni ELO
- `EloCubit` - Gestisce lo stato usando `EloRepository`

### 5. **Dependency Injection (lib/di/service_locator.dart)**
Configurato con **Provider** (non GetIt):
```dart
Provider<EloServiceImpl>(),
Provider<EloRepository>(
  create: (context) => EloRepository(
    eloService: context.read<EloServiceImpl>(),
  ),
),
Provider<EloCubit>(
  create: (context) => EloCubit(
    eloRepository: context.read<EloRepository>(),
  ),
),
```

### 6. **Edge Functions Server-Side**
Tutte le operazioni ELO sono gestite lato server:
- `update-elo-after-match`
- `apply-tournament-bonuses` 
- `get-user-profile-extended`
- `get-leaderboard`
- `get-match-history`
- `get-user-statistics`

## Utilizzo nell'App

### Accedere al Cubit
```dart
final eloCubit = context.read<EloCubit>();
```

### Creare Partite
```dart
// Partita amichevole
eloCubit.createFriendlyMatch(
  player1Id: 'user1',
  player2Id: 'user2',
  winnerId: 'user1',
  format: 'Advanced',
);

// Partita torneo
eloCubit.createTournamentMatch(
  player1Id: 'user1',
  player2Id: 'user2',
  winnerId: 'user1', 
  format: 'Advanced',
  tournamentId: 'tournament123',
  round: 1,
);

// Bye
eloCubit.createByeMatch(
  playerId: 'user1',
  format: 'Advanced',
  tournamentId: 'tournament123',
);
```

### Gestire Stati
```dart
BlocBuilder<EloCubit, EloState>(
  builder: (context, state) {
    switch (state) {
      case EloLoading():
        return CircularProgressIndicator();
      case EloProfileLoaded():
        return UserProfileWidget(state.profile);
      case EloLeaderboardLoaded():
        return LeaderboardWidget(state.leaderboardData);
      case EloError():
        return ErrorWidget(state.message);
      default:
        return SizedBox.shrink();
    }
  },
);
```

### Caricare Dati
```dart
// Profilo utente
eloCubit.loadUserProfile(userId: 'user123');

// Leaderboard
eloCubit.loadLeaderboard(format: 'Advanced', limit: 50);

// Storico partite
eloCubit.loadMatchHistory(userId: 'user123', format: 'Advanced');

// Statistiche
eloCubit.loadUserStatistics(userId: 'user123');
```

## Configurazione ELO (lib/utils/elo_config.dart)

### Costanti Sistema
- **ELO iniziale**: 1200
- **K-factor calibrazione**: 40 (prime 30 partite)
- **K-factor torneo**: 20
- **K-factor amichevoli**: 10
- **Bonus vincitore torneo**: +50 ELO
- **Bonus top 4**: +25 ELO

### Utilities
```dart
// Calcoli ELO
EloCalculator.calculateExpectedScore(1400, 1600);
EloCalculator.determineKFactor(isFriendly: false, isTournament: true, matchesPlayed: 25);

// Formattazione UI
EloCalculator.formatEloChange(25); // "+25"
EloCalculator.getEloTier(1800); // "Platinum"
EloCalculator.getRankSuffix(3); // "3rd"
```

## Generazione Codice

Per rigenerare i file `.g.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Database

Le tabelle database sono gestite dalle **Edge Functions**:
- `user_elo` - Rating ELO per utente/formato
- `matches_extended` - Partite con dati ELO
- `tournament_results` - Risultati finali tornei

**Importante**: Tutte le operazioni CRUD sono gestite server-side per sicurezza e integrità dei dati. 