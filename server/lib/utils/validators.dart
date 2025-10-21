/// Classe com validadores para dados de entrada da API
class Validators {
  static final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  /// Valida formato de email
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.error('Email é obrigatório');
    }
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Email inválido');
    }
    return ValidationResult.success();
  }
  
  /// Valida senha
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.error('Senha é obrigatória');
    }
    if (password.length < 6) {
      return ValidationResult.error('Senha deve ter no mínimo 6 caracteres');
    }
    return ValidationResult.success();
  }
  
  /// Valida nota (0-10)
  static ValidationResult validateNota(dynamic nota) {
    if (nota == null) {
      return ValidationResult.error('Nota é obrigatória');
    }
    
    final notaNum = nota is num ? nota : num.tryParse(nota.toString());
    
    if (notaNum == null) {
      return ValidationResult.error('Nota deve ser um número');
    }
    
    if (notaNum < 0 || notaNum > 10) {
      return ValidationResult.error('Nota deve estar entre 0 e 10');
    }
    
    return ValidationResult.success();
  }
  
  /// Valida se string não está vazia
  static ValidationResult validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('$fieldName é obrigatório');
    }
    return ValidationResult.success();
  }
  
  /// Valida peso de atividade
  static ValidationResult validatePeso(dynamic peso) {
    if (peso == null) {
      return ValidationResult.error('Peso é obrigatório');
    }
    
    final pesoNum = peso is num ? peso : num.tryParse(peso.toString());
    
    if (pesoNum == null) {
      return ValidationResult.error('Peso deve ser um número');
    }
    
    if (pesoNum <= 0) {
      return ValidationResult.error('Peso deve ser maior que zero');
    }
    
    return ValidationResult.success();
  }
  
  /// Valida código de cor hex
  static ValidationResult validateColor(String? cor) {
    if (cor == null || cor.isEmpty) {
      return ValidationResult.success(); // Cor é opcional, tem default
    }
    
    final hexRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');
    if (!hexRegex.hasMatch(cor)) {
      return ValidationResult.error('Cor deve estar no formato #RRGGBB');
    }
    
    return ValidationResult.success();
  }
  
  /// Valida ID
  static ValidationResult validateId(dynamic id) {
    if (id == null) {
      return ValidationResult.error('ID é obrigatório');
    }
    
    final idInt = id is int ? id : int.tryParse(id.toString());
    
    if (idInt == null || idInt <= 0) {
      return ValidationResult.error('ID inválido');
    }
    
    return ValidationResult.success();
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String? error;
  
  ValidationResult.success() : isValid = true, error = null;
  ValidationResult.error(this.error) : isValid = false;
  
  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}
