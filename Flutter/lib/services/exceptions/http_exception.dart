class HttpServiceException implements Exception {
  String cause;
  HttpServiceException(this.cause);
}