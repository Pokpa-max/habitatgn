import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:intl/intl.dart';

class UnifiedDailyRentalModal extends StatefulWidget {
  final String houseId;
  final String houseTitle;
  final String houseLocation;
  final String houseImageUrl;
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
    required this.houseImageUrl,
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

  late final TextEditingController _notesController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = true;
  String? _errorMessage;

  // Formatters en cache
  static final _priceFormatter = NumberFormat('#,###');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  int get _nights => _checkIn != null && _checkOut != null
      ? _checkOut!.difference(_checkIn!).inDays
      : 0;

  double get _totalPrice => widget.pricePerNight * _nights;

  bool get _canBook =>
      _checkIn != null &&
      _checkOut != null &&
      _guests > 0 &&
      _guests <= widget.maxGuests &&
      _nights >= widget.minStay &&
      _nights <= widget.maxStay &&
      _isAvailable &&
      !_isLoading &&
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

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

      if (!mounted) return;

      setState(() {
        _isAvailable = available;
        _isCheckingAvailability = false;
        _errorMessage = available
            ? null
            : 'Ce logement n\'est pas disponible pour ces dates';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingAvailability = false;
        _errorMessage = 'Erreur lors de la vérification de disponibilité';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    if (!isCheckIn && _checkIn == null) {
      _showSnackBar(
        'Veuillez d\'abord sélectionner la date d\'arrivée',
        Colors.orange,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? DateTime.now())
          : (_checkOut ?? _checkIn!.add(const Duration(days: 1))),
      firstDate:
          isCheckIn ? DateTime.now() : _checkIn!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = DateTime(
            picked.year,
            picked.month,
            picked.day,
            widget.checkInHour,
          );
          if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
            _checkOut = null;
          }
        } else {
          _checkOut = DateTime(
            picked.year,
            picked.month,
            picked.day,
            widget.checkOutHour,
          );
        }
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
        guestName: _nameController.text.trim(),
        guestPhone: _phoneController.text.trim(),
        houseImageUrl: widget.houseImageUrl,
      );

      if (!mounted) return;

      if (bookingId != null) {
        Navigator.pop(context);
        _showSnackBar('Réservation effectuée avec succès !', Colors.green);
        widget.onBookingSuccess?.call();
      } else {
        setState(() => _errorMessage = 'Erreur lors de la réservation');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  void _adjustGuests(int delta) {
    final newGuests = _guests + delta;
    if (newGuests >= 1 && newGuests <= widget.maxGuests) {
      setState(() => _guests = newGuests);
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
          _buildHandleBar(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 32),
                  _buildGuestInfoSection(),
                  const Divider(height: 32),
                  _buildDatesSection(),
                  _buildValidationMessages(),
                  const SizedBox(height: 24),
                  _buildGuestsSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  if (_nights > 0) ...[
                    const Divider(height: 32),
                    _buildPriceSummary(),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoBox(
                        _errorMessage!, Colors.red, Icons.error_outline),
                  ],
                  const SizedBox(height: 24),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.book_online, color: primaryColor, size: 20),
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
            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
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
      ],
    );
  }

  Widget _buildGuestInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos informations',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          label: 'Nom complet',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: primaryColor),
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
    );
  }

  Widget _buildDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      onTap: () => _selectDate(context, true),
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
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              if (_nights > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nights_stay, color: primaryColor, size: 16),
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
      ],
    );
  }

  Widget _buildValidationMessages() {
    return Column(
      children: [
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
        if (!_isAvailable && _checkIn != null && _checkOut != null) ...[
          const SizedBox(height: 8),
          _buildInfoBox(
            'Non disponible pour ces dates',
            Colors.red,
            Icons.event_busy,
          ),
        ],
      ],
    );
  }

  Widget _buildGuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onPressed: _guests > 1 ? () => _adjustGuests(-1) : null,
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
                onPressed:
                    _guests < widget.maxGuests ? () => _adjustGuests(1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
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
                '${_priceFormatter.format(widget.pricePerNight)} GNF x $_nights nuit${_nights > 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${_priceFormatter.format(_totalPrice)} GNF',
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
                '${_priceFormatter.format(_totalPrice)} GNF',
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
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                date != null ? _dateFormatter.format(date) : 'Choisir',
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
