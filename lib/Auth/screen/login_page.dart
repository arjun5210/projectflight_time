import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectconvert/Auth/bloc/auth_bloc.dart';
import 'package:projectconvert/Auth/screen/check_page.dart';
import 'package:projectconvert/Auth/screen/reg_page.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // 🔑 For validation

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AuthWrapper()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${state.error}")),
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: w,

                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SlideInUp(
                      duration: Duration(milliseconds: 800),
                      child: Bounce(
                        infinite: false,
                        delay: Duration(milliseconds: 300),
                        child: Card(
                          color: Color.fromARGB(255, 60, 59, 59),
                          child: Column(
                            children: [
                              SizedBox(height: h * 0.07),
                              Text(
                                "Welcome Back",
                                style: GoogleFonts.manrope(
                                  fontSize: w * 0.11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: h * 0.01),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Registration(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Don't have an account? Signup",
                                  style: GoogleFonts.aBeeZee(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 40,
                                  bottom: 40,
                                ),
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: emailcontroller,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                      255,
                                      37,
                                      36,
                                      36,
                                    ),
                                    hintText: "Email",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email cannot be empty';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 10,
                                  bottom: 30,
                                ),
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: passwordcontroller,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                      255,
                                      37,
                                      36,
                                      36,
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                  width: w,
                                  height: 50,

                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        BlocProvider.of<AuthBloc>(context).add(
                                          loginevent(
                                            emailcontroller.text.trim(),
                                            passwordcontroller.text.trim(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: h * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
