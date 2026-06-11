import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cbt_record_model.dart';

// CBT wizard state
enum CbtWizardStep {
  initialThought,
  identifyDistortions,
  challengeEvidence,
  balancedOutcome,
}

class CbtWizardState {
  final CbtWizardStep step;
  final CbtThoughtRecordDto record;

  const CbtWizardState({
    this.step = CbtWizardStep.initialThought,
    required this.record,
  });

  CbtWizardState copyWith({CbtWizardStep? step, CbtThoughtRecordDto? record}) {
    return CbtWizardState(
      step: step ?? this.step,
      record: record ?? this.record,
    );
  }
}

// CBT wizard state notifier
class CbtWizardNotifier extends StateNotifier<CbtWizardState> {
  CbtWizardNotifier()
    : super(
        CbtWizardState(
          step: CbtWizardStep.initialThought,
          record: CbtThoughtRecordDto(
            id: '',
            initialThought: '',
            detectedDistortions: [],
          ),
        ),
      );

  void updateNegativeThought(String text) {
    state = state.copyWith(
      record: CbtThoughtRecordDto(
        id: state.record.id,
        initialThought: text,
        detectedDistortions: state.record.detectedDistortions,
      ),
    );
  }

  void toggleDistortion(String distortion) {
    final distortions = List<String>.from(state.record.detectedDistortions);
    if (distortions.contains(distortion)) {
      distortions.remove(distortion);
    } else {
      distortions.add(distortion);
    }
    state = state.copyWith(
      record: CbtThoughtRecordDto(
        id: state.record.id,
        initialThought: state.record.initialThought,
        detectedDistortions: distortions,
      ),
    );
  }

  void updateEvidence(String evidenceFor, String evidenceAgainst) {
    state = state.copyWith(
      record: CbtThoughtRecordDto(
        id: state.record.id,
        initialThought: state.record.initialThought,
        detectedDistortions: state.record.detectedDistortions,
      ),
    );
  }

  void submitReframedThought(String text) {
    state = state.copyWith(
      record: CbtThoughtRecordDto(
        id: state.record.id,
        initialThought: state.record.initialThought,
        detectedDistortions: state.record.detectedDistortions,
      ),
    );
  }

  void nextStep() {
    switch (state.step) {
      case CbtWizardStep.initialThought:
        state = state.copyWith(step: CbtWizardStep.identifyDistortions);
        break;
      case CbtWizardStep.identifyDistortions:
        state = state.copyWith(step: CbtWizardStep.challengeEvidence);
        break;
      case CbtWizardStep.challengeEvidence:
        state = state.copyWith(step: CbtWizardStep.balancedOutcome);
        break;
      case CbtWizardStep.balancedOutcome:
        // Already at final step
        break;
    }
  }
}

// CBT wizard provider
final cbtWizardProvider =
    StateNotifierProvider<CbtWizardNotifier, CbtWizardState>((ref) {
      return CbtWizardNotifier();
    });
