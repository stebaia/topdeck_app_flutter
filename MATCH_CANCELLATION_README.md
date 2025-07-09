# Match Cancellation Feature

## Panoramica
È stata implementata una nuova funzionalità per la cancellazione dei match in corso. Questa funzionalità permette a entrambi i giocatori di un match di cancellarlo senza influire sui calcoli ELO.

## Struttura implementata

### 1. Edge Function: `delete-match`
**Percorso:** `supabase/functions/delete-match/index.ts`

**Caratteristiche:**
- ✅ Accessibile da entrambi i giocatori del match
- ✅ Non influisce sui calcoli ELO (nessuna modifica ai rating)
- ✅ Solo match in corso possono essere cancellati (non quelli completati)
- ✅ Aggiorna lo status a `cancelled` invece di eliminare il record
- ✅ Logging per audit trail
- ✅ Validazioni di sicurezza complete

**Request Body:**
```json
{
  "match_id": "uuid-del-match"
}
```

**Validazioni:**
- Utente autenticato
- Utente è uno dei due giocatori del match
- Match non è già completato (nessun vincitore)

### 2. Service Layer: `MatchServiceImpl`
**File:** `lib/network/service/impl/match_service_impl.dart`

Il metodo `delete()` ora usa l'edge function invece della cancellazione diretta dal database:
- Gestione della sessione utente
- Chiamata all'edge function `delete-match`
- Gestione degli errori appropriata

### 3. State Management: `MatchListBloc`
**Files:**
- `lib/state_management/blocs/match_list/match_list_bloc.dart`
- `lib/state_management/blocs/match_list/match_list_event.dart`
- `lib/state_management/blocs/match_list/match_list_state.dart`

**Nuovo evento:**
```dart
CancelMatchEvent(String matchId)
```

**Nuovi stati:**
- `MatchCancellingState` - Durante la cancellazione
- `MatchCancelledState` - Cancellazione completata con successo
- `MatchCancelErrorState` - Errore durante la cancellazione

### 4. UI Implementation: `MatchDetailPage`
**File:** `lib/ui/match/match_detail_page.dart`

**Nuove funzionalità:**
- ✅ Pulsante "Cancella Match" (solo per match in corso)
- ✅ Dialog di conferma con avviso che non influisce sull'ELO
- ✅ Stati di loading durante la cancellazione
- ✅ Feedback visivo (snackbar) per successo/errore
- ✅ Navigazione automatica dopo cancellazione

## Come funziona

### Flusso di cancellazione:
1. **Utente**: Clicca "Cancella Match" nella pagina dei dettagli
2. **UI**: Mostra dialog di conferma con avviso ELO
3. **BLoC**: Emette `CancelMatchEvent`
4. **Service**: Chiama edge function `delete-match`
5. **Edge Function**: 
   - Valida permessi
   - Verifica che il match sia in corso
   - Aggiorna status a `cancelled`
   - Registra azione per audit
6. **UI**: Mostra feedback e torna alla pagina precedente

### Sicurezza e validazioni:
- ✅ Solo i giocatori del match possono cancellarlo
- ✅ Solo match in corso (non completati) possono essere cancellati
- ✅ Autenticazione JWT richiesta
- ✅ Preservazione dei dati per audit trail
- ✅ Nessun impatto sui calcoli ELO

## Utilizzo

### Per sviluppatori:
```dart
// Per cancellare un match via BLoC
context.read<MatchListBloc>().add(CancelMatchEvent(matchId));

// Per ascoltare gli stati di cancellazione
BlocListener<MatchListBloc, MatchListState>(
  listener: (context, state) {
    if (state is MatchCancelledState) {
      // Match cancellato con successo
    } else if (state is MatchCancelErrorState) {
      // Errore durante la cancellazione
    }
  },
  child: YourWidget(),
)
```

### Per utenti:
1. Vai ai dettagli di un match in corso
2. Scorri verso il basso nella sezione "Azioni"
3. Clicca "Cancella Match" (pulsante rosso)
4. Conferma nel dialog che appare
5. Il match verrà cancellato senza influire sull'ELO

## Note tecniche

### Database Schema:
La funzionalità richiede che la tabella `matches` abbia questi campi:
- `status` (per marcare come `cancelled`)
- `cancelled_at` (timestamp della cancellazione)  
- `cancelled_by` (ID dell'utente che ha cancellato)

### Tabella opzionale per audit:
```sql
CREATE TABLE match_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id),
  action TEXT NOT NULL,
  performed_by UUID REFERENCES auth.users(id),
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Deploy
Per attivare la funzionalità:

1. **Deploy Edge Function:**
```bash
supabase functions deploy delete-match
```

2. **Aggiornare il codice Flutter** (già incluso in questo commit)

3. **Verificare i permessi** della edge function nel dashboard Supabase

## Limitazioni attuali
- Solo match 1v1 supportati (non tornei multi-giocatore)
- La cancellazione è definitiva (non reversibile)
- Richiede connessione internet per la validazione server-side

## Future miglioramenti possibili
- [ ] Possibilità di cancellare match anche da torneo
- [ ] Notifiche push all'avversario quando un match viene cancellato
- [ ] Statistiche sui match cancellati nel profilo utente
- [ ] Timeout automatico per match inattivi oltre X giorni 