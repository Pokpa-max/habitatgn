import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/reservation/reservation.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/services/reservation/reservation_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/widgets/reservation/reservation_modal.dart';

// Ajoutez cette fonction pour créer une carte de logement avec réservation
Widget buildHouseCardWithReservation(
  BuildContext context,
  House house, {
  VoidCallback? onReservationChanged,
}) {
  final reservationService = ReservationService();
  final houseData = house.toMap(); // Assumant que vous avez cette méthode
  final reservationStatus = reservationService.getReservationStatus(houseData);
  final canReserve = reservationService.canUserReserve(houseData);
  final hasUserReserved = reservationService.hasUserReserved(houseData);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
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
              builder: (context) => HouseDetailScreen(houseId: house.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomCachedNetworkImage(
                      imageUrl: house.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

                // Badge type d'offre
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      house.offerType["label"] ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Badge statut de réservation
                if (reservationStatus != ReservationStatus.available)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getReservationStatusColor(reservationStatus),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getReservationStatusIcon(reservationStatus),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reservationStatus.label,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Informations du logement
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (house.houseType?.label ?? '').toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FormattedPrice(
                        color: primaryColor,
                        price: house.price,
                        size: 18,
                        suffix: (house.offerType["value"] == "Louer")
                            ? '/mois'
                            : '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Localisation
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${house.address?.town["label"] ?? ''} / ${house.address?.commune["label"] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chambres ou surface
                  if (house.houseType?.label != "Terrain")
                    _buildBedroomsRow(house)
                  else
                    _buildAreaRow(house),

                  // Bouton de réservation ou statut
                  const SizedBox(height: 16),
                  _buildReservationSection(
                    context,
                    house,
                    reservationStatus,
                    canReserve,
                    hasUserReserved,
                    onReservationChanged,
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

Widget _buildReservationSection(
  BuildContext context,
  House house,
  ReservationStatus status,
  bool canReserve,
  bool hasUserReserved,
  VoidCallback? onReservationChanged,
) {
  if (hasUserReserved) {
    // L'utilisateur a déjà réservé ce logement
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.blue[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Votre demande est ${status.label.toLowerCase()}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (canReserve) {
    // L'utilisateur peut réserver
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () =>
            _showReservationModal(context, house, onReservationChanged),
        icon: const Icon(Icons.event_available_outlined, size: 18),
        label: Text(
          'Faire une réservation',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  if (status == ReservationStatus.pending) {
    // Logement en attente de confirmation
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, color: Colors.orange[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Réservation en attente de confirmation',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (status == ReservationStatus.confirmed) {
    // Logement confirmé/réservé
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy, color: Colors.red[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ce logement est réservé',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cas par défaut (ne devrait pas arriver)
  return const SizedBox.shrink();
}

Widget _buildBedroomsRow(House house) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.bed_outlined, color: primaryColor, size: 16),
      ),
      const SizedBox(width: 8),
      Text(
        '${house.bedrooms} chambre${house.bedrooms > 1 ? 's' : ''}',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    ],
  );
}

Widget _buildAreaRow(House house) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.straighten_outlined, color: primaryColor, size: 16),
      ),
      const SizedBox(width: 8),
      Text(
        '${house.area} m²',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    ],
  );
}

Color _getReservationStatusColor(ReservationStatus status) {
  switch (status) {
    case ReservationStatus.pending:
      return Colors.orange;
    case ReservationStatus.confirmed:
      return Colors.green;
    case ReservationStatus.cancelled:
      return Colors.red;
    case ReservationStatus.completed:
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

IconData _getReservationStatusIcon(ReservationStatus status) {
  switch (status) {
    case ReservationStatus.pending:
      return Icons.hourglass_empty;
    case ReservationStatus.confirmed:
      return Icons.check_circle;
    case ReservationStatus.cancelled:
      return Icons.cancel;
    case ReservationStatus.completed:
      return Icons.task_alt;
    default:
      return Icons.info;
  }
}

void _showReservationModal(
  BuildContext context,
  House house,
  VoidCallback? onReservationChanged,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReservationModal(
      maxGuests: house.bedrooms,
      houseId: house.id,
      houseTitle: house.houseType?.label ?? 'Logement',
      houseLocation:
          '${house.address?.town["label"] ?? ''} / ${house.address?.commune["label"] ?? ''}',
      // housePrice: house.price.toDouble(),
      onReservationSuccess: onReservationChanged,
    ),
  );
}
