// Data transfer object for CBT records (used in cbt_wizard_provider.dart)
// Note: Domain entity is in lib/domain/entities/cbt_thought_record.dart
class CbtThoughtRecordDto {
  final String id;
  final String initialThought;
  final List<String> detectedDistortions;

  CbtThoughtRecordDto({
    required this.id,
    required this.initialThought,
    required this.detectedDistortions,
  });
}
