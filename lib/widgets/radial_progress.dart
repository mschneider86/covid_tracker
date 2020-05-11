import 'dart:math';

import "package:flutter/material.dart";
import 'package:vector_math/vector_math_64.dart' as math;

class RadialProgress extends StatefulWidget {
  final progressValue;
  final Color startClr, endClr, bgClr;

  RadialProgress(
      {Key key, this.progressValue, this.startClr, this.endClr, this.bgClr})
      : super(key: key);

  @override
  _RadialProgressState createState() => _RadialProgressState();
}

class _RadialProgressState extends State<RadialProgress> with TickerProviderStateMixin {
  AnimationController _radialController;
  Animation<double> _radialAnimation;
  double progressDegrees = 0;
  final Duration fadeInDuration = Duration(milliseconds: 500);
  final Duration fillDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _radialController =
        AnimationController(vsync: this, duration: fillDuration); //1.5s
    _radialAnimation = Tween(begin: 0.0, end: 360.0).animate(
        CurvedAnimation(parent: _radialController, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        progressDegrees = widget.progressValue * _radialAnimation.value;
      });
    _radialController.forward();
  }

  @override
  void didUpdateWidget(RadialProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.startClr!=widget.startClr||oldWidget.endClr!=widget.endClr||oldWidget.bgClr!=widget.bgClr){
      _radialController.reset();
      _radialController.forward();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _radialController.dispose();
  }

  String getPercent() {
    return ((progressDegrees / 360.0) * 100).toStringAsPrecision(3);
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _radialAnimation,
      builder: (context, child) => Container(
        width: 162,
        height: 162,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: <Widget>[
            CustomPaint(
              child: Container(
                height: 145.0,
                width: 145.0,
                padding: EdgeInsets.all(40.0),
                child: AnimatedOpacity(
                  opacity: double.parse(getPercent()) > 5.0 ? 1.0 : 0.0,
                  duration: fadeInDuration,
                  child: Center(
                    child: Text(
                      "${getPercent()}%",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          color: widget.endClr,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              painter: RadialPainter(
                degrees: progressDegrees,
                startClr: widget.startClr,
                endClr: widget.endClr,
                bgClr: widget.bgClr,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment(
                  cos((2*pi*progressDegrees/360.0)-(pi/2)),
                  sin((2*pi*progressDegrees/360.0)-(pi/2))
                ),
                child: Material(
                  animationDuration: fillDuration,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: widget.endClr,
                      border: Border.all(color: Colors.white, width: 4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RadialPainter extends CustomPainter {
  final double degrees;
  final Color startClr, endClr, bgClr;

  RadialPainter({this.degrees, this.startClr, this.endClr, this.bgClr});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Rect rect = Rect.fromCircle(center: center, radius: size.width / 2);

    Paint circle1 = Paint()..color = bgClr;
    Paint circle2 = Paint()..color = Colors.white;
    canvas.drawCircle(center, size.width / 2, circle1);
    canvas.drawCircle(center, size.width / 4, circle2);

    Paint progressPaint = Paint()
      ..shader = SweepGradient(
              colors: <Color>[startClr, endClr],
              tileMode: TileMode.repeated,
              center: Alignment.center,
              startAngle: 3 * pi / 2,
              endAngle: 7 * pi / 2)
          .createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..isAntiAlias = true;

    canvas.drawArc(
        rect, math.radians(-90), math.radians(degrees), false, progressPaint);
  }

  @override
  bool shouldRepaint(RadialPainter oldDelegate) {
    return oldDelegate.degrees != degrees;
  }
}