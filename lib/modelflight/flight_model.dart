// class FlightResponse {
//   final List<Flight> flights;

//   FlightResponse({required this.flights});

//   factory FlightResponse.fromJson(Map<String, dynamic> json) {
//     List<Flight> flightList = [];

//     final trips = json["Data"]["FlightTrips"] as List;
//     for (var trip in trips) {
//       final journeys = trip["FlightJourneys"] as List;
//       for (var journey in journeys) {
//         final items = journey["FlightItems"] as List;
//         for (var item in items) {
//           final info = item["FlightInfo"];
//           flightList.add(
//             Flight(
//               airlineName: info["Name"]["en"],
//               airlineCode: info["Code"],
//               departureTime: item["DepartureDateTime"] ?? "",
//               arrivalTime: item["ArrivalDateTime"] ?? "",
//               departureAirport: item["DepartureAirport"] ?? "",
//               arrivalAirport: item["ArrivalAirport"] ?? "",
//               price: item["Price"] ?? "0",
//             ),
//           );
//         }
//       }
//     }
//     return FlightResponse(flights: flightList);
//   }
// }
class FlightResponse {
  final List<Flight> flights;

  FlightResponse({required this.flights});

  factory FlightResponse.fromJson(Map<String, dynamic> json) {
    List<Flight> flightList = [];

    final trips = json["Data"]["FlightTrips"] as List;
    for (var trip in trips) {
      final totalPrice = trip["FareDetails"]?["Total"]?.toString() ?? "0";

      final journeys = trip["FlightJourneys"] as List? ?? [];
      for (var journey in journeys) {
        final items = journey["FlightItems"] as List? ?? [];
        for (var item in items) {
          final info = item["FlightInfo"] ?? {};

          flightList.add(
            Flight(
              airlineName: info["Name"]?["en"] ?? "",
              airlineCode: info["Code"] ?? "",
              departureTime: item["DepartureDateTime"] ?? "",
              arrivalTime: item["ArrivalDateTime"] ?? "",
              departureAirport: item["DepartureAirport"]?["Code"] ?? "",
              arrivalAirport: item["ArrivalAirport"]?["Code"] ?? "",
              price: totalPrice,
            ),
          );
        }
      }
    }
    return FlightResponse(flights: flightList);
  }
}

class Flight {
  final String airlineName;
  final String airlineCode;
  final String departureTime;
  final String arrivalTime;
  final String departureAirport;
  final String arrivalAirport;
  final String price;

  Flight({
    required this.airlineName,
    required this.airlineCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'airlineName': airlineName,
      'airlineCode': airlineCode,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'price': price,
    };
  }

  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      airlineName: map['airlineName'],
      airlineCode: map['airlineCode'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      departureAirport: map['departureAirport'],
      arrivalAirport: map['arrivalAirport'],
      price: map['price'],
    );
  }
}
