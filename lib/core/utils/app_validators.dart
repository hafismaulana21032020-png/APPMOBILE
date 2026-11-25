enum PasswordSimilarity {
  distinct,
  similar,
  identical,
}

class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns `true` when [email] has a valid basic email format.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Returns `true` when [password] is at least 8 characters and includes both letters and digits.
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  /// Evaluates whether [newPassword] is identical or nearly identical to [oldPassword].
  static PasswordSimilarity evaluatePasswordSimilarity(
    String oldPassword,
    String newPassword,
  ) {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return PasswordSimilarity.distinct;
    }
    if (oldPassword == newPassword) {
      return PasswordSimilarity.identical;
    }

    final oldLower = oldPassword.toLowerCase();
    final newLower = newPassword.toLowerCase();
    if (oldLower == newLower) {
      return PasswordSimilarity.similar;
    }

    final oldCore = _normalizeLettersAndDigits(
      oldPassword.replaceAll(RegExp(r'[\d\W_]+$'), ''),
    );
    final newCore = _normalizeLettersAndDigits(
      newPassword.replaceAll(RegExp(r'[\d\W_]+$'), ''),
    );
    if (oldCore.length >= 4 && oldCore == newCore) {
      return PasswordSimilarity.similar;
    }

    final maxLen =
        oldLower.length > newLower.length ? oldLower.length : newLower.length;
    final dist = _levenshteinDistance(oldLower, newLower);
    final ratio = 1.0 - (dist / maxLen);
    if (ratio >= 0.70 || dist <= 2) {
      return PasswordSimilarity.similar;
    }

    if (oldLower.length >= 5 &&
        newLower.length >= 5 &&
        (oldLower.contains(newLower) || newLower.contains(oldLower))) {
      final minLen =
          oldLower.length < newLower.length ? oldLower.length : newLower.length;
      if ((minLen / maxLen) >= 0.65) {
        return PasswordSimilarity.similar;
      }
    }

    return PasswordSimilarity.distinct;
  }

  static String _normalizeLettersAndDigits(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;

    var prev = List<int>.generate(n + 1, (j) => j);
    for (var i = 1; i <= m; i++) {
      final curr = List<int>.filled(n + 1, 0);
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final deletion = prev[j] + 1;
        final insertion = curr[j - 1] + 1;
        final substitution = prev[j - 1] + cost;
        curr[j] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
      prev = curr;
    }
    return prev[n];
  }
}
