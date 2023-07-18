import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:monitor_umidade/edit_humidity.dart';
import 'package:monitor_umidade/services/messaging_service.dart';
import 'firebase_options.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'classes/sensor.dart';

Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingService().initNotifications();
  await intl.initializeDateFormatting('pt_BR', null);
}

void main() {
  initializeFirebase().then((_) {
    runApp(const App());
  });
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoramento de Umidade',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromRGBO(40, 162, 255, 1),
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _dataReference = FirebaseDatabase.instance.ref();
  final ValueNotifier<double> _humidity = ValueNotifier(0);
  List<Sensor> sensorList = [];
  double maxHumidity = 50;

  @override
  void initState() {
    super.initState();
    init();
  }

  double _calcAverageHumidity(List<Sensor> sensors) {
    if (sensors.isEmpty) {
      return 0.0;
    }
    final sum = sensors.fold(
        0, (previousValue, sensor) => previousValue + sensor.humidity);
    return (sum / sensors.length).toDouble();
  }

  void init() {
    //Atualiza o valor da humidade conforme o valor é alterado no BD
    _dataReference.child('sensors').onValue.listen((event) {
      sensorList.clear();
      final sensors = event.snapshot.value as Map<dynamic, dynamic>?;
      sensors?.forEach((key, value) {
        final sensor = Sensor(humidity: value['humidity'], date: value['time']);
        sensorList.add(sensor);
      });
      _humidity.value = _calcAverageHumidity(sensorList);
    });

    //Lê o valor da umidade máxima
    _dataReference.child('max_humidity').onValue.listen((event) {
      final snapshot = event.snapshot;
      dynamic doubleOrInteger = snapshot.value;
      maxHumidity = doubleOrInteger.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayFormat = DateFormat('d', 'pt_BR');
    final monthFormat = DateFormat('MMMM', 'pt_BR');
    final currentDay = dayFormat.format(now);
    final currentMonth = monthFormat.format(now);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.expand_more,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to another page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHumidity(
                    currentHumidity: maxHumidity,
                  ),
                ),
              );
            },
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
        ],
        shadowColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Text(
              'Monitoramento de Umidade',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '$currentDay de $currentMonth',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            ValueListenableBuilder<double>(
              valueListenable: _humidity,
              builder: (_, value, __) => Column(
                children: [
                  DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1.1,
                    progress: value,
                    startAngle: 225,
                    sweepAngle: 270,
                    foregroundColor: value >= maxHumidity
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    backgroundColor: const Color(0xffeeeeee),
                    foregroundStrokeWidth: 15,
                    backgroundStrokeWidth: 15,
                    animation: true,
                    seekSize: 6,
                    seekColor: const Color(0xffeeeeee),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$value%',
                            style: const TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Umidade',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: sensorList.length,
                    itemBuilder: (context, index) {
                      final sensor = sensorList[index];
                      final sensorIndex = index + 1;
                      return ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(40, 162, 255, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sensors,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Sensor $sensorIndex',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Text(
                          '${sensor.humidity}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
