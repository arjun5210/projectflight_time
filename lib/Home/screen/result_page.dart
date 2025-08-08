import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectconvert/Home/bloc/home_bloc.dart';

class Resultpage extends StatelessWidget {
  Resultpage({
    required this.amount,
    required this.fromcurrency,
    required this.tocurrency,
  });

  String fromcurrency;
  String tocurrency;
  String amount;

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,

        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is dataloaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SlideInUp(
                      duration: Duration(milliseconds: 800),
                      child: Bounce(
                        infinite: false,
                        delay: Duration(milliseconds: 300),
                        child: Container(
                          width: w * 0.7,

                          child: Card(
                            color: Color.fromARGB(255, 37, 36, 36),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 18,
                                    top: 30,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        fromcurrency,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: Image.network(
                                          'https://img.icons8.com/?size=100&id=81119&format=png&color=000000',
                                          width: 30,
                                        ),
                                      ),

                                      Text(
                                        tocurrency,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 50),

                                ListTile(
                                  title: Text(
                                    "AMOUNT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    amount,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    "CONVERTED RATE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    state.convertedresult,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),

                                SizedBox(height: 20),
                                ListTile(
                                  title: Text(
                                    "TIME STAMP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    state.timestamp,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),

                                ListTile(
                                  title: Text(
                                    state.isCached ? "Cached data" : "",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is dataloading) {
              return CircularProgressIndicator();
            }

            if (state is dataerror) {
              return Text("the error is ${state.error}");
            }
            return Column(children: [
            
          ],
        );
          },
        ),
      ),
    );
  }
}
