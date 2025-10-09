import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/widgets.dart';
import 'package:intl/intl.dart';

class DailyRentalFilterModal extends StatefulWidget {
  final Function(double, double, String, String, int, DateTime?, DateTime?)
      onApplyFilter;
  final double currentMinPrice;
  final double currentMaxPrice;
  final String currentPropertyType;
  final String currentVille;
  final int currentMinGuests;
  final DateTime? currentCheckIn;
  final DateTime? currentCheckOut;

  const DailyRentalFilterModal({
    super.key,
    required this.onApplyFilter,
    this.currentMinPrice = 0,
    this.currentMaxPrice = double.infinity,
    this.currentPropertyType = 'Tous',
    this.currentVille = '',
    this.currentMinGuests = 0,
    this.currentCheckIn,
    this.currentCheckOut,
  });

  @override
  State<DailyRentalFilterModal> createState() => _DailyRentalFilterModalState();
}

class _DailyRentalFilterModalState extends State<DailyRentalFilterModal> {
  late String _propertyType;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _villeController;
  late int _minGuests;
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    _propertyType = widget.currentPropertyType;
    _minGuests = widget.currentMinGuests;
    _checkIn = widget.currentCheckIn;
    _checkOut = widget.currentCheckOut;

    _minPriceController = TextEditingController(
      text: widget.currentMinPrice > 0
          ? widget.currentMinPrice.toInt().toString()
          : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentMaxPrice.isFinite
          ? widget.currentMaxPrice.toInt().toString()
          : '',
    );
    _villeController = TextEditingController(text: widget.currentVille);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  String get _nightsText {
    if (_checkIn != null && _checkOut != null) {
      final nights = _checkOut!.difference(_checkIn!).inDays;
      return '$nights nuit${nights > 1 ? 's' : ''}';
    }
    return 'Non défini';
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
                          Icons.tune,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filtrer les logements',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _resetAllFilters,
                        child: Text(
                          'Réinitialiser',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dates de séjour
                  _buildSectionTitle('Dates de séjour'),
                  const SizedBox(height: 12),
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // Nombre d'invités
                  _buildSectionTitle('Nombre d\'invités'),
                  const SizedBox(height: 12),
                  _buildGuestSelector(),
                  const SizedBox(height: 24),

                  // Localisation
                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: 12),
                  _buildLocationField(),
                  const SizedBox(height: 24),

                  // Type de propriété
                  _buildSectionTitle('Type de propriété'),
                  const SizedBox(height: 12),
                  _buildPropertyTypeGrid(),
                  const SizedBox(height: 24),

                  // Budget par nuit
                  _buildSectionTitle('Budget par nuit'),
                  const SizedBox(height: 12),
                  _buildBudgetFields(),
                  const SizedBox(height: 32),

                  // Bouton appliquer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(
                        'Voir les résultats',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      );

  Widget _buildDateSelector() {
    return Container(
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
                  onTap: () => _selectCheckInDate(context),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: 'Départ',
                  date: _checkOut,
                  onTap: () => _selectCheckOutDate(context),
                ),
              ),
            ],
          ),
          if (_checkIn != null && _checkOut != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    _nightsText,
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: date != null ? Colors.grey[800] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        _checkIn = picked;
        if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
          _checkOut = null;
        }
      });
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
        _checkOut = picked;
      });
    }
  }

  Widget _buildGuestSelector() {
    return Container(
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
            onPressed:
                _minGuests > 0 ? () => setState(() => _minGuests--) : null,
          ),
          Column(
            children: [
              Text(
                '$_minGuests',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'invité${_minGuests > 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          _buildCircularButton(
            icon: Icons.add,
            onPressed: () => setState(() => _minGuests++),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _villeController,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Ville, commune, quartier...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
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

  Widget _buildPropertyTypeGrid() {
    final types = [
      {'label': 'Tous', 'icon': Icons.dashboard_outlined},
      {'label': 'Villa', 'icon': Icons.villa_outlined},
      {'label': 'Maison', 'icon': Icons.home_outlined},
      {'label': 'Appartement', 'icon': Icons.apartment_outlined},
      {'label': 'Studio', 'icon': Icons.single_bed_outlined},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _propertyType == type['label'];
        return buildPropertyTypeChip(
          label: type['label'] as String,
          icon: type['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => setState(() => _propertyType = type['label'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetFields() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Prix min',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixText: 'GNF ',
              prefixStyle:
                  GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
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
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Prix max',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixText: 'GNF ',
              prefixStyle:
                  GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
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
        ),
      ],
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

  void _resetAllFilters() {
    setState(() {
      _propertyType = 'Tous';
      _minPriceController.clear();
      _maxPriceController.clear();
      _villeController.clear();
      _minGuests = 0;
      _checkIn = null;
      _checkOut = null;
    });
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text) ?? 0;
    final maxPrice =
        double.tryParse(_maxPriceController.text) ?? double.infinity;

    widget.onApplyFilter(
      minPrice,
      maxPrice,
      _propertyType,
      _villeController.text,
      _minGuests,
      _checkIn,
      _checkOut,
    );

    Navigator.pop(context);
  }
}
