import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/local_cbt_model.dart';
import '../../providers/app_providers.dart';
import '../../services/encryption_service.dart';

class CbtArchiveScreen extends ConsumerStatefulWidget {
  const CbtArchiveScreen({super.key});

  @override
  ConsumerState<CbtArchiveScreen> createState() => _CbtArchiveScreenState();
}

class _CbtArchiveScreenState extends ConsumerState<CbtArchiveScreen> {
  bool _isLoading = true;
  List<LocalCbtRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await ref.read(cbtRepositoryProvider).getCbtRecords();
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load records: $e')));
      }
    }
  }

  String _decryptField(String encryptedField) {
    try {
      return EncryptionService.decryptData(encryptedField);
    } catch (e) {
      return encryptedField;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Archive')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No CBT records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the wizard to create your first reflection',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return _buildRecordCard(record);
              },
            ),
    );
  }

  Widget _buildRecordCard(LocalCbtRecord record) {
    final situation = _decryptField(record.encryptedSituation);
    final negativeThought = _decryptField(record.encryptedNegativeThought);
    final rationalChallenge = _decryptField(record.encryptedRationalChallenge);
    final alternativeThought = _decryptField(
      record.encryptedAlternativeThought,
    );
    final date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          situation,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Cognitive Distortion',
                  record.cognitiveDistortionType,
                ),
                const SizedBox(height: 12),
                _buildSection('Negative Thought', negativeThought),
                const SizedBox(height: 12),
                _buildSection('Rational Challenge', rationalChallenge),
                const SizedBox(height: 12),
                _buildSection('Alternative Thought', alternativeThought),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecord(record.id),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this CBT record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(cbtRepositoryProvider).deleteCbtRecord(id);
        setState(() {
          _records.removeWhere((r) => r.id == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Record deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete record: $e')),
          );
        }
      }
    }
  }
}
