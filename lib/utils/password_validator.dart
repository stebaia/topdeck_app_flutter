/// Enum per i diversi tipi di errori di validazione della password
enum PasswordValidationError {
  tooShort,
  noUppercase,
  noLowercase,
  noNumber,
  noSpecialCharacter,
  containsWhitespace,
  tooCommon,
}

/// Risultato della validazione della password
class PasswordValidationResult {
  final bool isValid;
  final List<PasswordValidationError> errors;
  final PasswordStrength strength;

  const PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.strength,
  });

  /// Ottiene il messaggio di errore localizzato per un errore specifico
  String getErrorMessage(PasswordValidationError error) {
    switch (error) {
      case PasswordValidationError.tooShort:
        return 'La password deve contenere almeno 8 caratteri';
      case PasswordValidationError.noUppercase:
        return 'La password deve contenere almeno una lettera maiuscola';
      case PasswordValidationError.noLowercase:
        return 'La password deve contenere almeno una lettera minuscola';
      case PasswordValidationError.noNumber:
        return 'La password deve contenere almeno un numero';
      case PasswordValidationError.noSpecialCharacter:
        return 'La password deve contenere almeno un carattere speciale (!@#\$%^&*(),.?":{}|<>)';
      case PasswordValidationError.containsWhitespace:
        return 'La password non può contenere spazi';
      case PasswordValidationError.tooCommon:
        return 'La password è troppo comune, scegline una più sicura';
    }
  }

  /// Ottiene tutti i messaggi di errore
  List<String> get errorMessages {
    return errors.map((error) => getErrorMessage(error)).toList();
  }
}

/// Enum per la forza della password
enum PasswordStrength {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

/// Estensione per ottenere informazioni sulla forza della password
extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Molto debole';
      case PasswordStrength.weak:
        return 'Debole';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Forte';
      case PasswordStrength.veryStrong:
        return 'Molto forte';
    }
  }

  double get score {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  /// Colore associato alla forza della password
  int get colorValue {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0xFFD32F2F; // Rosso
      case PasswordStrength.weak:
        return 0xFFFF5722; // Arancione scuro
      case PasswordStrength.medium:
        return 0xFFFF9800; // Arancione
      case PasswordStrength.strong:
        return 0xFF4CAF50; // Verde
      case PasswordStrength.veryStrong:
        return 0xFF2E7D32; // Verde scuro
    }
  }
}

/// Validatore per la sicurezza delle password
class PasswordValidator {
  static const int _minLength = 8;
  static const int _maxLength = 128;

