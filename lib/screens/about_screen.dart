import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.crashReporting = false});

  /// True when this build sends crash reports (see crash_reporting.dart).
  final bool crashReporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Invoice Generator', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
              'Build an invoice from line items with tax and discount, then copy a plain-text version.',
              style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Features', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Bullet('Line items with quantity and unit price'),
          const _Bullet(
              'Discount percentage and tax rate applied in integer cents'),
          const _Bullet('Plain-text invoice preview you can copy'),
          const SizedBox(height: 16),
          Text('Privacy', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            crashReporting
                ? 'Everything runs on this device. The app has no account or '
                    'analytics. If it crashes, it sends a crash report to Sentry '
                    'with the error type and where in the code it happened, '
                    'never your invoice or personal details. The invoice you are '
                    'editing is saved locally on this device.'
                : 'Everything runs on this device. The app has no account, '
                    'analytics or network calls. The invoice you are editing is '
                    'saved locally on this device.',
          ),
          const SizedBox(height: 16),
          Text('Made by Chaowalit Greepoke · bookchaowalit.com',
              style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
