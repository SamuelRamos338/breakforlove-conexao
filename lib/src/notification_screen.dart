import 'package:flutter/material.dart';
import 'dart:async';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _remainingMilliseconds = 0;
  bool _isTimerRunning = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  final List<Map<String, dynamic>> _timePresets = [
    {'label': '5 minutos', 'time': 5, 'description': '5 minutos para relaxar e respirar.'},
    {'label': '10 minutos', 'time': 10, 'description': '10 minutos para recarregar sua mente.'},
    {'label': '15 minutos', 'time': 15, 'description': '15 minutos para melhorar sua concentração.'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    )..addListener(() => setState(() {}));

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _startTimerFromPreset(int minutes) {
    setState(() {
      _hours = 0;
      _minutes = minutes;
      _seconds = 0;
    });
    _startTimer();
  }

  void _startTimer() {
    if (_isTimerRunning || (_hours == 0 && _minutes == 0 && _seconds == 0)) return;

    setState(() {
      _remainingMilliseconds = Duration(hours: _hours, minutes: _minutes, seconds: _seconds).inMilliseconds;
      _isTimerRunning = true;
      _controller.duration = Duration(milliseconds: _remainingMilliseconds);
      _controller.reverse(from: 1.0);
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_remainingMilliseconds > 0) {
        setState(() {
          _remainingMilliseconds -= 100;
          _hours = _remainingMilliseconds ~/ 3600000;
          _minutes = (_remainingMilliseconds % 3600000) ~/ 60000;
          _seconds = (_remainingMilliseconds % 60000) ~/ 1000;
        });
      } else {
        _stopTimer();
        _showCompletionNotification();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _controller.stop();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingMilliseconds = Duration(hours: _hours, minutes: _minutes, seconds: _seconds).inMilliseconds;
      _controller.value = 1.0;
    });
  }

  void _showCompletionNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parabéns! Você completou seu tempo longe do celular!")),
    );
  }

  String _formatTime(int milliseconds) {
    final hours = milliseconds ~/ 3600000;
    final minutes = (milliseconds % 3600000) ~/ 60000;
    final seconds = (milliseconds % 60000) ~/ 1000;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopTimer();
    super.dispose();
  }

  void _editTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Selecione o Tempo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimePicker("Horas", _hours, (val) => setState(() => _hours = val)),
                  _buildTimePicker("Minutos", _minutes, (val) => setState(() => _minutes = val)),
                  _buildTimePicker("Segundos", _seconds, (val) => setState(() => _seconds = val)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_hours == 0 && _minutes == 0 && _seconds == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("O tempo não pode ser zero!")),
                    );
                    return;
                  }
                  setState(() => _remainingMilliseconds = Duration(hours: _hours, minutes: _minutes, seconds: _seconds).inMilliseconds);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePicker(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 120,
          width: 80,
          child: ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(initialItem: value),
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(60, (index) => Center(child: Text(index.toString().padLeft(2, '0')))),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _editTime,
              child: AnimatedScale(
                scale: _isTimerRunning ? _scaleAnim.value : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: TimerPainter(
                          progress: _controller.value,
                          backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                          progressGradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          glowColor: theme.colorScheme.primary,
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_remainingMilliseconds),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isTimerRunning ? _stopTimer : null,
                  icon: const Icon(Icons.stop),
                  label: const Text("Parar"),
                ),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reiniciar"),
                ),
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Iniciar"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tempos predefinidos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _timePresets.length,
                itemBuilder: (context, index) {
                  final preset = _timePresets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(preset['label']),
                      subtitle: Text(preset['description']),
                      trailing: ElevatedButton(
                        onPressed: () => _startTimerFromPreset(preset['time']),
                        child: const Text("Iniciar"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final LinearGradient progressGradient;
  final Color glowColor;

  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressGradient,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..shader = progressGradient.createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2))
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    final Paint glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18);

    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5, 2 * 3.14 * progress, false, glowPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5, 2 * 3.14 * progress, false, progressPaint);
    canvas.drawCircle(center, radius, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
