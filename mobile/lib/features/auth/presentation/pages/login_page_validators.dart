part of 'login_page.dart';

extension _LoginPageValidators on _LoginPageState {
  String? _validateFullName(String? value) {
    final t = context.l10n;
    if (_mode != _AuthMode.register) {
      return null;
    }
    final nameParts = _parseFullName(value ?? '');
    if (nameParts == null) {
      return t.fullNameValidation;
    }
    return null;
  }

  MapEntry<String, String>? _parseFullName(String rawValue) {
    final normalized = rawValue.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return null;
    }

    final segments = normalized.split(' ');
    if (segments.length < 2) {
      return null;
    }

    final firstName = segments.first.trim();
    final lastName = segments.sublist(1).join(' ').trim();
    if (firstName.length < 2 ||
        firstName.length > 64 ||
        lastName.length < 2 ||
        lastName.length > 64) {
      return null;
    }

    return MapEntry<String, String>(firstName, lastName);
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
