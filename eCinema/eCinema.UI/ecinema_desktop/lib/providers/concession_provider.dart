import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class ConcessionProvider extends BaseProvider<Concession> {
  ConcessionProvider() : super("Concession");

  @override
  Concession fromJson(data) => Concession.fromJson(data);
}
