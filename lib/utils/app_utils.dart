
class AppUtils {
  static bool isUserLoginAfterLogOut = false;

  static RegExp regexToRemoveTrailingZero = RegExp(r'([.]*0)(?!.*\d)');

  static RegExp regexToDenyComma = RegExp(r',');

  static RegExp regexToDenyNotADigit = RegExp(r'[^\d]');

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  static bool isValidEmail(String s) => hasMatch(s,
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  static bool isValidPasswordLength(String s) {
    return s.length >= 6;
  }

  /*
    Min 1 uppercase letter.
    Min 1 lowercase letter.
    Min 1 special character.
    Min 1 number.
    Min 8 characters.
    Max 30 characters
   */
  static bool isValidPasswordToRegister(String s) => hasMatch(s,
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%&*?])[A-Za-z\d#$@!%&*?]{6,10}$');
}
