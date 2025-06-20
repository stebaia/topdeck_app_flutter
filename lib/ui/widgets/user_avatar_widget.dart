import 'package:flutter/material.dart';
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';
import 'package:topdeck_app_flutter/model/user.dart';

/// Widget riutilizzabile per mostrare l'avatar di un utente
/// Se l'immagine non è disponibile, mostra la prima lettera dell'email con sfondo colorato
class UserAvatarWidget extends StatelessWidget {
  /// Profilo utente da mostrare
  final UserProfileForInvitation? userProfile;
  
  /// Dimensione del CircleAvatar
  final double radius;
  
  /// Dimensione del font per le iniziali
  final double? fontSize;
  
  /// Constructor
  const UserAvatarWidget({
    Key? key,
    required this.userProfile,
    this.radius = 20,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Se non c'è profilo utente, mostra avatar di default
    if (userProfile == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade400,
        child: Icon(
          Icons.person,
          size: radius * 0.8,
          color: Colors.white,
        ),
      );
    }

    // Ottieni l'URL dell'avatar e il username
    final String? avatarUrl = userProfile!.avatarUrl;
    final String? username = userProfile!.username;
    final String? nome = userProfile!.nome;
    
    // Se c'è l'immagine, usala
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Se l'immagine fallisce, il widget si ricostruirà automaticamente
          // con il fallback delle iniziali
          debugPrint('Error loading avatar image: $exception');
        },
        // Fornisce un fallback immediato in caso di errore
        child: Container(),
      );
    }

    // Fallback: usa la prima lettera del username o nome
    String initial = '?';
    if (username != null && username.isNotEmpty) {
      initial = username[0].toUpperCase();
    } else if (nome != null && nome.isNotEmpty) {
      initial = nome[0].toUpperCase();
    }

    // Genera un colore basato sul username o nome per consistenza
    final Color backgroundColor = _generateColorFromString(username ?? nome ?? 'default');

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Genera un colore consistente basato su una stringa
  Color _generateColorFromString(String input) {
    // Lista di colori piacevoli per gli avatar
    final List<Color> colors = [
      Colors.red.shade400,
      Colors.pink.shade400,
      Colors.purple.shade400,
      Colors.deepPurple.shade400,
      Colors.indigo.shade400,
      Colors.blue.shade400,
      Colors.lightBlue.shade400,
      Colors.cyan.shade400,
      Colors.teal.shade400,
      Colors.green.shade400,
      Colors.lightGreen.shade400,
      Colors.lime.shade400,
      Colors.yellow.shade400,
      Colors.amber.shade400,
      Colors.orange.shade400,
      Colors.deepOrange.shade400,
      Colors.brown.shade400,
      Colors.blueGrey.shade400,
    ];

    // Calcola un hash semplice della stringa per selezionare il colore
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Usa il modulo per selezionare un colore dalla lista
    final int index = hash.abs() % colors.length;
    return colors[index];
  }
}

/// Widget specifico per gli inviti che gestisce la logica sender/receiver
class MatchInvitationAvatarWidget extends StatelessWidget {
  /// L'invito al match
  final MatchInvitation matchInvitation;
  
  /// L'utente corrente
  final UserProfile myUser;
  
  /// Dimensione del CircleAvatar
  final double radius;
  
  /// Dimensione del font per le iniziali
  final double? fontSize;
  
  /// Constructor
  const MatchInvitationAvatarWidget({
    Key? key,
    required this.matchInvitation,
    required this.myUser,
    this.radius = 20,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determina quale profilo mostrare basandosi sull'utente corrente
    UserProfileForInvitation? profileToShow;
    
    if (matchInvitation.senderProfile?.id == myUser.id) {
      // Se io sono il sender, mostra il receiver
      profileToShow = matchInvitation.receiverProfile;
    } else {
      // Altrimenti mostra il sender
      profileToShow = matchInvitation.senderProfile;
    }

    return UserAvatarWidget(
      userProfile: profileToShow,
      radius: radius,
      fontSize: fontSize,
    );
  }
} 