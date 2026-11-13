import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesService {
  bool _configured = false;

  Future<void> logIn(String userId) async {
    if (kIsWeb) return;
    final apiKey = defaultTargetPlatform == TargetPlatform.android
        ? const String.fromEnvironment('REVENUECAT_ANDROID_API_KEY')
        : defaultTargetPlatform == TargetPlatform.iOS
        ? const String.fromEnvironment('REVENUECAT_IOS_API_KEY')
        : '';
    if (apiKey.isEmpty) return;

    if (!_configured) {
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = userId,
      );
      _configured = true;
      return;
    }
    await Purchases.logIn(userId);
  }

  Future<List<Package>> offerings() async {
    if (!_configured) {
      throw StateError('Les clés RevenueCat ne sont pas configurées.');
    }
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? <Package>[];
  }

  Future<void> purchase(Package package) async {
    if (!_configured) {
      throw StateError('Les clés RevenueCat ne sont pas configurées.');
    }
    await Purchases.purchase(PurchaseParams.package(package));
  }

  Future<void> restore() async {
    if (!_configured) {
      throw StateError('Les clés RevenueCat ne sont pas configurées.');
    }
    await Purchases.restorePurchases();
  }

  Future<void> logOut() async {
    if (_configured) await Purchases.logOut();
  }
}
