import 'package:flutter/material.dart';
import 'package:projectconvert/modelflight/flight_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/db_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Flight> flights = [];
  List<Flight> filteredFlights = [];
  bool isLoading = true;

  List<String> selectedAirlines = [];

  @override
  void initState() {
    super.initState();
    loadFlights();
  }

  Future<void> loadFlights() async {
    final prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('first_launch') ?? true;

    if (firstLaunch) {
      final response = await ApiService.fetchFlights();
      if (response != null) {
        for (var flight in response.flights) {
          await DBService.insertFlight(flight);
        }
        prefs.setBool('first_launch', false);
      }
    }
    flights = await DBService.getFlights();
    filteredFlights = List.from(flights);
    setState(() => isLoading = false);
  }

  void openFilterPopup() {
    final airlineNames = flights.map((f) => f.airlineName).toSet().toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Airlines",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setStatePopup(() {
                            selectedAirlines.clear();
                          });
                        },
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 300, // Limit height for bottom sheet
                    child: ListView.builder(
                      itemCount: airlineNames.length,
                      itemBuilder: (context, index) {
                        final airline = airlineNames[index];
                        final isSelected = selectedAirlines.contains(airline);
                        return CheckboxListTile(
                          title: Text(airline),
                          value: isSelected,
                          onChanged: (val) {
                            setStatePopup(() {
                              if (val == true) {
                                selectedAirlines.add(airline);
                              } else {
                                selectedAirlines.remove(airline);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  openSortPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                "Sort Flight By",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Airline Row
              _buildSortRow("Airline"),
              const Divider(),

              // Duration Row
              _buildSortRow("Duration"),
              const Divider(),

              // Price Row
              _buildSortRow("Price"),

              const SizedBox(height: 20),

              // Reset & Done Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Future.microtask(() => Navigator.pop(context));
                        // Put reset logic here if needed
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Future.microtask(() => Navigator.pop(context));
                        // If you want to navigate after closing:
                        Future.delayed(const Duration(milliseconds: 300), () {
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen()));
                        });
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortRow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Row(
          children: const [
            Icon(Icons.arrow_upward, color: Colors.grey),
            SizedBox(width: 8),
            Icon(Icons.arrow_downward, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  void applyFilter() {
    setState(() {
      if (selectedAirlines.isEmpty) {
        filteredFlights = List.from(flights);
      } else {
        filteredFlights = flights
            .where((f) => selectedAirlines.contains(f.airlineName))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0560A6),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {},
                      ),
                      const Text(
                        "NYZ  →  CAI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "17 October   |   2 Travellers   |   25 Flights",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredFlights.isEmpty
          ? const Center(child: Text("No flights found"))
          : ListView.builder(
              itemCount: filteredFlights.length,
              itemBuilder: (context, index) {
                final f = filteredFlights[index];
                return Card(
                  margin: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.network(
                              "https://booksultanuat.caxita.ca/images/AirlineIcons/${f.airlineCode}.png",
                              height: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.flight, size: 40),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              f.airlineName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "Departure",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  f.departureTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  f.departureAirport,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.flight_takeoff,
                              color: Colors.orange,
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Arrival",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  f.arrivalTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  f.arrivalAirport,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Non Refundable",
                              style: TextStyle(color: Colors.red),
                            ),
                            Text(
                              "EGP ${f.price}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 15,
          bottom: 15,
        ),
        child: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  openSortPopup(context);
                },
                child: const Text(
                  "Sort",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(width: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: openFilterPopup,
                child: const Text(
                  "Filter",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