  /// Lista di password comuni da evitare
  static const List<String> _commonPasswords = [
    'password',
    '123456',
    '123456789',
    'qwerty',
    'abc123',
    'password123',
    'admin',
    'letmein',
    'welcome',
    'monkey',
    '1234567890',
    'iloveyou',
    'princess',
    'rockyou',
    '12345678',
    'sunshine',
    'password1',
    '123123',
    'football',
    'master',
    'jordan',
    'superman',
    'harley',
    'robert',
    'daniel',
    'matthew',
    'michelle',
    'jessica',
    'jennifer',
    'amanda',
    'joshua',
    'michael',
    'shadow',
    'mustang',
    'baseball',
    'dragon',
    'killer',
    'trustno1',
    'hunter',
    'buster',
    'soccer',
    'tigger',
    'charlie',
    'london',
    'jordan23',
    'eagle1',
    'shelby',
    'disney',
    'angel',
    'oliver',
    'apple',
    'cookie',
    'maverick',
    'love',
    'secret',
    'summer',
    'hello',
    'freedom',
    'computer',
    'sexy',
    'thunder',
    'ginger',
    'hammer',
    'silver',
    'cooper',
    'calvin',
    'chelsea',
    'black',
    'diamond',
    'nascar',
    'jackson',
    'cameron',
    'tomcat',
    'cowboy',
    'sample',
    'hotdog',
    'internet',
    'service',
    'butter',
    'orange',
    'catch22',
    'player',
    'guitar',
    'test',
    'magic',
    'buddy',
    'rainbow',
    'gunner',
    'swimming',
    'dolphin',
    'david',
    'ncc1701',
    'money',
    'bonnie',
    'captain',
    'tennis',
    'russia',
    'coffee',
    'xxxxxxxx',
    'bulldog',
    'warrior',
    'marvin',
    'iceman',
    'music',
    'falcon',
    'beer',
    'apple123',
    'scorpio',
    'mother',
    'abcdef',
    'daniel1',
    'tiger',
    'doctor',
    'gateway',
    'blood',
    'florida',
    'blue',
    'alex',
    'cherry',
    'wood',
    'energy',
    'froggy',
    'super',
    'cool',
    'marina',
    'qwertyuiop',
    'sports',
    'jordan1',
    'dennis',
    'winner',
    'power',
    'fish',
    'client',
    'john',
    'green',
    'racing',
    'moon',
    'andrea',
    'slayer',
    'master1',
    'hello123',
    'charles',
    'martin',
    'johnson',
    'midnight',
    'christian',
    'anthony',
    'golden',
    'angel1',
    'sc00ter',
    'please',
    'american',
    'stone',
    'tiger1',
    'lambo',
    'stephen',
    'ace',
    'apple1',
    'live',
    'marshall',
    'roger',
    'orange1',
    '666666',
    'devil',
    'kelly',
    'spider',
    'fire',
    'cool1',
    'red123',
    'badboy',
    'star',
    'junior',
    'nathan',
    'casper',
    'braves',
    'paul',
    'mark',
    'frank',
    'hacker',
    'runner',
    'helpme',
    'pacific',
    'steve',
    'bears',
    'chiefs',
    'green1',
    'geheim',
    'starwars',
    'enter',
    'digital',
    'god',
    'fresh',
    'dick',
    'pepsi',
    'matrix',
    'champions',
    'holly',
    'fishing',
    'love1',
    'helpdesk',
    'fender',
    'john1',
    'yamaha',
    'diablo',
    'chris',
    'boston',
    'tiger123',
    'marine',
    'chicago',
    'rangers',
    'gandalf',
    'winter',
    'bigtits',
    'barney',
    'edward',
    'raiders',
    'porn',
    'badass',
    'blowme',
    'spanky',
    'bigdaddy',
    'johnson1',
    'chester',
    'london1',
    'midnight1',
    'blue1',
    'fishing1',
    'adidas',
    'manchester',
    'caroline',
    'newyork',
    'reddog',
    'red',
    'alexis',
    'crystal',
    'princess1',
    'gold',
    'naughty',
    'michigan',
    'hardcore',
    'fucking',
    'gorgeous',
    'hannah',
    'playboy',
    'hello1',
    'slipknot',
    'papa',
    'mike',
    'toyota',
    'jordan12',
    'liverpool',
    'chris1',
    'tester',
    'michelle1',
    'liverpool1',
    'bitch',
    'spitfire',
    'monster',
    'success',
    'access',
    'trustno2',
    'zzzzz',
    'batman',
    'swimming1',
    'dolphin1',
    'gordon',
    'casper1',
    'stupid',
    'shit',
    'saturn',
    'gemini',
    'apples',
    'august',
    ' 3333',
    'canada',
    'blazer',
    'cumming',
    'hunting',
    'kitty',
    'rainbow1',
    'arthur',
    'cream',
    'calvin1',
    'shaved',
    'surfer',
    'samson',
    'kelly1',
    'paul1',
    'jake',
    'matt',
    'jackie',
    'qwerty1',
    'shane',
    'rabbit',
    'bunny',
    '147258369',
    'tucker',
    'jason',
    'michelle2',
    'michelle3',
    'michelle4',
    'michelle5',
    'michelle6',
    'michelle7',
    'michelle8',
    'michelle9',
    'michelle10',
  ];

