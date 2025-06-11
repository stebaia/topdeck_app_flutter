import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../base_model.dart';
import 'deck.dart';

part 'tournament.g.dart';

/// Status of a tournament
enum TournamentStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed
}

/// Tournament model representing a tournament in the Supabase tournaments table
@JsonSerializable()
class Tournament extends BaseModel {
  /// The name of the tournament
  final String name;
  
  /// The format of the tournament
  final String format;
  
  /// The league this tournament belongs to (optional)
  final String? league;
  
  /// The ID of the user who created this tournament
  @JsonKey(name: 'created_by')
  final String? createdBy;
  
  /// The creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// The status of the tournament
  final TournamentStatus status;

  /// Whether the tournament is public (anyone can join) or private (invite only)
  @JsonKey(name: 'is_public')
  final bool isPublic;

  /// Maximum number of participants allowed in the tournament
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;

  /// Unique code for joining private tournaments
  @JsonKey(name: 'invite_code')
  final String? inviteCode;

  /// The date when the tournament is scheduled to start
  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  /// The time when the tournament is scheduled to start (stored as string in HH:MM format)
  @JsonKey(name: 'start_time')
  final String? startTime;

  /// Detailed description of the tournament
  final String? description;

  /// Current round number (0 = not started)
  @JsonKey(name: 'current_round')
  final int currentRound;

  /// Total number of rounds for this tournament
  @JsonKey(name: 'total_rounds')
  final int? totalRounds;

  /// When the current round timer ends
  @JsonKey(name: 'round_timer_end')
  final DateTime? roundTimerEnd;

  /// Duration of each round in minutes
  @JsonKey(name: 'round_time_minutes')
  final int roundTimeMinutes;

  /// Constructor
  const Tournament({
    required super.id,
    required this.name,
    required this.format,
    this.league,
    this.createdBy,
    this.createdAt,
    this.status = TournamentStatus.upcoming,
    this.isPublic = true,
    this.maxParticipants,
    this.inviteCode,
    this.startDate,
    this.startTime,
    this.description,
    this.currentRound = 0,
    this.totalRounds,
    this.roundTimerEnd,
    this.roundTimeMinutes = 50,
  });

  /// Creates a new Tournament instance with a generated UUID
  factory Tournament.create({
    required String name,
    required String format,
    String? league,
    String? createdBy,
    TournamentStatus status = TournamentStatus.upcoming,
    bool isPublic = true,
    int? maxParticipants,
    String? inviteCode,
    DateTime? startDate,
    String? startTime,
    String? description,
    int currentRound = 0,
    int? totalRounds,
    DateTime? roundTimerEnd,
    int roundTimeMinutes = 50,
  }) {
    return Tournament(
      id: const Uuid().v4(),
      name: name,
      format: format,
      league: league,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: status,
      isPublic: isPublic,
      maxParticipants: maxParticipants,
      inviteCode: inviteCode,
      startDate: startDate,
      startTime: startTime,
      description: description,
      currentRound: currentRound,
      totalRounds: totalRounds,
      roundTimerEnd: roundTimerEnd,
      roundTimeMinutes: roundTimeMinutes,
    );
  }

  /// Creates a tournament from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TournamentToJson(this);

  /// Get the combined start DateTime from startDate and startTime
  DateTime? get startDateTime {
    if (startDate == null || startTime == null) return null;
    
    // Parse time from HH:MM format
    final timeParts = startTime!.split(':');
    if (timeParts.length != 2) return null;
    
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    
    if (hour == null || minute == null) return null;
    
    return DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      hour,
      minute,
    );
  }

  /// Check if tournament is scheduled for today
  bool get isToday {
    if (startDate == null) return false;
    final now = DateTime.now();
    return startDate!.year == now.year &&
           startDate!.month == now.month &&
           startDate!.day == now.day;
  }

  /// Check if tournament is scheduled for tomorrow
  bool get isTomorrow {
    if (startDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startDate!.year == tomorrow.year &&
           startDate!.month == tomorrow.month &&
           startDate!.day == tomorrow.day;
  }

  /// Check if tournament has already started
  bool get hasStarted {
    final startDT = startDateTime;
    if (startDT == null) return false;
    return DateTime.now().isAfter(startDT);
  }

  /// Check if tournament should be starting soon (within 30 minutes)
  bool get isStartingSoon {
    final startDT = startDateTime;
    if (startDT == null) return false;
    final now = DateTime.now();
    return startDT.isAfter(now) && 
           startDT.difference(now).inMinutes <= 30;
  }

  @override
  Tournament copyWith({
    String? id,
    String? name,
    String? format,
    String? league,
    String? createdBy,
    DateTime? createdAt,
    TournamentStatus? status,
    bool? isPublic,
    int? maxParticipants,
    String? inviteCode,
    DateTime? startDate,
    String? startTime,
    String? description,
    int? currentRound,
    int? totalRounds,
    DateTime? roundTimerEnd,
    int? roundTimeMinutes,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      league: league ?? this.league,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      inviteCode: inviteCode ?? this.inviteCode,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      description: description ?? this.description,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      roundTimerEnd: roundTimerEnd ?? this.roundTimerEnd,
      roundTimeMinutes: roundTimeMinutes ?? this.roundTimeMinutes,
    );
  }
} 