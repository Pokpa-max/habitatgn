// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:habitatgn/services/reservation/reservation_service.dart';
// import 'package:habitatgn/utils/appcolors.dart';

// class ReservationModal extends StatefulWidget {
//   final String houseId;
//   final String houseTitle;
//   final String houseLocation;
//   final double housePrice;
//   final VoidCallback? onReservationSuccess;

//   const ReservationModal({
//     super.key,
//     required this.houseId,
//     required this.houseTitle,
//     required this.houseLocation,
//     required this.housePrice,
//     this.onReservationSuccess,
//   });

//   @override
//   State<ReservationModal> createState() => _ReservationModalState();
// }

// class _ReservationModalState extends State<ReservationModal> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _messageController = TextEditingController();

//   DateTime? _selectedVisitDate;
//   bool _isLoading = false;

//   final ReservationService _reservationService = ReservationService();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.9,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           Flexible(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: primaryColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.event_available_outlined,
//                             color: primaryColor,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Réserver ce logement',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                               Text(
//                                 'Prenez rendez-vous avec le propriétaire',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // Infos du logement
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   widget.houseTitle,
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey[800],
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 '${widget.housePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} F',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.location_on_outlined,
//                                   size: 16, color: Colors.grey[600]),
//                               const SizedBox(width: 4),
//                               Text(
//                                 widget.houseLocation,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Formulaire
//                     Text(
//                       'Vos informations',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     _buildTextField(
//                       controller: _nameController,
//                       label: 'Nom complet',
//                       icon: Icons.person_outline,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Veuillez entrer votre nom';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     _buildTextField(
//                       controller: _phoneController,
//                       label: 'Numéro de téléphone',
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Veuillez entrer votre numéro';
//                         }
//                         if (value.length < 8) {
//                           return 'Numéro trop court';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     _buildTextField(
//                       controller: _emailController,
//                       label: 'Email',
//                       icon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Veuillez entrer votre email';
//                         }
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                             .hasMatch(value)) {
//                           return 'Email invalide';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),

//                     // Date de visite
//                     Text(
//                       'Date de visite souhaitée',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     InkWell(
//                       onTap: _selectVisitDate,
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey[300]!),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.calendar_today_outlined,
//                                 color: primaryColor),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 _selectedVisitDate != null
//                                     ? 'Le ${_formatDate(_selectedVisitDate!)}'
//                                     : 'Sélectionner une date (optionnel)',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: _selectedVisitDate != null
//                                       ? Colors.grey[800]
//                                       : Colors.grey[500],
//                                 ),
//                               ),
//                             ),
//                             Icon(Icons.chevron_right, color: Colors.grey[400]),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Message
//                     Text(
//                       'Message au propriétaire',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     TextFormField(
//                       controller: _messageController,
//                       maxLines: 4,
//                       style: GoogleFonts.poppins(fontSize: 14),
//                       decoration: InputDecoration(
//                         hintText: 'Votre message (optionnel)...',
//                         hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: primaryColor, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.all(16),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Boutons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               side: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             child: Text(
//                               'Annuler',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           flex: 2,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _submitReservation,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : Text(
//                                     'Envoyer la demande',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // Note informative
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline,
//                               color: Colors.blue[600], size: 16),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Lagence recevra votre demande et vous contactera.',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: Colors.blue[700],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: GoogleFonts.poppins(fontSize: 14),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//         prefixIcon: Icon(icon, color: primaryColor),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: primaryColor, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }

