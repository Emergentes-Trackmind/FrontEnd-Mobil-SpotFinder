import '../../shared/services/http-common.dart';

class PaymentService extends ApiClient {
  PaymentService() {
    resourceEndPoint = '/payments';
  }
}
