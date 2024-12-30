class AuthException implements Exception {}

class UserNotFoundException extends AuthException {}

class WrongPasswordException extends AuthException {}

class WeakPasswordException extends AuthException {}

class EmailAlreadyInUseException extends AuthException {}

class InvalidEmailException extends AuthException {}

class GenericException extends AuthException {}

class UserNotLoggedInException extends AuthException {}
