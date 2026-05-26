import '../../core/constants/api_constants.dart';
import 'local_storage_service.dart';

class RequestLimiter {
  RequestLimiter(this._storage);

  final LocalStorageService _storage;

  Future<bool> canRequest() async {
    final cleanLog = _recentLog();
    await _storage.saveRequestLog(cleanLog);
    return cleanLog.length < ApiConstants.safeHourlyLimit;
  }

  Future<void> registerRequest() async {
    final cleanLog = _recentLog()..add(DateTime.now());
    await _storage.saveRequestLog(cleanLog);
  }

  List<DateTime> _recentLog() {
    final threshold = DateTime.now().subtract(const Duration(hours: 1));
    return _storage
        .getRequestLog()
        .where((date) => date.isAfter(threshold))
        .toList();
  }
}
