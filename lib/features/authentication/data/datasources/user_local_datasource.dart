import 'package:health_mate/core/error/exceptions.dart';
import 'package:health_mate/features/authentication/data/models/user_model.dart';
import 'package:hive/hive.dart';

abstract class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> updateUser(UserModel user);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  Box<UserModel> userBox;
  UserLocalDataSourceImpl(this.userBox);

  @override
  Future<UserModel> getUser() async {
    final user = userBox.get('current_user');
    if (user == null) {
      throw DatabaseExceptions('No user found');
    }
    return user;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user',user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await userBox.put('current_user',user );
  }
}
