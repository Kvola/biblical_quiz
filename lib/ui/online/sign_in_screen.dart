import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../common.dart';
import 'online_common.dart';

/// Devenir joueur : numéro de téléphone, code reçu par WhatsApp, puis pseudo.
///
/// Rend true quand le joueur est prêt (profil créé).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static Future<bool> open(BuildContext context) async =>
      await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const SignInScreen())) == true;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

enum _Step { phone, code, pseudo }

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _pseudo = TextEditingController();
  _Step _step = _Step.phone;
  bool _busy = false;
  String? _error;
  String? _canonical;
  List<({String code, String name, String dial})> _countries = const [];
  String? _country;

  @override
  void initState() {
    super.initState();
    final me = ref.read(onlineMeProvider).value;
    if (me != null && me.player == null) _step = _Step.pseudo;
    _loadCountries();
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _pseudo.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final r = await ref.read(onlineServiceProvider).countries(context.lang);
      if (!mounted) return;
      setState(() {
        _countries = [
          for (final c in (r['countries'] as List? ?? const []).whereType<Map>())
            (code: '${c['code']}', name: '${c['name']}', dial: '${c['dial']}'),
        ];
        _country = '${r['default'] ?? (_countries.isEmpty ? 'CI' : _countries.first.code)}';
      });
    } catch (_) {
      if (mounted) setState(() => _country ??= 'CI');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = onlineError(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty) return;
    _canonical = await ref.read(onlineServiceProvider).requestCode(phone, country: _country);
    setState(() => _step = _Step.code);
  });

  Future<void> _verify() => _run(() async {
    final me = await ref.read(onlineServiceProvider).verifyCode(_canonical ?? _phone.text.trim(), _code.text.trim());
    ref.read(onlineMeProvider.notifier).set(me);
    if (me.player != null) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() => _step = _Step.pseudo);
    }
  });

  Future<void> _savePseudo() => _run(() async {
    final OnlineMe me = await ref.read(onlineServiceProvider).register(_pseudo.text.trim(), context.lang);
    ref.read(onlineMeProvider.notifier).set(me);
    if (mounted) Navigator.of(context).pop(true);
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(_step == _Step.pseudo ? l.pseudoTitle : l.signInTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ...switch (_step) {
              _Step.phone => [
                Text(l.onlineAccountHint),
                const SizedBox(height: 16),
                if (_countries.length > 1)
                  DropdownButtonFormField<String>(
                    key: ValueKey(_country),
                    initialValue: _country,
                    decoration: InputDecoration(labelText: l.signInCountry),
                    items: [
                      for (final c in _countries) DropdownMenuItem(value: c.code, child: Text('${c.name} (+${c.dial})')),
                    ],
                    onChanged: (v) => setState(() => _country = v),
                  ),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    labelText: l.signInPhone,
                    prefixText: _countries.where((c) => c.code == _country).map((c) => '+${c.dial} ').firstOrNull,
                  ),
                  onSubmitted: (_) => _sendCode(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.chat),
                  label: Text(l.signInSendCode),
                  onPressed: _busy ? null : _sendCode,
                ),
                const SizedBox(height: 16),
                Text(l.signInPrivacy, style: Theme.of(context).textTheme.bodySmall),
              ],
              _Step.code => [
                Text(l.signInCodeSent(_canonical ?? _phone.text)),
                const SizedBox(height: 16),
                TextField(
                  controller: _code,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l.signInCode),
                  onSubmitted: (_) => _verify(),
                ),
                FilledButton(onPressed: _busy ? null : _verify, child: Text(l.signInVerify)),
                Row(
                  children: [
                    TextButton(onPressed: _busy ? null : _sendCode, child: Text(l.signInResend)),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _step = _Step.phone),
                      child: Text(l.signInChangeNumber),
                    ),
                  ],
                ),
              ],
              _Step.pseudo => [
                TextField(
                  controller: _pseudo,
                  autofocus: true,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.pseudoLabel, helperText: l.pseudoHint),
                  onSubmitted: (_) => _savePseudo(),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _busy ? null : _savePseudo, child: Text(l.pseudoSave)),
              ],
            },
            if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}
