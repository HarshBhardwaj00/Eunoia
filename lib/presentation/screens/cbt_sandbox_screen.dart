import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cbt_record_model.dart';
import '../../providers/cbt_wizard_provider.dart';
import '../../providers/app_providers.dart';
import 'cbt_archive_screen.dart';

// CBT Thought Wizard - guides users through cognitive behavioral therapy exercises
class CbtSandboxScreen extends ConsumerWidget {
  const CbtSandboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cbtWizardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBT Thought Wizard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CbtArchiveScreen(),
                ),
              );
            },
            tooltip: 'View Archive',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepIndicator(state),
                const SizedBox(height: 32),
                _buildStepContent(context, ref, state),
                const SizedBox(height: 16),
                _buildNextButton(context, ref, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(CbtWizardState state) {
    int currentStep = 0;
    if (state.step == CbtWizardStep.identifyDistortions) currentStep = 1;
    if (state.step == CbtWizardStep.challengeEvidence) currentStep = 2;
    if (state.step == CbtWizardStep.balancedOutcome) currentStep = 3;

    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: index <= currentStep ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    WidgetRef ref,
    CbtWizardState state,
  ) {
    switch (state.step) {
      case CbtWizardStep.initialThought:
        return _InitialThoughtForm(record: state.record);
      case CbtWizardStep.identifyDistortions:
        return _DistortionSelectionForm(record: state.record);
      case CbtWizardStep.challengeEvidence:
        return _EvidenceForm(record: state.record);
      case CbtWizardStep.balancedOutcome:
        return _BalancedThoughtForm(record: state.record);
    }
  }

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
    CbtWizardState state,
  ) {
    bool canProceed = false;
    switch (state.step) {
      case CbtWizardStep.initialThought:
        canProceed = state.record.initialThought.trim().isNotEmpty;
        break;
      case CbtWizardStep.identifyDistortions:
        canProceed = state.record.detectedDistortions.isNotEmpty;
        break;
      case CbtWizardStep.challengeEvidence:
        canProceed = true;
        break;
      case CbtWizardStep.balancedOutcome:
        canProceed = false;
        break;
    }

    return ElevatedButton(
      onPressed: canProceed
          ? () => ref.read(cbtWizardProvider.notifier).nextStep()
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        state.step == CbtWizardStep.balancedOutcome ? 'Complete' : 'Next',
      ),
    );
  }
}

class _InitialThoughtForm extends ConsumerStatefulWidget {
  final CbtThoughtRecordDto record;
  const _InitialThoughtForm({required this.record});

  @override
  ConsumerState<_InitialThoughtForm> createState() =>
      _InitialThoughtFormState();
}

class _InitialThoughtFormState extends ConsumerState<_InitialThoughtForm> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.record.initialThought);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter your thought');
    } else {
      setState(() => _errorText = null);
      ref.read(cbtWizardProvider.notifier).updateNegativeThought(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What negative thought are you experiencing?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your negative thought...',
            border: const OutlineInputBorder(),
            errorText: _errorText,
          ),
          onChanged: (_) => _validateAndSave(),
        ),
      ],
    );
  }
}

class _DistortionSelectionForm extends ConsumerWidget {
  final CbtThoughtRecordDto record;
  const _DistortionSelectionForm({required this.record});

  static const List<String> _distortions = [
    'All-or-nothing thinking',
    'Overgeneralization',
    'Mental filter',
    'Disqualifying the positive',
    'Jumping to conclusions',
    'Magnification',
    'Emotional reasoning',
    'Should statements',
    'Labeling',
    'Personalization',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which cognitive distortions apply?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._distortions.map((distortion) {
          final isSelected = record.detectedDistortions.contains(distortion);
          return CheckboxListTile(
            title: Text(distortion),
            value: isSelected,
            onChanged: (_) {
              ref.read(cbtWizardProvider.notifier).toggleDistortion(distortion);
            },
          );
        }),
      ],
    );
  }
}

class _EvidenceForm extends StatefulWidget {
  final CbtThoughtRecordDto record;
  const _EvidenceForm({required this.record});

  @override
  State<_EvidenceForm> createState() => _EvidenceFormState();
}

class _EvidenceFormState extends State<_EvidenceForm> {
  late TextEditingController _evidenceForController;
  late TextEditingController _evidenceAgainstController;

  @override
  void initState() {
    super.initState();
    _evidenceForController = TextEditingController();
    _evidenceAgainstController = TextEditingController();
  }

  @override
  void dispose() {
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Challenge your thought with evidence',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _evidenceForController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Evidence supporting the thought',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _evidenceAgainstController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Evidence against the thought',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _BalancedThoughtForm extends ConsumerStatefulWidget {
  final CbtThoughtRecordDto record;
  const _BalancedThoughtForm({required this.record});

  @override
  ConsumerState<_BalancedThoughtForm> createState() =>
      _BalancedThoughtFormState();
}

class _BalancedThoughtFormState extends ConsumerState<_BalancedThoughtForm> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Extract data from the record
      final situation = widget.record.initialThought;
      final negativeThought = widget.record.initialThought;
      final cognitiveDistortionType = widget.record.detectedDistortions.join(
        ', ',
      );
      final rationalChallenge = _controller.text;
      final alternativeThought = _controller.text;

      // Call the CBT repository to save
      await ref
          .read(cbtRepositoryProvider)
          .saveCbtRecord(
            situation: situation,
            negativeThought: negativeThought,
            cognitiveDistortionType: cognitiveDistortionType,
            rationalChallenge: rationalChallenge,
            alternativeThought: alternativeThought,
          );

      // Clear the form
      _controller.clear();

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflection safely encrypted & archived.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to dashboard
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reflection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is a more balanced thought?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your balanced perspective...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReflection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Reflection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Securing your cognitive record...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
