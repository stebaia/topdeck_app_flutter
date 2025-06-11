# Sistema ELO - Edge Functions Documentation

## Panoramica
Il sistema ELO è stato implementato completamente lato Supabase utilizzando Edge Functions per garantire sicurezza, integrità dei dati e performance ottimali. Tutte le operazioni di calcolo ELO, validazione e aggiornamento avvengono server-side.

## Edge Functions Deploy

### 1. update-elo-after-match
**Endpoint:** `/functions/v1/update-elo-after-match`
**Metodo:** POST

Gestisce il calcolo e aggiornamento ELO dopo una partita.

**Parametri:**
```json
{
  "player1_id": "uuid",
  "player2_id": "uuid|null", // null per bye
  "winner_id": "uuid|null", // null per pareggio, undefined per bye
  "format": "advanced|edison|goat|hat|custom",
  "tournament_id": "uuid|null",
  "is_friendly": boolean,
  "is_bye": boolean,
  "player1_deck_id": "uuid|null",
  "player2_deck_id": "uuid|null",
  "round": number|null
}
```

**Logica ELO:**
- **ELO iniziale:** 1200 per nuovi utenti
- **K-Factor:** 
  - 40 per primi 30 match (calibrazione)
  - 20 per match tornei
  - 10 per match amichevoli
- **Formula:** `newElo = oldElo + K * (score - expectedScore)`
- **Bye:** conta come vittoria ma senza cambio ELO

**Response:**
```json
{
  "success": true,
  "match": { /* match data */ },
  "elo_changes": {
    "player1": {
      "old_elo": 1200,
      "new_elo": 1216,
      "change": 16
    },
    "player2": { /* ... */ }
  }
}
```

### 2. apply-tournament-bonuses
**Endpoint:** `/functions/v1/apply-tournament-bonuses`
**Metodo:** POST

Applica i bonus ELO a fine torneo.

**Parametri:**
```json
{
  "tournament_id": "uuid",
  "format": "advanced|edison|goat|hat|custom",
  "final_rankings": [
    {
      "user_id": "uuid",
      "position": 1,
      "points": 9,
      "deck_id": "uuid|null"
    }
  ]
}
```

**Bonus System:**
- **Vincitore:** +50 ELO
- **Top 4:** +25 ELO
- **Altri:** nessun bonus

**Response:**
```json
{
  "success": true,
  "total_participants": 16,
  "bonuses_applied": 5,
  "details": {
    "winner_bonus": 1,
    "top4_bonus": 4,
    "applied_bonuses": [/* dettagli */]
  }
}
```

### 3. get-user-profile-extended
**Endpoint:** `/functions/v1/get-user-profile-extended`
**Metodo:** GET

Ottiene il profilo utente completo con statistiche ELO.

