import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<RegisterUserEvent>((event, emit) async {
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        await auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        print(event.email);
        print(event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });
    on<loginevent>((event, emit) async {
      emit(AuthLoading());
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        await auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        print(event.email);
        print(event.password);
        emit(AuthSuccess());
      } catch (e) {
        print("error");
        emit(AuthFailure(error: e.toString()));
        print(e);
      }
    });

    on<logoutevent>((event, emit) async {
      await FirebaseAuth.instance.signOut();
      emit(AuthInitial());
    });

    on<checkstatus>((event, emit) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    });
  }
}
