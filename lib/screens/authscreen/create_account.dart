import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _acceptedTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(authProvider, isPasswordVisible,
                      isConfirmPasswordVisible),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      authProvider, bool isPasswordVisible, bool isConfirmPasswordVisible) {
    return Column(
      children: [
        // Header avec bouton retour
        _buildHeader(),

        // Contenu principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Logo et titre
                _buildTitleSection(),

                const SizedBox(height: 20),

                // Formulaire
                _buildFormSection(
                    authProvider, isPasswordVisible, isConfirmPasswordVisible),

                const SizedBox(height: 10),

                // Lien vers connexion
                _buildLoginLink(authProvider),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.grey[700],
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Logo H
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryColor,
                blurRadius: 18,
                // offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "H",
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Titre
        Text(
          "Créer un compte",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        Text(
          "Commencez votre aventure avec HabitatGN",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormSection(
      authProvider, bool isPasswordVisible, bool isConfirmPasswordVisible) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ nom
          _buildTextField(
            controller: nameController,
            focusNode: _nameFocus,
            hintText: 'Nom & Prénom',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 10),

          // Champ email
          _buildTextField(
            controller: emailController,
            focusNode: _emailFocus,
            hintText: 'Adresse email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 10),

          // Champ mot de passe
          _buildTextField(
            controller: passwordController,
            focusNode: _passwordFocus,
            hintText: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: isPasswordVisible,
            onVisibilityToggle: () {
              ref.read(passwordVisibilityProvider.notifier).toggleVisibility();
            },
          ),

          const SizedBox(height: 10),

          // Champ confirmation mot de passe
          _buildTextField(
            controller: confirmPasswordController,
            focusNode: _confirmPasswordFocus,
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

          const SizedBox(height: 10),

          // Conditions d'utilisation
          _buildTermsCheckbox(),

          const SizedBox(height: 10),

          // Bouton de création
          _buildCreateAccountButton(authProvider),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: focusNode.hasFocus
            ? primaryColor.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus
              ? primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !isVisible,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        onChanged: (value) {
          setState(() {}); // Pour mettre à jour l'état de focus
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: focusNode.hasFocus ? primaryColor : Colors.grey[600],
              size: 20,
            ),
          ),
          suffixIcon: isPassword
              ? Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "J’accepte les CGU et la politique de confidentialité.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton(authProvider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: authProvider.isSigningUp
              ? null
              : () => _handleCreateAccount(authProvider),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: authProvider.isSigningUp
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Créer mon compte',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(authProvider) {
    return TextButton(
      onPressed: authProvider.isSigningUp
          ? null
          : () => authProvider.navigateToLogin(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          children: [
            const TextSpan(text: "Déjà un compte ? "),
            TextSpan(
              text: "Se connecter",
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode de gestion de la création de compte
  Future<void> _handleCreateAccount(authProvider) async {
    // Validations
    if (_isFormInvalid(authProvider)) return;

    // Vérification connexion internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      authProvider.showErrorMessage(
        context,
        'Connexion Internet indisponible',
        color: Colors.orange[700],
      );
      return;
    }

    // Création du compte
    await authProvider.createUserWithEmailAndPassword(
      context,
      emailController.text.trim(),
      passwordController.text,
      nameController.text.trim(),
    );
  }

  bool _isFormInvalid(authProvider) {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      authProvider.showErrorMessage(
        context,
        "Veuillez remplir tous les champs",
        color: primaryColor,
      );
      return true;
    }

    if (!_isValidEmail(emailController.text)) {
      authProvider.showErrorMessage(
        context,
        "Format d'email invalide",
        color: Colors.orange[700],
      );
      return true;
    }

    if (passwordController.text != confirmPasswordController.text) {
      authProvider.showErrorMessage(
        context,
        "Les mots de passe ne correspondent pas",
        color: Colors.orange[700],
      );
      return true;
    }

    if (passwordController.text.length < 6) {
      authProvider.showErrorMessage(
        context,
        "Le mot de passe doit contenir au moins 6 caractères",
        color: Colors.orange[700],
      );
      return true;
    }

    if (!_acceptedTerms) {
      authProvider.showErrorMessage(
        context,
        "Veuillez accepter les conditions d'utilisation",
        color: Colors.orange[700],
      );
      return true;
    }

    return false;
  }
}