**Query Parameters:**
- `user_id`: UUID dell'utente
- `include_matches`: boolean (default: true)
- `include_tournaments`: boolean (default: true)
- `match_limit`: number (default: 50)
- `tournament_limit`: number (default: 50)

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "username": "player123",
    "nome": "Mario",
    "cognome": "Rossi",
    "elo_ratings": {
      "advanced": {
        "elo": 1450,
        "matches_played": 25,
        "wins": 15,
        "losses": 8,
        "draws": 2,
        "win_rate": 0.6,
        "peak_elo": 1480
      }
    },
    "match_history": [/* matches */],
    "tournament_history": [/* tournaments */],
    "overall_stats": {
      "total_matches": 25,
      "overall_win_rate": 0.6,
      "total_tournaments": 3,
      "tournament_wins": 1,
      "favorite_format": "advanced",
      "peak_elo": 1480
    }
  }
}
```

### 4. get-leaderboard
**Endpoint:** `/functions/v1/get-leaderboard`
**Metodo:** GET

Ottiene le classifiche ELO.

**Query Parameters:**
- `format`: string (opzionale, se omesso restituisce tutte)
- `limit`: number (max 100, default: 50)
- `page`: number (default: 1)
- `search`: string (ricerca username)
- `user_id`: UUID (per includere rank utente)

**Response:**
```json
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "user_id": "uuid",
        "username": "champion",
        "elo": 1650,
        "matches_played": 45,
        "win_rate": 0.75
      }
    ],
    "format_leaderboards": {
      "advanced": [/* top 10 advanced */],
      "edison": [/* top 10 edison */]
    },
    "user_rank": 15,
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_entries": 234,
      "has_next_page": true
    }
  }
}
```

### 5. get-match-history
**Endpoint:** `/functions/v1/get-match-history`
**Metodo:** GET

Ottiene la cronologia match di un utente.

**Query Parameters:**
- `user_id`: UUID (richiesto)
- `format`: string (opzionale)
- `limit`: number (max 100, default: 50)
- `page`: number (default: 1)
- `tournament_only`: boolean
- `friendly_only`: boolean

**Response:**
```json
{
  "success": true,
  "data": {
    "matches": [
      {
        "id": "uuid",
        "format": "advanced",
        "date": "2024-01-15T14:30:00Z",
        "result": "win|loss|draw|bye",
        "opponent": {
          "username": "opponent",
          "avatar_url": "url"
        },
        "is_tournament": true,
        "tournament": {
          "name": "Weekly Advanced"
        },
        "elo_change": 16,
        "elo_before": 1200,
        "elo_after": 1216
      }
    ],
    "statistics": {
      "total_matches": 25,
      "wins": 15,
      "tournament_matches": 20,
      "total_elo_gained": 250
    },
    "pagination": { /* ... */ }
  }
}
```

### 6. get-user-statistics
**Endpoint:** `/functions/v1/get-user-statistics`
**Metodo:** GET

Ottiene statistiche dettagliate utente.

**Query Parameters:**
- `user_id`: UUID (richiesto)
- `format`: string (opzionale)
- `include_ranking`: boolean (default: true)

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "format": "advanced",
    "match_statistics": {
      "total_matches": 25,
      "wins": 15,
      "win_rate": 0.6,
      "avg_elo_change": 8.5,
      "total_elo_gained": 250
    },
    "rankings": {
      "advanced": 15,
      "edison": 8
    },
    "tournament_statistics": {
      "total_tournaments": 3,
      "tournament_wins": 1,
      "top4_finishes": 2,
      "tournament_win_rate": 0.33
    },
    "recent_performance": {
      "last_10_matches": 10,
      "recent_wins": 7,
      "win_streak": 3,
      "recent_elo_change": 45
    }
  }
}
```

## Database Functions

Funzioni PostgreSQL create per operazioni ottimizzate:

### update_player_elos()
Aggiorna atomicamente i dati ELO di due giocatori.

### get_user_match_stats()
Calcola statistiche match per un utente.

### get_user_rank_in_format()
Ottiene il rank di un utente in un formato specifico.

### get_format_leaderboard()
Genera leaderboard paginata per formato.

## Sicurezza

- **Autenticazione:** JWT token richiesto
- **Validazione:** Input validation completa
- **Atomicità:** Transazioni database per consistency
- **Rate Limiting:** Controlli server-side
- **Audit Trail:** Log completo delle operazioni

## Esempi di Utilizzo

### Creare Match Amichevole
```dart
final result = await eloService.createFriendlyMatch(
  player1Id: 'user1-uuid',
  player2Id: 'user2-uuid', 
  winnerId: 'user1-uuid',
  format: 'advanced',
);
```

### Completare Torneo
```dart
final result = await eloService.completeTournament(
  tournamentId: 'tournament-uuid',
  format: 'advanced',
  finalRankings: rankings,
);
```

### Ottenere Leaderboard
```dart
final leaderboard = await eloService.getLeaderboard(
  format: 'advanced',
  limit: 20,
  userId: currentUserId,
);
```

## Performance

- **Caching:** Redis per leaderboard frequenti
- **Indexing:** Indici ottimizzati per query common
- **Pagination:** Tutte le liste sono paginate
- **Batching:** Operazioni batch per tournaments

## Monitoraggio

- **Logs:** Centralized logging su Supabase
- **Metrics:** Performance monitoring
- **Alerts:** Error tracking e notifiche
- **Backup:** Automated backups ELO data

## Versioning

- **API Versioning:** Supporto versioni multiple
- **Migration:** Scripts per aggiornamenti schema
- **Rollback:** Procedure per rollback sicuro
- **Testing:** Unit e integration tests

Questo sistema garantisce scalabilità, sicurezza e performance per il sistema ELO dell'applicazione. 