  /// Valida una password e restituisce il risultato della validazione
  static PasswordValidationResult validate(String password) {
    final errors = <PasswordValidationError>[];

    // Controllo lunghezza minima
    if (password.length < _minLength) {
      errors.add(PasswordValidationError.tooShort);
    }

    // Controllo presenza di lettere maiuscole
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add(PasswordValidationError.noUppercase);
    }

    // Controllo presenza di lettere minuscole
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add(PasswordValidationError.noLowercase);
    }

    // Controllo presenza di numeri
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add(PasswordValidationError.noNumber);
    }

    // Controllo presenza di caratteri speciali
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add(PasswordValidationError.noSpecialCharacter);
    }

    // Controllo presenza di spazi
    if (password.contains(' ')) {
      errors.add(PasswordValidationError.containsWhitespace);
    }

    // Controllo se la password è troppo comune
    if (_commonPasswords.contains(password.toLowerCase())) {
      errors.add(PasswordValidationError.tooCommon);
    }

    // Calcola la forza della password
    final strength = _calculatePasswordStrength(password);

    return PasswordValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      strength: strength,
    );
  }

  /// Calcola la forza della password basata su vari criteri
  static PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;

    // Lunghezza
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;

    // Varietà di caratteri
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // Complessità aggiuntiva
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]{2,}')))
      score += 1; // Multipli caratteri speciali
    if (password.contains(RegExp(r'[0-9]{2,}'))) score += 1; // Multipli numeri
    if (!_hasRepeatingCharacters(password))
      score += 1; // Nessun carattere ripetuto
    if (!_hasSequentialCharacters(password)) score += 1; // Nessuna sequenza

    // Penalità per password comuni
    if (_commonPasswords.contains(password.toLowerCase())) {
      score -= 3;
    }

    // Mappa il punteggio alla forza
    if (score <= 2) return PasswordStrength.veryWeak;
    if (score <= 4) return PasswordStrength.weak;
    if (score <= 6) return PasswordStrength.medium;
    if (score <= 8) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// Controlla se la password ha caratteri ripetuti consecutivi
  static bool _hasRepeatingCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  /// Controlla se la password ha sequenze di caratteri (es. 123, abc)
  static bool _hasSequentialCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);

      if (char2 == char1 + 1 && char3 == char2 + 1) {
        return true;
      }
    }
    return false;
  }

  /// Genera suggerimenti per migliorare la password
  static List<String> generateSuggestions(PasswordValidationResult result) {
    final suggestions = <String>[];

    for (final error in result.errors) {
      switch (error) {
        case PasswordValidationError.tooShort:
          suggestions.add('Usa almeno $_minLength caratteri');
          break;
        case PasswordValidationError.noUppercase:
          suggestions.add('Aggiungi almeno una lettera maiuscola (A-Z)');
          break;
        case PasswordValidationError.noLowercase:
          suggestions.add('Aggiungi almeno una lettera minuscola (a-z)');
          break;
        case PasswordValidationError.noNumber:
          suggestions.add('Aggiungi almeno un numero (0-9)');
          break;
        case PasswordValidationError.noSpecialCharacter:
          suggestions.add(
              'Aggiungi almeno un carattere speciale (!@#\$%^&*(),.?":{}|<>)');
          break;
        case PasswordValidationError.containsWhitespace:
          suggestions.add('Rimuovi gli spazi dalla password');
          break;
        case PasswordValidationError.tooCommon:
          suggestions.add('Evita password comuni, usa una combinazione unica');
          break;
      }
    }

    // Suggerimenti generali per migliorare la forza
    if (result.strength == PasswordStrength.veryWeak ||
        result.strength == PasswordStrength.weak) {
      suggestions.add('Considera di usare una passphrase con più parole');
      suggestions.add('Mescola lettere maiuscole e minuscole');
      suggestions.add('Includi numeri e simboli');
    }

    return suggestions;
  }

  /// Controlla se due password corrispondono
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  /// Valida la conferma della password
  static String? validatePasswordConfirmation(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Conferma la password';
    }

    if (!passwordsMatch(password, confirmPassword)) {
      return 'Le password non corrispondono';
    }

    return null;
  }
}
