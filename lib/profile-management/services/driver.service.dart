import '../../shared/services/http-common.dart';

class DriverService extends ApiClient {
  DriverService() {
    resourceEndPoint = '/profiles/driver';
  }
}