import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF42C8F5);
const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _textPrimaryColor = Color(0xFF1F2937);
const _textSecondaryColor = Color(0xFF4B5563);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _inputColor = Color(0xFFF3F6FA);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.onResetPassword,
  });

  final Future<void> Function(String email)? onResetPassword;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  _FormMessage? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    setState(() => _message = null);

    if (email.isEmpty) {
      setState(() {
        _message = const _FormMessage(
          ok: false,
          text: 'Please enter your email.',
        );
      });
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.onResetPassword?.call(email);
      if (!mounted) return;

      setState(() {
        _message = const _FormMessage(
          ok: true,
          text: 'Reset link sent! Check your email inbox.',
        );
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = _FormMessage(
          ok: false,
          text: error.toString().isEmpty
              ? 'Could not send reset email.'
              : error.toString(),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const _IconCircle(),
                    const SizedBox(height: 16),
                    const Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Enter your email below and we'll send you a link to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textTertiaryColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ResetCard(
                      emailController: _emailController,
                      loading: _loading,
                      message: _message,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 20),
                    _BackButton(onPressed: _goBack),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _textPrimaryColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.key_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _ResetCard extends StatelessWidget {
  const _ResetCard({
    required this.emailController,
    required this.loading,
    required this.message,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final bool loading;
  final _FormMessage? message;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _textPrimaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Email',
            style: TextStyle(
              color: _textSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) {
              if (!loading) onSubmit();
            },
            style: const TextStyle(
              color: _textPrimaryColor,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'your.email@example.com',
              hintStyle: const TextStyle(color: _textTertiaryColor),
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: _textTertiaryColor,
                size: 18,
              ),
              filled: true,
              fillColor: _inputColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primaryColor, width: 1.4),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: message!.ok
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                disabledBackgroundColor: _primaryColor.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.arrow_back_rounded,
        color: _primaryColor,
        size: 16,
      ),
      label: const Text(
        'Back to Login',
        style: TextStyle(
          color: _primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FormMessage {
  const _FormMessage({
    required this.ok,
    required this.text,
  });

  final bool ok;
  final String text;
}
