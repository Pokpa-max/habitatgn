import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateAccountPage extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  CreateAccountPage({super.key});
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Créez votre compte",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: nameController,
                    hintText: 'Nom & Présnom',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Mot de passe',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: isPasswordVisible,
                    onVisibilityToggle: () {
                      ref
                          .read(passwordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirmer le mot de passe',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      ref
                          .read(confirmPasswordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                        fillColor: WidgetStateProperty.resolveWith(
                            (states) => primaryColor),
                      ),
                      const Text(
                        'J’accepte les conditions d’utilisation',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isCreatingAccount
                          ? null
                          : () async {
                              // Votre logique de création de compte existante
                              // Validation des champs
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty ||
                                  confirmPasswordController.text.isEmpty ||
                                  nameController.text.isEmpty) {
                                authProvider.showErrorMessage(
                                  color: primaryColor,
                                  context,
                                  "Veuillez remplir tous les champs.",
                                );
                                return;
                              }

                              // Validation de l'email
                              if (!_isValidEmail(emailController.text)) {
                                authProvider.showErrorMessage(
                                  context,
                                  "Veuillez entrer une adresse email valide.",
                                );
                                return;
                              }
                              // Vérification si les mots de passe correspondent
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                authProvider.showErrorMessage(
                                  context,
                                  "Les mots de passe ne correspondent pas.",
                                );
                                return;
                              }

                              // Validation de la longueur du mot de passe
                              if (passwordController.text.length < 6) {
                                authProvider.showErrorMessage(
                                  context,
                                  "Le mot de passe doit contenir au moins 6 caractères.",
                                );
                                return;
                              }

                              final List<ConnectivityResult>
                                  connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              // Vérifiez l'état de la connexion Internet
                              if ((connectivityResult
                                  .contains(ConnectivityResult.none))) {
                                authProvider.showErrorMessage(
                                    context, 'Connexion Internet indisponible.',
                                    color: Colors.red);
                                return;
                              } else {
                                await authProvider
                                    .createUserWithEmailAndPassword(
                                        context,
                                        emailController.text,
                                        passwordController.text,
                                        nameController.text);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: authProvider.isCreatingAccount
                          ? const SpinKitFadingCircle(
                              color: primaryColor,
                              size: 20.0,
                            )
                          : const Text(
                              'Créez votre compte',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Naviguer vers la page de connexion
                        authProvider.navigateToLogin(context);
                      },
                      child: const Text(
                        'Avez déjà un compte ? Connectez-vous',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final Function(double, double, String, String, String, int, bool)
      onApplyFilter;
  const FilterModal({super.key, required this.onApplyFilter});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _propertyType = 'Tous';
  String _needType = 'Tous';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  int _bedrooms = 0;
  bool _hasChanges = false;
  final backgroundColor = Colors.white;
  final surfaceColor = const Color(0xFFF3F4F6);

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête fixe
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _needType = 'Tous';
                      _propertyType = 'Tous';
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      _villeController.clear();
                      _bedrooms = 0;
                      _hasChanges = false;
                    });
                  },
                  child: Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu défilable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Type de besoin (Compact)
                  _buildSectionTitle("J'ai besoin de"),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Tous', 'Louer', 'Acheter'].map((type) {
                      final isSelected = _needType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() {
                              _needType = type;
                              _hasChanges = true;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Section Ville (Compact)
                  _buildSectionTitle("Emplacement"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _villeController,
                    decoration: InputDecoration(
                      hintText: 'Ville, commune...',
                      prefixIcon:
                          const Icon(Icons.location_on_outlined, size: 20),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                  const SizedBox(height: 16),

                  // Section Budget (Compact)
                  _buildSectionTitle("Budget"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceField('Min', _minPriceController),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriceField('Max', _maxPriceController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section Type de propriété (Grid compact)
                  _buildSectionTitle("Type de propriété"),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.5,
                    children: [
                      _buildPropertyTypeChip('Tous', Icons.dashboard_outlined),
                      _buildPropertyTypeChip('Maison', Icons.home_outlined),
                      _buildPropertyTypeChip(
                          'Appart.', Icons.apartment_outlined),
                      _buildPropertyTypeChip(
                          'Studio', Icons.single_bed_outlined),
                      _buildPropertyTypeChip('Villa', Icons.villa_outlined),
                      _buildPropertyTypeChip('Bureau', Icons.business_outlined),
                    ],
                  ),
                  if (_propertyType != 'Terrain') ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle("Chambres"),
                    const SizedBox(height: 8),
                    _buildBedroomSelector(),
                  ],
                ],
              ),
            ),
          ),

          // Bouton Appliquer (Fixe en bas)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                double minPrice =
                    double.tryParse(_minPriceController.text) ?? 0;
                double maxPrice = double.tryParse(_maxPriceController.text) ??
                    double.infinity;
                widget.onApplyFilter(
                  minPrice,
                  maxPrice,
                  _needType,
                  _propertyType,
                  _villeController.text,
                  _bedrooms,
                  _hasChanges,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Appliquer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '$label €',
        prefixIcon: const Icon(Icons.euro_outlined, size: 20),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildPropertyTypeChip(String label, IconData icon) {
    final isSelected = _propertyType == label;
    return GestureDetector(
      onTap: () => setState(() {
        _propertyType = label;
        _hasChanges = true;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedroomSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: _bedrooms > 0
                ? () => setState(() {
                      _bedrooms--;
                      _hasChanges = true;
                    })
                : null,
          ),
          Text(
            '$_bedrooms',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => setState(() {
              _bedrooms++;
              _hasChanges = true;
            }),
          ),
        ],
      ),
    );
  }
}
