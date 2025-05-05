import 'package:ecinema_mobile/models/concession.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class ConcessionProvider extends BaseProvider<Concession> {
  ConcessionProvider() : super("Concession");

  @override
  Concession fromJson(data) => Concession.fromJson(data);
}
