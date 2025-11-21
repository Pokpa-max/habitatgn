import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
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
  final PriceType? priceType;

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
    this.priceType,
  });

  @override
  State<UnifiedDailyRentalModal> createState() =>
      _UnifiedDailyRentalModalState();
}

class _UnifiedDailyRentalModalState extends State<UnifiedDailyRentalModal> {
  late final DailyRentalService _service;
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

  static final _priceFormatter = NumberFormat('#,###');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _service = DailyRentalService();
    _initializeControllers();
  }

  void _initializeControllers() {
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

  // ============ CALCULS DE DURÉE ============

  /// Obtient le nombre de jours entre check-in et check-out
  int get _daysDifference {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  /// Calcule la durée selon le type de tarification
  /// - Hourly: nombre d'heures
  /// - Daily: nombre de jours
  /// - Weekly: arrondir au nombre de semaines (ceil) - 1 semaine = 7 jours
  /// - Monthly: arrondir au nombre de mois (ceil) - 1 mois = 30 jours
  int get _duration {
    if (_checkIn == null || _checkOut == null) return 0;

    final difference = _checkOut!.difference(_checkIn!);

    switch (widget.priceType) {
      case PriceType.hourly:
        final hours = difference.inHours;
        return hours > 0 ? hours : 1;

      case PriceType.weekly:
        // Arrondir à la semaine supérieure (ceil)
        final weeks = (difference.inDays / 7).ceil();
        return weeks > 0 ? weeks : 1;

      case PriceType.monthly:
        // Arrondir au mois supérieur (ceil)
        final months = (difference.inDays / 30).ceil();
        return months > 0 ? months : 1;

      case PriceType.daily:
      default:
        return difference.inDays;
    }
  }

  /// Obtient le nombre réel de jours facturés
  /// Utilisé pour l'affichage détaillé du calcul de prix
  /// Ex: 1 semaine = 7 jours facturés, même si vous n'en utilisez que 5
  int get _daysCharged {
    if (_duration <= 0) return 0;

    switch (widget.priceType) {
      case PriceType.weekly:
        return _duration * 7;
      case PriceType.monthly:
        return _duration * 30;
      case PriceType.daily:
      case PriceType.hourly:
      default:
        return _duration;
    }
  }

  /// Obtient le message de remplissage (jours bonus inclus)
  /// Ex: "3 jours inclus" pour une semaine utilisée sur 4 jours
  String? get _durationFillMessage {
    if (_duration <= 0 || _daysDifference <= 0) return null;

    final bonus = _daysCharged - _daysDifference;
    if (bonus <= 0) return null;

    switch (widget.priceType) {
      case PriceType.weekly:
        return bonus > 0
            ? '+$bonus jour${bonus > 1 ? 's' : ''} inclus au tarif'
            : null;

      case PriceType.monthly:
        return bonus > 0
            ? '+$bonus jour${bonus > 1 ? 's' : ''} inclus au tarif'
            : null;

      default:
        return null;
    }
  }

  /// Retourne le label de l'unité de durée (pluralisé si nécessaire)
  String get _durationLabel {
    switch (widget.priceType) {
      case PriceType.hourly:
        return _duration == 1 ? 'heure' : 'heures';
      case PriceType.weekly:
        return _duration == 1 ? 'semaine' : 'semaines';
      case PriceType.monthly:
        return _duration == 1 ? 'mois' : 'mois';
      case PriceType.daily:
      default:
        return _duration == 1 ? 'jour' : 'jours';
    }
  }

  /// Retourne le suffixe du prix (ex: "/jour", "/heure")
  String get _priceSuffix => widget.priceType?.priceSuffix ?? '/jour';

  /// Retourne le label du type de tarification
  String get _priceTypeLabel => widget.priceType?.label ?? 'Par jour';

  /// Détermine si la validation minStay/maxStay doit être appliquée
  /// (seulement pour la tarification journalière)
  bool get _shouldValidateDuration =>
      widget.priceType == PriceType.daily || widget.priceType == null;

  /// Calcule le prix total
  double get _totalPrice => widget.pricePerNight * _duration;

  // ============ VALIDATIONS ============

  /// Vérifie si la réservation peut être confirmée
  bool get _canBook =>
      _checkIn != null &&
      _checkOut != null &&
      _guests > 0 &&
      _guests <= widget.maxGuests &&
      (_shouldValidateDuration
          ? (_duration >= widget.minStay && _duration <= widget.maxStay)
          : true) &&
      _isAvailable &&
      !_isLoading &&
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  // ============ FONCTIONS ASYNC ============

  /// Vérifie la disponibilité du logement pour les dates sélectionnées
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

  /// Affiche le sélecteur de date
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
      _updateDate(isCheckIn, picked);
    }
  }

  /// Met à jour la date et recalcule la disponibilité
  void _updateDate(bool isCheckIn, DateTime picked) {
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

  /// Confirme la réservation et l'envoie au service
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
        bookingTpe: widget.priceType!,
        guestName: _nameController.text.trim(),
        guestPhone: _phoneController.text.trim(),
        houseImageUrl: widget.houseImageUrl,
      );

      if (!mounted) return;

      if (bookingId != null) {
        Navigator.pop(context);
        showToast(context, 'Réservation effectuée avec succès !', primaryColor);
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

  // ============ ACTIONS UI ============

  /// Affiche un snack bar avec un message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  /// Ajuste le nombre d'invités
  void _adjustGuests(int delta) {
    final newGuests = _guests + delta;
    if (newGuests >= 1 && newGuests <= widget.maxGuests) {
      setState(() => _guests = newGuests);
    }
  }

  // ============ HELPERS UI ============

  /// Retourne l'icône correspondant au type de tarification
  IconData _getPriceTypeIcon() {
    switch (widget.priceType) {
      case PriceType.hourly:
        return Icons.schedule;
      case PriceType.weekly:
      case PriceType.monthly:
        return Icons.calendar_month;
      case PriceType.daily:
      default:
        return Icons.calendar_today;
    }
  }

  // ============ BUILD METHODS ============

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
                  if (widget.priceType != null) _buildPriceTypeIndicator(),
                  _buildGuestInfoSection(),
                  const Divider(height: 32),
                  _buildDatesSection(),
                  _buildValidationMessages(),
                  const SizedBox(height: 24),
                  _buildGuestsSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  if (_duration > 0) ...[
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

  Widget _buildPriceTypeIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getPriceTypeIcon(),
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarification: $_priceTypeLabel',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  '${_priceFormatter.format(widget.pricePerNight)} GNF$_priceSuffix',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vos informations'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
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
        _buildSectionTitle('Dates du séjour'),
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
              if (_duration > 0) _buildDurationIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationIndicator() {
    final hasBonus =
        _durationFillMessage != null && _durationFillMessage!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Durée calculée
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getPriceTypeIcon(), color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$_duration $_durationLabel',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($_daysDifference jours)',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Info bonus pour semaine/mois
          if (hasBonus) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 14, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _durationFillMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationMessages() {
    return Column(
      children: [
        if (_shouldValidateDuration &&
            _duration > 0 &&
            _duration < widget.minStay) ...[
          const SizedBox(height: 8),
          _buildInfoBox(
            'Minimum: ${widget.minStay} ${_durationLabel}',
            Colors.orange,
            Icons.info_outline,
          ),
        ],
        if (_shouldValidateDuration && _duration > widget.maxStay) ...[
          const SizedBox(height: 8),
          _buildInfoBox(
            'Maximum: ${widget.maxStay} ${_durationLabel}',
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
        _buildSectionTitle('Nombre d\'invités'),
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
        _buildSectionTitle('Commentaires (optionnel)'),
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
    final hasBonusDays =
        _durationFillMessage != null && _durationFillMessage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Ligne de calcul principal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_priceFormatter.format(widget.pricePerNight)} GNF × $_duration $_durationLabel',
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

          // Message des jours bonus si applicable
          if (hasBonusDays) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _durationFillMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 16),

          // Total final
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (widget.priceType != null)
                    Text(
                      _priceTypeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
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
    final isSelected = date != null;
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
              color: isSelected ? primaryColor : Colors.grey[300]!,
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
                isSelected ? _dateFormatter.format(date) : 'Choisir',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.grey[800] : Colors.grey[500],
                ),
              ),
              if (isSelected)
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
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEnabled ? primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.grey[500],
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
