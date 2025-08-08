import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:projectconvert/Auth/bloc/auth_bloc.dart';
import 'package:projectconvert/Auth/screen/check_page.dart';
import 'dart:convert';

import 'package:projectconvert/Home/bloc/home_bloc.dart';
import 'package:projectconvert/Home/screen/result_page.dart';

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();

  String _fromCurrency = 'USD';
  String _toCurrency = 'GBP';
  String _convertedResult = '';
  bool _isLoading = false;
  FocusNode _fromFocusNode = FocusNode();
  FocusNode _toFocusNode = FocusNode();

  List<String> _currencyList = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'INR',
  ];
  String timeStamp = '';

  @override
  void initState() {
    _fromFocusNode.addListener(() {
      setState(() {});
    });

    _toFocusNode.addListener(() {
      setState(() {});
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 37, 36, 36),
        title: Row(
          children: [
            Image.network(
              'https://img.icons8.com/?size=100&id=11937&format=png&color=000000',
              width: w * 0.1,
            ),
            SizedBox(width: 20),
            Text(
              'Currency Converter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Color.fromARGB(255, 60, 59, 59),
                      title: Text(
                        'Alert',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Are You Want to Exit.',
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            BlocProvider.of<AuthBloc>(
                              context,
                            ).add(logoutevent());
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => AuthWrapper(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text('YES'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('NO'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.exit_to_app, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: h * 0.1),
              SizedBox(height: h * 0.05),
              Container(
                // container contains the textfield and drop down
                child: Column(
                  children: [
                    // from currency dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _fromFocusNode.hasFocus
                            ? Colors.orange
                            : const Color.fromARGB(255, 37, 36, 36),
                      ),
                      width: w * 0.9,
                      height: h * 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color.fromARGB(255, 60, 59, 59),
                          decoration: InputDecoration(border: InputBorder.none),
                          value: _fromCurrency,
                          items: _currencyList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                'From: $value',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _fromCurrency = val!;
                            });
                          },
                        ),
                      ),
                    ).animate().slide(
                      duration: 800.ms,
                      begin: Offset(-1, 0),
                      end: Offset.zero,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(height: h * 0.1),

                    // to currency dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _toFocusNode.hasFocus
                            ? Colors.orange
                            : const Color.fromARGB(255, 37, 36, 36),
                      ),
                      width: w * 0.9,
                      height: h * 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color.fromARGB(255, 60, 59, 59),
                          decoration: InputDecoration(border: InputBorder.none),
                          value: _toCurrency,
                          items: _currencyList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                'To: $value',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _toCurrency = val!;
                            });
                          },
                        ),
                      ),
                    ).animate().slide(
                      duration: 800.ms,
                      begin: Offset(-1, 0),
                      end: Offset.zero,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(height: h * 0.1),

                    // amount input
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _amountController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 37, 36, 36),
                        labelText: 'Enter Amount',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ).animate().slide(
                      duration: 800.ms,
                      begin: Offset(-1, 0),
                      end: Offset.zero,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(height: h * 0.1),

                    SlideInUp(
                      duration: Duration(milliseconds: 800),

                      child: Bounce(
                        infinite: false,
                        delay: Duration(milliseconds: 300),
                        child: SizedBox(
                          width: w * 0.9,
                          height: h * 0.06,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                            ),
                            onPressed: () {
                              if (_amountController.text.trim().isEmpty ||
                                  double.tryParse(
                                        _amountController.text.trim(),
                                      ) ==
                                      null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please enter a valid amount',
                                    ),
                                  ),
                                );
                              } else {
                                BlocProvider.of<HomeBloc>(context).add(
                                  getevent(
                                    amount: _amountController.text,
                                    fromcurrency: _fromCurrency,
                                    tocurrency: _toCurrency,
                                  ),
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Resultpage(
                                      amount: _amountController.text,
                                      fromcurrency: _fromCurrency,
                                      tocurrency: _toCurrency,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _isLoading ? 'Converting...' : 'CONVERT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
