import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_detail_screen.dart';
import 'package:habitatgn/screens/reservation/reservation_viewmodel.dart';

import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeReservations = ref.watch(activeReservationsProvider);
    final historyReservations = ref.watch(historyReservationsProvider);
    final dateFormatter = ref.watch(dateFormatterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Mes Réservations',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Suivez vos demandes de visite',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
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
                      activeReservations.whenData((data) {
                            return data.isNotEmpty
                                ? Row(
                                    children: [
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${data.length}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          }).value ??
                          const SizedBox.shrink(),
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
                      historyReservations.whenData((data) {
                            return data.isNotEmpty
                                ? Row(
                                    children: [
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${data.length}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          }).value ??
                          const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(allReservationsProvider);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveReservationsTab(activeReservations, dateFormatter),
            _buildHistoryTab(historyReservations, dateFormatter),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveReservationsTab(
    AsyncValue<List<Map<String, dynamic>>> activeReservations,
    DateFormatter dateFormatter,
  ) {
    return activeReservations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Erreur: $err'),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_note_outlined,
            title: 'Aucune demande active',
            message:
                'Vous n\'avez pas de demande de réservation en cours.\nCommencez par rechercher un logement qui vous intéresse.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildReservationCard(
              booking,
              dateFormatter,
              isActive: true,
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(
    AsyncValue<List<Map<String, dynamic>>> historyReservations,
    DateFormatter dateFormatter,
  ) {
    return historyReservations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Erreur: $err'),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_outlined,
            title: 'Historique vide',
            message:
                'Votre historique de réservations apparaîtra ici une fois que vous aurez fait des demandes.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildReservationCard(
              booking,
              dateFormatter,
              isActive: false,
            );
          },
        );
      },
    );
  }

  Widget _buildReservationCard(
    Map<String, dynamic> booking,
    DateFormatter dateFormatter, {
    required bool isActive,
  }) {
    final bookingData = booking['bookingData'] as Map<String, dynamic>;
    final bookingId = booking['bookingId'] as String;
    final houseId = bookingData['houseId'] as String;
    final status = bookingData['status'] as String;

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
                    DailyRentalDetailScreen(rentalId: houseId),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomCachedNetworkImage(
                          imageUrl: bookingData['houseImageUrl'] ?? '',
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
                            'Réservation de logement',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Référence: ${bookingId.substring(0, 8)}...',
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
                    _buildStatusBadge(status),
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
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        color: Colors.grey[600],
                        text:
                            'Demandé le ${dateFormatter.formatDate((bookingData['createdAt'] as dynamic).toDate())}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.event_outlined,
                        color: primaryColor,
                        text:
                            'Arrivée: ${dateFormatter.formatDate((bookingData['checkIn'] as dynamic).toDate())}',
                        highlight: true,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.event_busy_outlined,
                        color: Colors.grey[600],
                        text:
                            'Départ: ${dateFormatter.formatDate((bookingData['checkOut'] as dynamic).toDate())}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.people_outline,
                        color: Colors.grey[600],
                        text: 'Clients: ${bookingData['guests']} personne(s)',
                      ),
                      if (bookingData['notes']?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.message_outlined,
                          color: Colors.grey[600],
                          text: bookingData['notes'],
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions pour les demandes actives
                if (isActive && status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(bookingId),
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
                          onPressed: () {
                            ref
                                .read(reservationServiceProvider)
                                .launchPhoneCall(
                                    'tel:${bookingData['guestPhone']}');
                          },
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
                if (isActive && status == 'confirmed') ...[
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
                                "L'agence va vous contacter bientôt.",
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

  Widget _buildInfoRow({
    required IconData icon,
    required Color? color,
    required String text,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: highlight ? primaryColor : Colors.grey[600],
              fontWeight: highlight ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      case 'completed':
        return 'Complétée';
      default:
        return status;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
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
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Annuler la réservation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Non',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[500]),
            child: Text(
              'Oui, annuler',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reservationService = ref.read(reservationServiceProvider);
      final success = await reservationService.cancelReservation(bookingId);
      if (success && mounted) {
        showToast(context, "Réservation annulée avec succès !", primaryColor);
        ref.refresh(allReservationsProvider);
      }
    }
  }
}
