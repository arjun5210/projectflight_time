import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:projectconvert/keys/key.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Map<String, Map<String, dynamic>> cachedata = {}; // cache data......
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<getevent>((event, emit) async {
      try {
        final String cacheKey =
            '${event.fromcurrency}-${event.tocurrency}-${event.amount}';

        if (cachedata.containsKey(cacheKey)) {
          final DateTime cachedTime = cachedata[cacheKey]!['timestamp'];

          if (DateTime.now().difference(cachedTime).inMinutes < 5) {
            final cachedResult = cachedata[cacheKey]!['result'];
            final cachedTimestamp = cachedata[cacheKey]!['apiTimestamp'];
            emit(
              dataloaded(
                convertedresult: cachedResult,
                timestamp: cachedTimestamp.toString(),
                isCached: true,
              ),
            );

            return;

            // here the value is fetch from cachedata (map)
          }
        }

        // if the cache data expired then here we use normal api calling method

        datavalues value = datavalues();

        final url =
            'https://api.currencylayer.com/convert?access_key=${value.acesskeyvalue}&from=${event.fromcurrency}&to=${event.tocurrency}&amount=${event.amount}';
        final response = await http.get(Uri.parse(url));
        print('RESPONSE STATUS: ${response.statusCode}');
        final data = json.decode(response.body);
        if (data['success'] == true) {
          var convertedresult = data['result'].toString();
          print("the converted price $convertedresult");

          var time = data['info']['timestamp'];
          var timestamp = DateTime.fromMillisecondsSinceEpoch(
            time * 1000,
          ).toString();
          print("timestamp $timestamp");

          // here we saved to the cache

          cachedata[cacheKey] = {
            'result': convertedresult,
            'timestamp': DateTime.now(),
            'apiTimestamp': timestamp,
          };
          emit(
            dataloaded(
              convertedresult: convertedresult,
              timestamp: timestamp,
              isCached: false,
            ),
          );
        }
      } catch (e) {
        emit(dataerror(error: e.toString()));
      }
    });
  }
}
