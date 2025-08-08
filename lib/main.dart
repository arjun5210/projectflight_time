import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectconvert/Auth/bloc/auth_bloc.dart';
import 'package:projectconvert/Auth/screen/check_page.dart';
import 'package:projectconvert/Auth/screen/reg_page.dart';

import 'package:projectconvert/Home/bloc/home_bloc.dart';
import 'package:projectconvert/Home/screen/currency_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthWrapper(),
      //Authwrapper
    );
  }
}
