import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_mate/core/usecase/usecase.dart';
import 'package:health_mate/features/authentication/domain/usecases/create_user.dart';
import 'package:health_mate/features/authentication/domain/usecases/get_user.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_event.dart';
import 'package:health_mate/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetUser getUser;
  final CreateUser createUser;

  AuthBloc({required this.getUser, required this.createUser}) : super(AuthInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<CreateUserEvent>(_onCreateUser);
  }

  Future<void> _onLoadUser(LoadUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getUser(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthLoaded(user)),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await createUser( CreateUserParams
    (name: event.name,age: event.age,height: event.height,weight: event.weight,activityGoal: event.activityGoal));
    result.fold((failure)=> emit(AuthError(failure.message)),
    (_)=> emit(UserCreated()),
    
    );
  }
}
