import 'package:ecinema_desktop/models/user.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) => User.fromJson(data);
}
