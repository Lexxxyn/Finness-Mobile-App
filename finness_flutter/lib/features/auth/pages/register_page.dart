import 'package:flutter/material.dart';

const _accentColor = Color(0xFF2BBFA4);
const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _textPrimaryColor = Color(0xFF1F2937);
const _textSecondaryColor = Color(0xFF4B5563);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _inputColor = Color(0xFFF3F6FA);

enum _RegisterStep { account, about, goal, equipment }

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.onRegister,
    this.onLoginPressed,
    this.onRegistered,
  });

  final Future<void> Function(RegisterFormData data)? onRegister;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _heightController = TextEditingController(text: '165');
  final _weightController = TextEditingController(text: '58');

  _RegisterStep _step = _RegisterStep.account;
  String _gender = 'Female';
  String _goal = 'maintain';
  DateTime? _dob;
  final Set<String> _equipment = {'bodyweight'};
  bool _showPassword = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int get _stepIndex => _step.index;

  String? _validateAccount() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_passwordController.text != _confirmController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String? _validateAbout() {
    final height = num.tryParse(_heightController.text);
    final weight = num.tryParse(_weightController.text);

    if (_gender.isEmpty) return 'Please select your gender.';
    if (height == null || height < 80 || height > 250) {
      return 'Please enter a valid height in cm.';
    }
    if (weight == null || weight < 25 || weight > 250) {
      return 'Please enter a valid weight in kg.';
    }
    return null;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (_step == _RegisterStep.account) {
      final error = _validateAccount();
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
      setState(() => _step = _RegisterStep.about);
      return;
    }

    if (_step == _RegisterStep.about) {
      final error = _validateAbout();
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
      setState(() => _step = _RegisterStep.goal);
      return;
    }

    if (_step == _RegisterStep.goal) {
      setState(() => _step = _RegisterStep.equipment);
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      if (_step == _RegisterStep.about) {
        _step = _RegisterStep.account;
      } else if (_step == _RegisterStep.goal) {
        _step = _RegisterStep.about;
      } else if (_step == _RegisterStep.equipment) {
        _step = _RegisterStep.goal;
      }
    });
  }

  void _toggleEquipment(String id) {
    setState(() {
      if (_equipment.contains(id)) {
        _equipment.remove(id);
      } else {
        _equipment.add(id);
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (_equipment.isEmpty) {
      setState(() {
        _errorMessage =
            'Pick at least one equipment option (Bodyweight is fine).';
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final data = RegisterFormData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _gender,
        dob: _dob,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        equipment: _equipment.toList(growable: false),
        goal: _goal,
      );

      await widget.onRegister?.call(data);
      if (!mounted) return;

      widget.onRegistered?.call();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().isEmpty
            ? 'Registration failed. Please try again.'
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _accentColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() => _dob = selected);
    }
  }

  void _goToLogin() {
    if (widget.onLoginPressed != null) {
      widget.onLoginPressed!();
      return;
    }

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
                    const SizedBox(height: 4),
                    const _Header(),
                    const SizedBox(height: 16),
                    _StepperDots(index: _stepIndex),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_step == _RegisterStep.account)
                            _AccountStep(
                              nameController: _nameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmController: _confirmController,
                              showPassword: _showPassword,
                              onTogglePassword: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
                          if (_step == _RegisterStep.about)
                            _AboutStep(
                              gender: _gender,
                              dob: _dob,
                              heightController: _heightController,
                              weightController: _weightController,
                              onGenderChanged: (value) {
                                setState(() => _gender = value);
                              },
                              onPickDate: _pickDate,
                            ),
                          if (_step == _RegisterStep.goal)
                            _GoalStep(
                              selected: _goal,
                              onChanged: (value) {
                                setState(() => _goal = value);
                              },
                            ),
                          if (_step == _RegisterStep.equipment)
                            _EquipmentStep(
                              selected: _equipment,
                              onToggle: _toggleEquipment,
                            ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _ActionRow(
                            stepIndex: _stepIndex,
                            loading: _loading,
                            onBack: _back,
                            onNext: _next,
                            onSubmit: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _Footer(onLoginPressed: _goToLogin),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _accentColor,
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
            Icons.favorite_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimaryColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Start your wellness journey today',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textTertiaryColor, fontSize: 13),
        ),
      ],
    );
  }
}

class _StepperDots extends StatelessWidget {
  const _StepperDots({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (dotIndex) {
        final active = dotIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _accentColor : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.showPassword,
    required this.onTogglePassword,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool showPassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('Account details'),
        _InputField(
          controller: nameController,
          label: 'Full Name',
          hintText: 'Jane Doe',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        _InputField(
          controller: emailController,
          label: 'Email',
          hintText: 'your.email@example.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        _InputField(
          controller: passwordController,
          label: 'Password',
          hintText: 'Create a password',
          icon: Icons.lock_outline_rounded,
          obscureText: !showPassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _textTertiaryColor,
              size: 20,
            ),
          ),
        ),
        _InputField(
          controller: confirmController,
          label: 'Confirm Password',
          hintText: 'Re-enter password',
          icon: Icons.lock_outline_rounded,
          obscureText: !showPassword,
        ),
      ],
    );
  }
}

