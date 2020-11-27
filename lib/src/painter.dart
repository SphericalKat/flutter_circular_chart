import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_circular_chart/src/animated_circular_chart.dart';
import 'package:flutter_circular_chart/src/circular_chart.dart';
import 'package:flutter_circular_chart/src/stack.dart';

class AnimatedCircularChartPainter extends CustomPainter {
  AnimatedCircularChartPainter(this.animation, this.labelPainter)
      : super(repaint: animation);

  final Animation<CircularChart> animation;
  final TextPainter labelPainter;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLabel(canvas, size, labelPainter);
    _paintChart(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(AnimatedCircularChartPainter old) => false;
}

class CircularChartPainter extends CustomPainter {
  CircularChartPainter(this.chart, this.labelPainter);

  final CircularChart chart;
  final TextPainter labelPainter;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLabel(canvas, size, labelPainter);
    _paintChart(canvas, size, chart);
  }

  @override
  bool shouldRepaint(CircularChartPainter old) => false;
}

const double _kRadiansPerDegree = Math.pi / 180;

void _paintLabel(Canvas canvas, Size size, TextPainter labelPainter) {
  if (labelPainter != null) {
    labelPainter.paint(
      canvas,
      new Offset(
        size.width / 2 - labelPainter.width / 2,
        size.height / 2 - labelPainter.height / 2,
      ),
    );
  }
}

double convertRadiusToSigma(double radius) => radius * 0.57735 + 0.5;

void _paintChart(Canvas canvas, Size size, CircularChart chart) {
  final Paint segmentPaint = new Paint()
    ..style = chart.chartType == CircularChartType.Radial
        ? PaintingStyle.stroke
        : PaintingStyle.fill
    ..strokeCap = chart.edgeStyle == SegmentEdgeStyle.round
        ? StrokeCap.round
        : StrokeCap.butt;

  for (final CircularChartStack stack in chart.stacks) {
    for (final segment in stack.segments) {
      segmentPaint.shader =
          LinearGradient(colors: [segment.startColor, segment.endColor])
              .createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
      );

      segmentPaint.strokeWidth = segment.strokeWidth ?? stack.width;
      final Paint shadowPaint = Paint()
        ..style = chart.chartType == CircularChartType.Radial
            ? PaintingStyle.stroke
            : PaintingStyle.fill
        ..strokeCap = chart.edgeStyle == SegmentEdgeStyle.round
            ? StrokeCap.round
            : StrokeCap.butt
        // ..color = Colors.black.withAlpha(128)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(12));

      shadowPaint.strokeWidth = (segment.strokeWidth ?? stack.width) - 2;
      shadowPaint.shader =
          LinearGradient(colors: [segment.startColor, segment.endColor])
              .createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
      );

      canvas.drawArc(
        new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
        stack.startAngle * _kRadiansPerDegree,
        segment.sweepAngle * _kRadiansPerDegree,
        chart.chartType == CircularChartType.Pie,
        shadowPaint,
      );

      canvas.drawArc(
        new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
        stack.startAngle * _kRadiansPerDegree,
        segment.sweepAngle * _kRadiansPerDegree,
        chart.chartType == CircularChartType.Pie,
        segmentPaint,
      );
    }
  }
}
