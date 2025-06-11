import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';

/// Page for creating a new tournament
class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _leagueController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedFormat = 'advanced';
  bool _isPublic = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _formats = [
    'advanced',
    'goat',
    'edison',
    'hat',
    'custom',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _leagueController.dispose();
    _maxParticipantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleziona data torneo',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Seleziona ora di inizio',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Torneo'),
        actions: [
          BlocBuilder<TournamentOperationsBloc, TournamentOperationState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state is CreatingTournamentState ? null : _createTournament,
                child: state is CreatingTournamentState
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crea'),
              );
            },
          ),
        ],
      ),
      body: BlocListener<TournamentOperationsBloc, TournamentOperationState>(
        listener: (context, state) {
          if (state is TournamentCreatedState) {
            Navigator.of(context).pop();
          } else if (state is TournamentOperationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informazioni Base'),
                const SizedBox(height: 16),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildFormatField(),
                const SizedBox(height: 16),
                _buildLeagueField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Programmazione'),
                const SizedBox(height: 16),
                _buildDateTimeFields(),
                const SizedBox(height: 24),
                _buildSectionTitle('Impostazioni Privacy'),
                const SizedBox(height: 16),
                _buildPrivacyToggle(),
                const SizedBox(height: 24),
                _buildSectionTitle('Partecipanti'),
                const SizedBox(height: 16),
                _buildMaxParticipantsField(),
                const SizedBox(height: 32),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome del torneo',
        hintText: 'Inserisci il nome del torneo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.emoji_events),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Il nome del torneo è obbligatorio';
        }
        if (value.trim().length < 3) {
          return 'Il nome deve essere di almeno 3 caratteri';
        }
        return null;
      },
    );
  }

  Widget _buildFormatField() {
    return DropdownButtonFormField<String>(
      value: _selectedFormat,
      decoration: const InputDecoration(
        labelText: 'Formato',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _formats.map((format) {
        return DropdownMenuItem(
          value: format,
          child: Text(_formatDisplayName(format)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFormat = value;
          });
        }
      },
    );
  }

  Widget _buildLeagueField() {
    return TextFormField(
      controller: _leagueController,
      decoration: const InputDecoration(
        labelText: 'Lega (opzionale)',
        hintText: 'Es. Lega Regionale, Torneo Locale...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.group),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrizione (opzionale)',
        hintText: 'Aggiungi dettagli sul torneo, regole speciali, premi...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildDateTimeFields() {
    return Column(
      children: [
        // Date field
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data di inizio (opzionale)',
              hintText: 'Seleziona la data',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Nessuna data selezionata',
              style: TextStyle(
                color: _selectedDate != null ? null : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Time field
        InkWell(
          onTap: _selectTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Ora di inizio (opzionale)',
              hintText: 'Seleziona l\'ora',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(
              _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : 'Nessun orario selezionato',
              style: TextStyle(
                color: _selectedTime != null ? null : Colors.grey[600],
              ),
            ),
          ),
        ),
        if (_selectedDate != null || _selectedTime != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Nota: I tornei serali potrebbero superare la mezzanotte',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Torneo Pubblico'),
              subtitle: Text(
                _isPublic
                    ? 'Chiunque può vedere e unirsi al torneo'
                    : 'Solo chi ha il codice invito può unirsi',
              ),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
              secondary: Icon(
                _isPublic ? Icons.public : Icons.lock,
                color: _isPublic ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxParticipantsField() {
    return TextFormField(
      controller: _maxParticipantsController,
      decoration: const InputDecoration(
        labelText: 'Numero massimo partecipanti (opzionale)',
        hintText: 'Lascia vuoto per nessun limite',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = int.tryParse(value);
          if (number == null || number < 2) {
            return 'Il numero deve essere almeno 2';
          }
          if (number > 1000) {
            return 'Il numero non può superare 1000';
          }
        }
        return null;
      },
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Informazioni',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• I tornei pubblici sono visibili a tutti gli utenti\n'
              '• I tornei privati richiedono un codice invito\n'
              '• Puoi sempre modificare le impostazioni dopo la creazione\n'
              '• I partecipanti possono unirsi fino all\'inizio del torneo',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayName(String format) {
    switch (format) {
      case 'advanced':
        return 'Advanced';
      case 'goat':
        return 'GOAT';
      case 'edison':
        return 'Edison';
      case 'hat':
        return 'HAT';
      case 'custom':
        return 'Custom';
      default:
        return format;
    }
  }

  void _createTournament() {
    if (_formKey.currentState!.validate()) {
      final maxParticipants = _maxParticipantsController.text.isNotEmpty
          ? int.tryParse(_maxParticipantsController.text)
          : null;

      final league = _leagueController.text.isNotEmpty
          ? _leagueController.text.trim()
          : null;

      final description = _descriptionController.text.isNotEmpty
          ? _descriptionController.text.trim()
          : null;

      // Format time as HH:MM string if selected
      String? startTimeString;
      if (_selectedTime != null) {
        startTimeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      }

      context.read<TournamentOperationsBloc>().add(
        CreateTournamentOperationEvent(
          name: _nameController.text.trim(),
          format: _selectedFormat,
          isPublic: _isPublic,
          maxParticipants: maxParticipants,
          league: league,
          startDate: _selectedDate,
          startTime: startTimeString,
          description: description,
        ),
      );
    }
  }
} 