class _AboutStep extends StatelessWidget {
  const _AboutStep({
    required this.gender,
    required this.dob,
    required this.heightController,
    required this.weightController,
    required this.onGenderChanged,
    required this.onPickDate,
  });

  final String gender;
  final DateTime? dob;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('About you'),
        const _FieldLabel('Gender'),
        Row(
          children: _genderOptions.map((option) {
            final active = gender == option;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option == _genderOptions.last ? 0 : 8,
                ),
                child: _ChoiceChipButton(
                  label: option,
                  active: active,
                  onPressed: () => onGenderChanged(option),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _DateField(value: dob, onPressed: onPickDate),
        Row(
          children: [
            Expanded(
              child: _InputField(
                controller: heightController,
                label: 'Height (cm)',
                icon: Icons.straighten_rounded,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InputField(
                controller: weightController,
                label: 'Weight (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('What is your main goal?'),
        const Text(
          'We will tune meal targets and workout recommendations around this.',
          style: TextStyle(
            color: _textTertiaryColor,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        for (final option in _goalOptions) ...[
          _GoalTile(
            option: option,
            active: selected == option.id,
            onPressed: () => onChanged(option.id),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.option,
    required this.active,
    required this.onPressed,
  });

  final _GoalOption option;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE4F7F2) : _inputColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? _accentColor : _borderColor),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: active ? _accentColor : _textSecondaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: active ? _accentColor : _textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: _textTertiaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              const Icon(Icons.check_circle_rounded, color: _accentColor),
          ],
        ),
      ),
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('What equipment do you have?'),
        const Text(
          "We'll recommend workouts that fit your gear. Pick all that apply.",
          style: TextStyle(
            color: _textTertiaryColor,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: _equipmentOptions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final option = _equipmentOptions[index];
            final active = selected.contains(option.id);
            return _EquipmentTile(
              option: option,
              active: active,
              onPressed: () => onToggle(option.id),
            );
          },
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            autocorrect: false,
            enableSuggestions: !obscureText,
            style: const TextStyle(color: _textPrimaryColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: _textTertiaryColor),
              prefixIcon: Icon(icon, color: _textTertiaryColor, size: 18),
              suffixIcon: suffixIcon,
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
                borderSide: const BorderSide(color: _accentColor, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onPressed});

  final DateTime? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldLabel('Date of Birth'),
          const SizedBox(height: 6),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _inputColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: _textTertiaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value == null
                          ? 'Tap to pick your birthday'
                          : _formatDate(value!),
                      style: TextStyle(
                        color: value == null
                            ? _textTertiaryColor
                            : _textPrimaryColor,
                        fontSize: 15,
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
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: active ? _accentColor : _inputColor,
        foregroundColor: active ? Colors.white : _textSecondaryColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? _accentColor : _borderColor),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.option,
    required this.active,
    required this.onPressed,
  });

  final _EquipmentOption option;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE4F7F2) : _inputColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? _accentColor : _borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option.icon,
                    color: active ? _accentColor : _textSecondaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? _accentColor : _textSecondaryColor,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.stepIndex,
    required this.loading,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final int stepIndex;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (stepIndex > 0)
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: loading ? null : onBack,
                style: TextButton.styleFrom(
                  backgroundColor: _inputColor,
                  foregroundColor: _textSecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.chevron_left_rounded, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),
        const SizedBox(width: 10),
        Expanded(
          child: _PrimaryButton(
            label: stepIndex < 3 ? 'Continue' : 'Create Account',
            loading: loading && stepIndex == 3,
            icon: stepIndex < 3 ? Icons.chevron_right_rounded : null,
            onPressed: loading ? null : (stepIndex < 3 ? onNext : onSubmit),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          disabledBackgroundColor: _accentColor.withValues(alpha: 0.55),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: _textSecondaryColor, fontSize: 14),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: onLoginPressed,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: _accentColor,
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: _textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _textSecondaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class RegisterFormData {
  const RegisterFormData({
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.dob,
    required this.height,
    required this.weight,
    required this.equipment,
    required this.goal,
  });

  final String name;
  final String email;
  final String password;
  final String gender;
  final DateTime? dob;
  final double height;
  final double weight;
  final List<String> equipment;
  final String goal;
}

class _EquipmentOption {
  const _EquipmentOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class _GoalOption {
  const _GoalOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

const _genderOptions = ['Female', 'Male', 'Other'];

const _goalOptions = [
  _GoalOption(
    id: 'lose_weight',
    label: 'Lose weight',
    description: 'Lower-calorie meals and cardio-focused workouts.',
    icon: Icons.local_fire_department_rounded,
  ),
  _GoalOption(
    id: 'build_muscle',
    label: 'Build muscle',
    description: 'High-protein meals and strength-focused workouts.',
    icon: Icons.fitness_center_rounded,
  ),
  _GoalOption(
    id: 'increase_weight',
    label: 'Increase weight',
    description: 'Higher-calorie Indonesian meals and hypertrophy workouts.',
    icon: Icons.add_circle_rounded,
  ),
  _GoalOption(
    id: 'maintain_muscle',
    label: 'Maintain muscle',
    description: 'Protein-forward meals and strength maintenance workouts.',
    icon: Icons.self_improvement_rounded,
  ),
  _GoalOption(
    id: 'maintain',
    label: 'Maintain health',
    description: 'Balanced meals and steady weekly movement.',
    icon: Icons.favorite_rounded,
  ),
  _GoalOption(
    id: 'improve_fitness',
    label: 'Improve fitness',
    description: 'Conditioning, endurance, and all-round training.',
    icon: Icons.trending_up_rounded,
  ),
];

const _equipmentOptions = [
  _EquipmentOption(
    id: 'bodyweight',
    label: 'Bodyweight',
    icon: Icons.accessibility_new_rounded,
  ),
  _EquipmentOption(
    id: 'dumbbells',
    label: 'Dumbbells',
    icon: Icons.fitness_center_rounded,
  ),
  _EquipmentOption(
    id: 'barbell',
    label: 'Barbell',
    icon: Icons.fitness_center_outlined,
  ),
  _EquipmentOption(
    id: 'kettlebell',
    label: 'Kettlebell',
    icon: Icons.sports_gymnastics_rounded,
  ),
  _EquipmentOption(
    id: 'resistance_bands',
    label: 'Resistance Bands',
    icon: Icons.linear_scale_rounded,
  ),
  _EquipmentOption(
    id: 'yoga_mat',
    label: 'Yoga Mat',
    icon: Icons.self_improvement_rounded,
  ),
  _EquipmentOption(
    id: 'pull_up_bar',
    label: 'Pull-up Bar',
    icon: Icons.horizontal_rule_rounded,
  ),
  _EquipmentOption(
    id: 'treadmill',
    label: 'Treadmill',
    icon: Icons.directions_run_rounded,
  ),
  _EquipmentOption(
    id: 'stationary_bike',
    label: 'Stationary Bike',
    icon: Icons.directions_bike_rounded,
  ),
  _EquipmentOption(
    id: 'jump_rope',
    label: 'Jump Rope',
    icon: Icons.timeline_rounded,
  ),
];
