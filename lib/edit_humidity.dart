import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditHumidity extends StatefulWidget {
  final double currentHumidity;
  EditHumidity({required this.currentHumidity});

  @override
  State<EditHumidity> createState() => _EditHumidityState();
}

class _EditHumidityState extends State<EditHumidity> {
  final ValueNotifier<double> _humidity = ValueNotifier(0);
  final databaseReference = FirebaseDatabase.instance.ref();

  void updateMaxHumidity() {
    databaseReference.child('max_humidity').set(_humidity.value);
  }

  @override
  void initState() {
    super.initState();
    _humidity.value = widget.currentHumidity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.expand_more,
          color: Colors.white,
        ),
        actions: [
          Icon(
            Icons.settings,
            color: Colors.white,
          ),
          Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
        ],
        shadowColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Text('Editar umidade máxima',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            const Text(
              'Mude o valor em que o app \n envia uma notificação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 60),
            ValueListenableBuilder(
              valueListenable: _humidity,
              builder: (_, value, __) => Column(
                children: [
                  DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1.1,
                    progress: value,
                    startAngle: 225,
                    sweepAngle: 270,
                    foregroundColor: Colors.greenAccent,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Umidade máxima',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Slider(
                      value: _humidity.value,
                      thumbColor: Colors.blueAccent,
                      activeColor: Colors.white,
                      min: 0.0,
                      max: 100.0,
                      divisions: 200,
                      onChanged: (value) {
                        _humidity.value = (value * 2).round() / 2;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                updateMaxHumidity();
                Navigator.pop(context);
              },
              label: const Icon(
                Icons.save,
                color: Color.fromRGBO(40, 162, 255, 1),
              ),
              icon: const Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
