class AppValidators {
  AppValidators._();

  static String? required(String? value, [String label = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$label est obligatoire';
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Veuillez entrer un nombre valide';
    }
    return null;
  }

  static String? intNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    if (int.tryParse(value) == null) {
      return 'Veuillez entrer un nombre entier valide';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[0-9+ ]{8,}$').hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }

  static String? positiveInteger(String? value, [String label = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$label est obligatoire';
    }
    final n = int.tryParse(value);
    if (n == null || n < 0) {
      return 'Entrez un nombre positif';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String label = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$label est obligatoire';
    }
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null || n < 0) {
      return 'Entrez un nombre positif';
    }
    return null;
  }

  static String? sku(String? value) {
    if (value == null || value.isEmpty) {
      return 'La référence est obligatoire';
    }
    if (value.length < 3) {
      return 'Référence trop courte';
    }
    return null;
  }
}
