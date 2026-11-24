import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_bank.dart';
import '../../online/api.dart';
import '../common.dart';

/// Signalement d'une question rédigée par IA : motif, précision facultative, envoi.
Future<void> showAiReportSheet(BuildContext context, AiChoiceQuestion question) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _AiReportSheet(question: question),
);

class _AiReportSheet extends ConsumerStatefulWidget {
  const _AiReportSheet({required this.question});

  final AiChoiceQuestion question;

  @override
  ConsumerState<_AiReportSheet> createState() => _AiReportSheetState();
}

class _AiReportSheetState extends ConsumerState<_AiReportSheet> {
  final _note = TextEditingController();
  String _reason = 'wrong';
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _sending = true);
    String message;
    try {
      final withdrawn = await ref.read(aiBankServiceProvider).report(widget.question.id, _reason, _note.text);
      message = withdrawn ? l.aiReportWithdrawn : l.aiReportThanks;
    } on ApiException {
      message = l.aiReportOffline;
    }
    if (!mounted) return;
    nav.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reasons = [
      ('wrong', l.aiReportWrong),
      ('several', l.aiReportSeveral),
      ('unclear', l.aiReportUnclear),
      ('doctrine', l.aiReportDoctrine),
      ('other', l.aiReportOther),
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.aiReportTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v ?? _reason),
                child: Column(
                  children: [
                    for (final (value, label) in reasons)
                      RadioListTile<String>(
                        key: ValueKey('ai-reason-$value'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: value,
                        title: Text(label),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _note,
                maxLength: 300,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.aiReportNote),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('ai-report-send'),
                  onPressed: _sending ? null : _send,
                  child: Text(l.aiReportSend),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
