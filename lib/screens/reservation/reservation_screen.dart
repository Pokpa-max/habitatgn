import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/reservation/reservation.dart';
import 'package:habitatgn/services/reservation/reservation_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReservationService _reservationService = ReservationService();

  List<Map<String, dynamic>> _activeReservations = [];
  List<Map<String, dynamic>> _historyReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allReservations = await _reservationService.getUserReservations();

      // Séparer les réservations actives et l'historique
      _activeReservations = allReservations.where((reservation) {
        final details = reservation['details'] as ReservationDetails;
        return details.status == ReservationStatus.pending;
      }).toList();

      _historyReservations = allReservations.where((reservation) {
        final details = reservation['details'] as ReservationDetails;
        return details.status == ReservationStatus.cancelled ||
            details.status == ReservationStatus.completed;
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.grey[700],
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Mes Réservations',
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Suivez vos demandes de visite',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: primaryColor,
              indicatorWeight: 2,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions, size: 18),
                      const SizedBox(width: 8),
                      const Text('Mes Demandes'),
                      if (_activeReservations.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_activeReservations.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 18),
                      const SizedBox(width: 8),
                      const Text('Historique'),
                      if (_historyReservations.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_historyReservations.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveReservationsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveReservationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeReservations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_note_outlined,
        title: 'Aucune demande active',
        message:
            'Vous n\'avez pas de demande de réservation en cours.\nCommencez par rechercher un logement qui vous intéresse.',
        actionLabel: 'Rechercher des logements',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeReservations.length,
      itemBuilder: (context, index) {
        final reservation = _activeReservations[index];
        return _buildReservationCard(reservation, isActive: true);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyReservations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_outlined,
        title: 'Historique vide',
        message:
            'Votre historique de réservations apparaîtra ici une fois que vous aurez fait des demandes.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyReservations.length,
      itemBuilder: (context, index) {
        final reservation = _historyReservations[index];
        return _buildReservationCard(reservation, isActive: false);
      },
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation,
      {required bool isActive}) {
    final houseData = reservation['houseData'] as Map<String, dynamic>;
    final details = reservation['details'] as ReservationDetails;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: primaryColor.withOpacity(0.2), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HouseDetailScreen(houseId: details.houseId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et statut
                Row(
                  children: [
                    // Image miniature du logement
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomCachedNetworkImage(
                          imageUrl: details.imageUrl!,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.houseType?.label.toUpperCase() ??
                                'Logement',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${details.address?.town['label'] ?? ''} / ${details.address?.commune['label'] ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(details.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Informations de la demande
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Demandé le ${_formatDate(details.requestDate)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (details.checkInDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event_outlined,
                                size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Visite prévue le ${_formatDate(details.checkInDate!)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (details.message?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.message_outlined,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                details.message!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions pour les demandes actives
                if (isActive &&
                    details.status == ReservationStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => {
                            _cancelReservation(reservation['houseId']),
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Annuler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            side: BorderSide(color: Colors.red[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => makePhoneCall(
                              details.contactPhone ?? '', context),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Appeler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Statut des demandes confirmées
                if (isActive &&
                    details.status == ReservationStatus.confirmed) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Réservation confirmée !',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                              Text(
                                'Le propriétaire va vous contacter bientôt.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case ReservationStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case ReservationStatus.confirmed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case ReservationStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case ReservationStatus.completed:
        color = Colors.blue;
        icon = Icons.task_alt;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.search, size: 20),
                label: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _cancelReservation(String houseId) async {
    final cancelled = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Annuler la demande',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Voulez-vous vraiment annuler cette demande de réservation ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(color: Colors.grey[700]))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[500]),
            child: Text('Oui, annuler',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );

    if (cancelled == true) {
      final success = await _reservationService.cancelReservation(houseId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande annulée !', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange[600],
          ),
        );
        _loadReservations();
      }
    }
  }
}
