/// Base exception for AURA app errors.
sealed class AppException implements Exception {
  const AppException(this.message, this.code);
  final String message;
  final String code;

  @override
  String toString() => '$code: $message';
}

class AuthRequiredException extends AppException {
  const AuthRequiredException()
      : super('인증이 필요합니다.', 'AUTH_REQUIRED');
}

class WardrobeLimitReachedException extends AppException {
  const WardrobeLimitReachedException()
      : super('무료 옷장 등록 한도에 도달했습니다.', 'WARDROBE_LIMIT_REACHED');
}

class RecreationLimitReachedException extends AppException {
  const RecreationLimitReachedException()
      : super('이번 달 룩 재현 한도에 도달했습니다.', 'RECREATION_LIMIT_REACHED');
}

class InvalidImageException extends AppException {
  const InvalidImageException()
      : super('이미지를 처리할 수 없습니다.', 'INVALID_IMAGE');
}

class NoFashionItemsException extends AppException {
  const NoFashionItemsException()
      : super('패션 아이템을 찾을 수 없습니다.', 'NO_FASHION_ITEMS');
}

class AiTimeoutException extends AppException {
  const AiTimeoutException()
      : super('AI 분석 시간이 초과되었습니다.', 'AI_TIMEOUT');
}

class AiErrorException extends AppException {
  const AiErrorException()
      : super('AI 분석 중 오류가 발생했습니다.', 'AI_ERROR');
}

class RateLimitedException extends AppException {
  const RateLimitedException()
      : super('요청이 너무 많습니다. 잠시 후 재시도해주세요.', 'RATE_LIMITED');
}

class NetworkException extends AppException {
  const NetworkException([String message = '네트워크 연결을 확인해주세요.'])
      : super(message, 'NETWORK_ERROR');
}
