part of 'login_page.dart';

extension _LoginPageValidators on _LoginPageState {
  String? _validateFirstName(String? value) {
    final t = context.l10n;
    if (_mode != _AuthMode.register) {
      return null;
    }
    final name = (value ?? '').trim();
    if (name.length < 2 || name.length > 64) {
      return t.firstNameLengthValidation;
    }
    return null;
  }

  String? _validateLastName(String? value) {
    final t = context.l10n;
    if (_mode != _AuthMode.register) {
      return null;
    }
    final name = (value ?? '').trim();
    if (name.length < 2 || name.length > 64) {
      return t.lastNameLengthValidation;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final t = context.l10n;
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return t.emailRequired;
    }
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (!ok) {
      return t.invalidEmailFormat;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final t = context.l10n;
    final text = value ?? '';
    if (text.length < 8) {
      return t.passwordMinLength;
    }
    if (_mode == _AuthMode.register) {
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      final hasNumber = RegExp(r'[0-9]').hasMatch(text);
      final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(text);
      if (!hasUppercase || !hasNumber || !hasSymbol) {
        return t.passwordComplexityValidation;
      }
    }
    return null;
  }

  String? _validateRepeat(String? value) {
    final t = context.l10n;
    if (_mode != _AuthMode.register) {
      return null;
    }
    if ((value ?? '') != _passwordController.text) {
      return t.passwordsDoNotMatch;
    }
    return null;
  }
}
