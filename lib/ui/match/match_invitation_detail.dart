import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';
import 'package:topdeck_app_flutter/ui/match/deck_selection_page.dart';
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';
import 'package:topdeck_app_flutter/utils/toast_service.dart';

/// Page to display match invitation details
@RoutePage()
class MatchInvitationDetailPage extends StatelessWidget {
  /// Invitation data
  final MatchInvitation invitation;

  /// Whether this is a received invitation
  final bool isReceived;

  /// Constructor
  const MatchInvitationDetailPage({
    Key? key,
    required this.invitation,
    required this.isReceived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final String senderName = invitation.senderProfile?.username ??
        invitation.senderProfile?.fullName ??
        'Sconosciuto';
    final String receiverName = invitation.receiverProfile?.username ??
        invitation.receiverProfile?.fullName ??
        'Sconosciuto';
    final String opponentName = isReceived ? senderName : receiverName;

    final String status = invitation.status.toString().split('.').last;
    final String format = invitation.displayFormat ?? 'Formato sconosciuto';

    final String createdAtStr = invitation.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(invitation.createdAt!)
        : 'Data sconosciuta';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Accettato';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        statusText = 'Rifiutato';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        statusText = 'In attesa';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<InvitationListBloc, InvitationListState>(
        listener: (context, state) {
          if (state is InvitationCancelledState) {
            ToastService.showSuccess(context, 'Invito annullato con successo');
            context.maybePop();
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  'Dettaglio invito',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 88, 16, 12),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isReceived ? 'Invito da' : 'Invito a',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opponentName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      statusText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildModernCard(
                        context,
                        'Dettagli della partita',
                        Icons.info_rounded,
                        [
                          _buildDetailItem(Icons.sports_esports_rounded, 'Formato', format),
                          _buildDetailItem(Icons.access_time_rounded, 'Data invito', createdAtStr),
                          if (invitation.message != null && invitation.message!.isNotEmpty)
                            _buildDetailItem(Icons.message_rounded, 'Messaggio', invitation.message!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildModernCard(
                        context,
                        'Partecipanti',
                        Icons.people_rounded,
                        [
                          _buildDetailItem(
                            isReceived ? Icons.person_outline_rounded : Icons.person_rounded,
                            isReceived ? 'Invitante' : 'Tu',
                            senderName,
                          ),
                          _buildDetailItem(
                            isReceived ? Icons.person_rounded : Icons.person_outline_rounded,
                            isReceived ? 'Tu' : 'Invitato',
                            receiverName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Action buttons
                      if (!isReceived && status == 'pending')
                        _buildActionButton(
                          context,
                          'Annulla invito',
                          Icons.cancel_rounded,
                          Colors.red,
                          () {
                            context
                                .read<InvitationListBloc>()
                                .cancelInvitation(invitation.id);
                          },
                        ),
                      
                      if (isReceived && status == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                'Accetta',
                                Icons.check_rounded,
                                Colors.green,
                                () {
                                  context.pushRoute(DeckSelectionPageRoute(invitation: invitation));
                                  // Invece di accettare direttamente, andiamo alla pagina di selezione del mazzo
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                'Rifiuta',
                                Icons.close_rounded,
                                Colors.red,
                                () {
                                  context.read<InvitationListBloc>().add(
                                        DeclineInvitationEvent(invitation.id),
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isDark ? 10 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text(
                  '$label:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
