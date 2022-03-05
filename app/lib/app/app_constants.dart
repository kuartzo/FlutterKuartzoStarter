class AppConstants {
  final String apiServerBaseUrl;

  const AppConstants._({
    this.apiServerBaseUrl = '',
  });

  static const AppConstants kuartzo = AppConstants._(
    apiServerBaseUrl: 'http://192.168.1.111:8080',
  );
}
