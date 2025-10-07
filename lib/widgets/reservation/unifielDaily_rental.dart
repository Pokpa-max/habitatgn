import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:intl/intl.dart';

class UnifiedDailyRentalModal extends StatefulWidget {
  final String houseId;
  final String houseTitle;
  final String houseLocation;
  final double pricePerNight;
  final int maxGuests;
  final int minStay;
  final int maxStay;
  final int checkInHour;
  final int checkOutHour;
  final VoidCallback? onBookingSuccess;

  const UnifiedDailyRentalModal({
    super.key,
    required this.houseId,
    required this.houseTitle,
    required this.houseLocation,
    required this.pricePerNight,
    this.maxGuests = 2,
    this.minStay = 1,
    this.maxStay = 30,
    this.checkInHour = 14,
    this.checkOutHour = 12,
    this.onBookingSuccess,
  });

  @override
  State<UnifiedDailyRentalModal> createState() =>
      _UnifiedDailyRentalModalState();
}

class _UnifiedDailyRentalModalState extends State<UnifiedDailyRentalModal> {
  final DailyRentalService _service = DailyRentalService();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = true;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _nights {
    if (_checkIn != null && _checkOut != null) {
      return _checkOut!.difference(_checkIn!).inDays;
    }
    return 0;
  }

  double get _totalPrice {
    return widget.pricePerNight * _nights;
  }

  bool get _canBook {
    return _checkIn != null &&
        _checkOut != null &&
        _guests > 0 &&
        _guests <= widget.maxGuests &&
        _nights >= widget.minStay &&
        _nights <= widget.maxStay &&
        _isAvailable &&
        !_isLoading;
  }

  Future<void> _checkAvailability() async {
    if (_checkIn == null || _checkOut == null) return;

    setState(() {
      _isCheckingAvailability = true;
      _errorMessage = null;
    });

    try {
      final available = await _service.checkAvailability(
        houseId: widget.houseId,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
      );

      setState(() {
        _isAvailable = available;
        _isCheckingAvailability = false;
        if (!available) {
          _errorMessage = 'Ce logement n\'est pas disponible pour ces dates';
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingAvailability = false;
        _errorMessage = 'Erreur lors de la vérification de disponibilité';
      });
    }
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkIn ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkIn = DateTime(
          picked.year,
          picked.month,
          picked.day,
          widget.checkInHour,
          0,
        );
        if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
          _checkOut = null;
        }
      });
      _checkAvailability();
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_checkIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez d\'abord sélectionner la date d\'arrivée',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOut ?? _checkIn!.add(const Duration(days: 1)),
      firstDate: _checkIn!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkOut = DateTime(
          picked.year,
          picked.month,
          picked.day,
          widget.checkOutHour,
          0,
        );
      });
      _checkAvailability();
    }
  }

  Future<void> _confirmBooking() async {
    if (!_canBook) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookingId = await _service.createBooking(
        houseId: widget.houseId,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guests: _guests,
        totalPrice: _totalPrice,
        notes: _notesController.text,
      );

      if (bookingId != null) {
        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Réservation effectuée avec succès !',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onBookingSuccess?.call();
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la réservation';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.book_online,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réserver',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              widget.houseTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.houseLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Dates
                  Text(
                    'Dates du séjour',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateButton(
                                label: 'Arrivée',
                                date: _checkIn,
                                time: '${widget.checkInHour}:00',
                                onTap: () => _selectCheckInDate(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.arrow_forward, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDateButton(
                                label: 'Départ',
                                date: _checkOut,
                                time: '${widget.checkOutHour}:00',
                                onTap: () => _selectCheckOutDate(context),
                              ),
                            ),
                          ],
                        ),
                        if (_nights > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.nights_stay,
                                    color: primaryColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '$_nights nuit${_nights > 1 ? 's' : ''}',
                                  style: GoogleFonts.poppins(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Validations
                  if (_nights > 0 && _nights < widget.minStay) ...[
                    const SizedBox(height: 8),
                    _buildInfoBox(
                      'Séjour minimum : ${widget.minStay} nuit${widget.minStay > 1 ? 's' : ''}',
                      Colors.orange,
                      Icons.info_outline,
                    ),
                  ],

                  if (_nights > widget.maxStay) ...[
                    const SizedBox(height: 8),
                    _buildInfoBox(
                      'Séjour maximum : ${widget.maxStay} nuits',
                      Colors.orange,
                      Icons.info_outline,
                    ),
                  ],

                  if (!_isAvailable &&
                      _checkIn != null &&
                      _checkOut != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoBox(
                      'Non disponible pour ces dates',
                      Colors.red,
                      Icons.event_busy,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Nombre d'invités
                  Text(
                    'Nombre d\'invités',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircularButton(
                          icon: Icons.remove,
                          onPressed: _guests > 1
                              ? () => setState(() => _guests--)
                              : null,
                        ),
                        Column(
                          children: [
                            Text(
                              '$_guests',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'invité${_guests > 1 ? 's' : ''} (max: ${widget.maxGuests})',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        _buildCircularButton(
                          icon: Icons.add,
                          onPressed: _guests < widget.maxGuests
                              ? () => setState(() => _guests++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  Text(
                    'Commentaires (optionnel)',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Informations supplémentaires...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),

                  // Récapitulatif des prix
                  if (_nights > 0) ...[
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${NumberFormat('#,###').format(widget.pricePerNight)} GNF x $_nights nuit${_nights > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###').format(_totalPrice)} GNF',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###').format(_totalPrice)} GNF',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Message d'erreur
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoBox(
                        _errorMessage!, Colors.red, Icons.error_outline),
                  ],

                  const SizedBox(height: 24),

                  // Bouton de confirmation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canBook ? _confirmBooking : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading || _isCheckingAvailability
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Confirmer la réservation',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required String time,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: date != null ? primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Choisir',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: date != null ? Colors.grey[800] : Colors.grey[500],
                ),
              ),
              if (date != null)
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null ? primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : Colors.grey[500],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