//   Future<void> _selectVisitDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedVisitDate = picked;
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     const months = [
//       '',
//       'janvier',
//       'février',
//       'mars',
//       'avril',
//       'mai',
//       'juin',
//       'juillet',
//       'août',
//       'septembre',
//       'octobre',
//       'novembre',
//       'décembre'
//     ];
//     return '${date.day} ${months[date.month]} ${date.year}';
//   }

//   Future<void> _submitReservation() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final success = await _reservationService.requestReservation(
//         houseId: widget.houseId,
//         userName: _nameController.text.trim(),
//         userPhone: _phoneController.text.trim(),
//         userEmail: _emailController.text.trim(),
//         visitDate: _selectedVisitDate,
//         message: _messageController.text.trim().isNotEmpty
//             ? _messageController.text.trim()
//             : null,
//       );

//       if (success) {
//         Navigator.pop(context);
//         widget.onReservationSuccess?.call();

//         // Afficher message de succès
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Demande de réservation envoyée avec succès !',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: primaryColor,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       } else {
//         throw Exception('Erreur lors de l\'envoi');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red[600],
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

// // Fonction helper pour afficher le modal
// void showReservationModal(
//   BuildContext context, {
//   required String houseId,
//   required String houseTitle,
//   required String houseLocation,
//   required double housePrice,
//   VoidCallback? onReservationSuccess,
// }) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => ReservationModal(
//       houseId: houseId,
//       houseTitle: houseTitle,
//       houseLocation: houseLocation,
//       housePrice: housePrice,
//       onReservationSuccess: onReservationSuccess,
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/services/reservation/reservation_service.dart';
import 'package:habitatgn/utils/appcolors.dart';

class ReservationModal extends StatefulWidget {
  final String houseId;
  final String houseTitle;
  final String houseLocation;
  final int maxGuests;
  final VoidCallback? onReservationSuccess;

  const ReservationModal({
    super.key,
    required this.houseId,
    required this.houseTitle,
    required this.houseLocation,
    required this.maxGuests,
    this.onReservationSuccess,
  });

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  bool _isLoading = false;

  final ReservationService _reservationService = ReservationService();

  int get numberOfNights {
    if (_checkInDate != null && _checkOutDate != null) {
      return _checkOutDate!.difference(_checkInDate!).inDays;
    }
    return 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.hotel_outlined,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Réserver ce logement',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Compléter votre demande',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Infos du logement
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.houseTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.houseLocation,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dates de séjour
                    Text(
                      'Dates de séjour',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectCheckInDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Arrivée',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _checkInDate != null
                                        ? _formatDate(_checkInDate!)
                                        : 'Sélectionner',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _checkInDate != null
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectCheckOutDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Départ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _checkOutDate != null
                                        ? _formatDate(_checkOutDate!)
                                        : 'Sélectionner',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _checkOutDate != null
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Affichage du nombre de nuits
                    if (numberOfNights > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.nights_stay_outlined,
                                color: primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '$numberOfNights nuit${numberOfNights > 1 ? 's' : ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
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
                            onPressed: _numberOfGuests > 1
                                ? () => setState(() => _numberOfGuests--)
                                : null,
                          ),
                          Column(
                            children: [
                              Text(
                                '$_numberOfGuests',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'invité${_numberOfGuests > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          _buildCircularButton(
                            icon: Icons.add,
                            onPressed: _numberOfGuests < widget.maxGuests
                                ? () => setState(() => _numberOfGuests++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Formulaire contact
                    Text(
                      'Vos informations de contact',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Nom complet',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Numéro de téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Numéro trop court';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Message
                    Text(
                      'Message (optionnel)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _messageController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Informations complémentaires...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'Annuler',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: (_isLoading || numberOfNights <= 0)
                                ? null
                                : _submitReservation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    numberOfNights > 0
                                        ? 'Envoyer la demande'
                                        : 'Sélectionner les dates',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // Note informative
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[600], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Le propriétaire recevra votre demande et vous contactera.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCircularButton(
      {required IconData icon, VoidCallback? onPressed}) {
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

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null &&
            _checkOutDate!.isBefore(picked.add(const Duration(days: 1)))) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord sélectionner la date d\'arrivée',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jui',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return '${date.day} ${months[date.month]}';
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner les dates de séjour',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = _messageController.text.trim().isNotEmpty
          ? '${_messageController.text.trim()}\n\nDétails:\n- Arrivée: ${_formatDate(_checkInDate!)}\n- Départ: ${_formatDate(_checkOutDate!)}\n- Invités: $_numberOfGuests\n- Durée: $numberOfNights nuit${numberOfNights > 1 ? 's' : ''}'
          : 'Séjour du ${_formatDate(_checkInDate!)} au ${_formatDate(_checkOutDate!)} pour $_numberOfGuests invité${_numberOfGuests > 1 ? 's' : ''} ($numberOfNights nuit${numberOfNights > 1 ? 's' : ''})';

      final success = await _reservationService.requestReservation(
        houseId: widget.houseId,
        userName: _nameController.text.trim(),
        userPhone: _phoneController.text.trim(),
        userEmail: _emailController.text.trim(),
        visitDate: _checkInDate,
        message: message,
      );

      if (success) {
        Navigator.pop(context);
        widget.onReservationSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Demande de réservation envoyée avec succès !',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Erreur lors de l\'envoi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Fonction helper pour afficher le modal
// void showSimpleReservationModal(
//   BuildContext context, {
//   required String houseId,
//   required String houseTitle,
//   required String houseLocation,
//   required int maxGuests,
//   VoidCallback? onReservationSuccess,
// }) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => SimpleReservationModal(
//       houseId: houseId,
//       houseTitle: houseTitle,
//       houseLocation: houseLocation,
//       maxGuests: maxGuests,
//       onReservationSuccess: onReservationSuccess,
//     ),
//   );
// }
// Fonction helper pour afficher le modal
void showReservationModal(
  BuildContext context, {
  required String houseId,
  required String houseTitle,
  required String houseLocation,
  required double housePrice,
  required int maxGuests,
  VoidCallback? onReservationSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReservationModal(
      houseId: houseId,
      houseTitle: houseTitle,
      houseLocation: houseLocation,
      maxGuests: maxGuests,
      onReservationSuccess: onReservationSuccess,
    ),
  );
}
