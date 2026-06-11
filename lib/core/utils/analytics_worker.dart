import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Result of correlation analysis
class CorrelationResult {
  final double correlationCoefficient;
  final String factor1;
  final String factor2;
  final String interpretation;

  CorrelationResult({
    required this.correlationCoefficient,
    required this.factor1,
    required this.factor2,
    required this.interpretation,
  });

  @override
  String toString() {
    return 'Correlation between $factor1 and $factor2: ${correlationCoefficient.toStringAsFixed(3)} - $interpretation';
  }
}

/// Data point for analysis
class DataPoint {
  final DateTime timestamp;
  final Map<String, double> metrics;

  DataPoint({required this.timestamp, required this.metrics});
}

/// Parameters for correlation computation
class CorrelationParams {
  final List<DataPoint> dataPoints;
  final String metric1;
  final String metric2;

  CorrelationParams({
    required this.dataPoints,
    required this.metric1,
    required this.metric2,
  });
}

/// Isolated compute function for correlation analysis
/// This runs in a separate isolate to prevent UI frame drops
CorrelationResult computeCorrelation(CorrelationParams params) {
  if (params.dataPoints.length < 2) {
    return CorrelationResult(
      correlationCoefficient: 0.0,
      factor1: params.metric1,
      factor2: params.metric2,
      interpretation: 'Insufficient data',
    );
  }

  // Extract paired data
  final pairs = <List<double>>[];
  for (final point in params.dataPoints) {
    final val1 = point.metrics[params.metric1];
    final val2 = point.metrics[params.metric2];
    if (val1 != null && val2 != null) {
      pairs.add([val1, val2]);
    }
  }

  if (pairs.length < 2) {
    return CorrelationResult(
      correlationCoefficient: 0.0,
      factor1: params.metric1,
      factor2: params.metric2,
      interpretation: 'Insufficient paired data',
    );
  }

  // Calculate Pearson correlation coefficient
  final n = pairs.length.toDouble();
  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double sumX2 = 0;
  double sumY2 = 0;

  for (final pair in pairs) {
    final x = pair[0];
    final y = pair[1];
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
    sumY2 += y * y;
  }

  final numerator = (n * sumXY) - (sumX * sumY);
  final denominator = sqrt(
    ((n * sumX2) - (sumX * sumX)) * ((n * sumY2) - (sumY * sumY)),
  );

  if (denominator == 0) {
    return CorrelationResult(
      correlationCoefficient: 0.0,
      factor1: params.metric1,
      factor2: params.metric2,
      interpretation: 'No variance in data',
    );
  }

  final correlation = numerator / denominator;
  final interpretation = _interpretCorrelation(correlation);

  return CorrelationResult(
    correlationCoefficient: correlation,
    factor1: params.metric1,
    factor2: params.metric2,
    interpretation: interpretation,
  );
}

/// Interpret correlation strength
String _interpretCorrelation(double correlation) {
  final absCorr = correlation.abs();
  if (absCorr >= 0.8) {
    return correlation > 0
        ? 'Strong positive correlation'
        : 'Strong negative correlation';
  } else if (absCorr >= 0.5) {
    return correlation > 0
        ? 'Moderate positive correlation'
        : 'Moderate negative correlation';
  } else if (absCorr >= 0.3) {
    return correlation > 0
        ? 'Weak positive correlation'
        : 'Weak negative correlation';
  } else {
    return 'No significant correlation';
  }
}

/// Top-level function to run correlation analysis in isolate
/// Takes raw history logs (as List<Map>) and returns correlation results
Future<List<CorrelationResult>> runAnalyticsInIsolate(
  List<Map<String, dynamic>> rawLogs,
) async {
  // Convert raw logs to DataPoints
  final dataPoints = rawLogs.map((log) {
    final metrics = <String, double>{};
    log.forEach((key, value) {
      if (key != 'timestamp' && value is num) {
        metrics[key] = value.toDouble();
      }
    });
    return DataPoint(
      timestamp: DateTime.parse(
        log['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      metrics: metrics,
    );
  }).toList();

  // Define metric pairs to analyze
  final metricPairs = <List<String>>[
    ['sleep_hours', 'anxiety_level'],
    ['sleep_hours', 'mood_score'],
    ['exercise_minutes', 'anxiety_level'],
    ['exercise_minutes', 'mood_score'],
    ['caffeine_intake', 'sleep_hours'],
    ['caffeine_intake', 'anxiety_level'],
  ];

  // Run correlation analysis for each pair using compute()
  final results = <CorrelationResult>[];
  for (final pair in metricPairs) {
    final result = await compute(
      computeCorrelation,
      CorrelationParams(
        dataPoints: dataPoints,
        metric1: pair[0],
        metric2: pair[1],
      ),
    );
    results.add(result);
  }

  return results;
}

/// Convenience function for single correlation analysis
Future<CorrelationResult> analyzeSingleCorrelation(
  List<Map<String, dynamic>> rawLogs,
  String metric1,
  String metric2,
) async {
  final dataPoints = rawLogs.map((log) {
    final metrics = <String, double>{};
    log.forEach((key, value) {
      if (key != 'timestamp' && value is num) {
        metrics[key] = value.toDouble();
      }
    });
    return DataPoint(
      timestamp: DateTime.parse(
        log['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      metrics: metrics,
    );
  }).toList();

  return await compute(
    computeCorrelation,
    CorrelationParams(
      dataPoints: dataPoints,
      metric1: metric1,
      metric2: metric2,
    ),
  );
}
