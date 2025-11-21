import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:intl/intl.dart';

class RentalCardPricing extends StatelessWidget {
  final DailyRental rental;

  const RentalCardPricing({
    required this.rental,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final availableTypes = rental.availablePriceTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Prix principal
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat('#,###').format(rental.mainPrice),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              rental.priceSuffix,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        // Indicateur de tarification multiple
        if (availableTypes.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '(+${availableTypes.length - 1} option)',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class InteractivePriceSelector extends StatefulWidget {
  final DailyRental rental;
  final Function(PriceType)? onPriceTypeChanged;

  const InteractivePriceSelector({
    required this.rental,
    this.onPriceTypeChanged,
    super.key,
  });

  @override
  State<InteractivePriceSelector> createState() =>
      _InteractivePriceSelectorState();
}

class _InteractivePriceSelectorState extends State<InteractivePriceSelector> {
  late PriceType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.rental.mainPriceType;
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = widget.rental.availablePriceTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prix actuel en grand
        Row(
          children: [
            Text(
              NumberFormat('#,###').format(
                widget.rental.getPriceForType(_selectedType) ?? 0,
              ),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              PriceType.getSuffixForType(_selectedType),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sélecteur de type de prix
        if (availableTypes.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTypes.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedType = type);
                  widget.onPriceTypeChanged?.call(type);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    type.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
