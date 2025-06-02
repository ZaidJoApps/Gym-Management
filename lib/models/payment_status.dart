import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum PaymentStatus {
  fullyPaid,
  partiallyPaid,
  unpaid;

  String toDisplayString(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PaymentStatus.fullyPaid:
        return l10n.fullyPaid;
      case PaymentStatus.partiallyPaid:
        return l10n.partiallyPaid;
      case PaymentStatus.unpaid:
        return l10n.unpaid;
    }
  }
} 