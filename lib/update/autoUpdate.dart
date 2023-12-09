import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';

class AutoUpdate {
  Future<void> getPackageData() async {
    PackageInfo _packageInfo = PackageInfo();

    _packageInfo = await PackageManager.getPackageInfo();

    /// Android
    if (Platform.isAndroid) {
      InAppUpdateManager manager = InAppUpdateManager();
      AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) return;
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        //If an in-app update is already running, resume the update.
        String? message =
            await manager.startAnUpdate(type: AppUpdateType.immediate);
        debugPrint(message ?? '');
      } else if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        ///Update available
        if (appUpdateInfo.immediateAllowed) {
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint(message ?? '');
        } else if (appUpdateInfo.flexibleAllowed) {
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.flexible);
          debugPrint(message ?? '');
        } else {
          debugPrint(
              'Update available. Immediate & Flexible Update Flow not allow');
        }
      }
    } else if (Platform.isIOS) {
      VersionInfo? _versionInfo = await UpgradeVersion.getiOSStoreVersion(
          packageInfo: _packageInfo, regionCode: "US");
      debugPrint(_versionInfo.toJson().toString());
    }
  }
}
