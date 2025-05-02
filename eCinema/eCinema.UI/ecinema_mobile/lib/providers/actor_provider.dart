import 'package:ecinema_mobile/models/actor.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super("Actor");

  @override
  Actor fromJson(data) => Actor.fromJson(data);
}
