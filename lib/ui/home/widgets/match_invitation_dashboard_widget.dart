import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/ui/widgets/user_avatar_widget.dart';

class MatchInvitationDashboardWidget extends StatelessWidget {
  const MatchInvitationDashboardWidget({
    super.key, 
    required this.matchInvitation, 
    required this.myUser,
  });
  
  final UserProfile myUser;
  final MatchInvitation matchInvitation;
  
  @override
  Widget build(BuildContext context) {
    final bool isFromMe = matchInvitation.senderProfile?.id == myUser.id;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => context.pushRoute(MatchInvitationDetailPageRoute(invitation: matchInvitation, isReceived: !isFromMe)).then((_) {
        // Quando si torna dalla pagina di dettaglio, ricarica gli inviti
        // Questo è utile se l'invito è stato cancellato o modificato
        if (context.mounted) {
          context.read<InvitationListBloc>().loadInvitations();
        }
      }),
      child: Container(
        width: 300,
        
        margin: const EdgeInsets.only(bottom: 16, left: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(isDarkMode),
          ),
          borderRadius: BorderRadius.circular(20),
                   boxShadow: [
             BoxShadow(
               color: _getPrimaryColor(context).withOpacity(0.3),
               blurRadius: 6,
               offset: const Offset(0, 6),
             ),
           ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: -10,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con avatar e status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: MatchInvitationAvatarWidget(
                            matchInvitation: matchInvitation,
                            myUser: myUser,
                            radius: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getOtherUserName(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    isFromMe ? Icons.send : Icons.inbox,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFromMe ? 'Inviato da te' : 'Ricevuto',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Formato con icona
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.games,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            matchInvitation.displayFormat ?? 'Formato non specificato',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (matchInvitation.message != null && matchInvitation.message!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.message_outlined,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Messaggio',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  matchInvitation.message!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                    ],
                    
                    // Footer con azioni
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tocca per i dettagli',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Ottiene il nome dell'altro utente (non quello corrente)
  String _getOtherUserName() {
    if (matchInvitation.senderProfile?.id == myUser.id) {
      // Se io sono il sender, mostra il receiver
      return matchInvitation.receiverProfile?.username ?? 
             matchInvitation.receiverProfile?.fullName ?? 
             'Utente sconosciuto';
    } else {
      // Altrimenti mostra il sender
      return matchInvitation.senderProfile?.username ?? 
             matchInvitation.senderProfile?.fullName ?? 
             'Utente sconosciuto';
    }
  }
  
  /// Ottiene il testo per lo stato dell'invito
  String _getStatusText() {
    switch (matchInvitation.status) {
      case MatchInvitationStatus.pending:
        return 'IN ATTESA';
      case MatchInvitationStatus.accepted:
        return 'ACCETTATO';
      case MatchInvitationStatus.declined:
        return 'RIFIUTATO';
      default:
        return matchInvitation.status.toString().split('.').last.toUpperCase();
    }
  }

  /// Ottiene il colore basato sullo stato dell'invito
  Color _getStatusColor() {
    switch (matchInvitation.status) {
      case MatchInvitationStatus.pending:
        return Colors.orange.shade100;
      case MatchInvitationStatus.accepted:
        return Colors.green.shade100;
      case MatchInvitationStatus.declined:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Ottiene il colore primario dell'app (sempre viola indaco)
  Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Ottiene i colori del gradiente basati sul tema dell'app (sempre viola con variazioni)
  List<Color> _getGradientColors(bool isDarkMode) {
    // Usa sempre il colore primary (viola indaco) con variazioni di tonalità per gli stati
    switch (matchInvitation.status) {
      case MatchInvitationStatus.pending:
        // Viola più chiaro per pending
        return isDarkMode
            ? [const Color(0xFF6366F1), const Color(0xFF5B21B6)]
            : [const Color(0xFF6366F1), const Color(0xFF5B21B6)];
      case MatchInvitationStatus.accepted:
        // Viola standard per accepted
        return isDarkMode
            ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
            : [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
      case MatchInvitationStatus.declined:
        // Viola più scuro per declined
        return isDarkMode
            ? [const Color(0xFF4F46E5), const Color(0xFF3730A3)]
            : [const Color(0xFF4F46E5), const Color(0xFF3730A3)];
      default:
        // Viola standard di default
        return isDarkMode
            ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
            : [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }

  /// Crea il badge per lo stato dell'invito
  Widget _buildStatusBadge() {
    IconData iconData;
    Color backgroundColor;
    
    switch (matchInvitation.status) {
      case MatchInvitationStatus.pending:
        iconData = Icons.schedule;
        backgroundColor = Colors.white.withOpacity(0.2);
        break;
      case MatchInvitationStatus.accepted:
        iconData = Icons.check_circle;
        backgroundColor = Colors.white.withOpacity(0.2);
        break;
      case MatchInvitationStatus.declined:
        iconData = Icons.cancel;
        backgroundColor = Colors.white.withOpacity(0.2);
        break;
      default:
        iconData = Icons.help_outline;
        backgroundColor = Colors.white.withOpacity(0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}