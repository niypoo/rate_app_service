import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'package:get/get.dart';

class RateAppService extends GetxService {
  late RateMyApp rateMyApp;

  // functions properties
  final BuildContext context;
  final String title;
  final String rateButtonText;
  final String message;
  final Function notSatisfiedAction;
  final String preferencesPrefix;

  // rate properties
  final String googlePlayIdentifier;
  final String appStoreIdentifier;
  final int minDays;
  final int minLaunches;
  final int remindDays;
  final int remindLaunches;

  RateAppService({
    required this.preferencesPrefix,
    required this.appStoreIdentifier,
    required this.googlePlayIdentifier,
    required this.rateButtonText,
    required this.notSatisfiedAction,
    required this.context,
    required this.message,
    required this.title,
    this.minDays = 5,
    this.minLaunches = 20,
    this.remindDays = 3,
    this.remindLaunches = 5,
  });

  Future<RateAppService> init() async {
    // instantiate
    rateMyApp = RateMyApp(
      preferencesPrefix: preferencesPrefix,
      minDays: minDays,
      minLaunches: minLaunches,
      remindDays: remindDays,
      remindLaunches: remindLaunches,
      googlePlayIdentifier: googlePlayIdentifier,
      appStoreIdentifier: appStoreIdentifier,
    );

    return this;
  }

  //if user eligible to show dialog
  Future<void> autoRateDialog() async {
    //init
    await rateMyApp.init();
    // if eligible
    if (rateMyApp.shouldOpenDialog) {
      await rateDialog();
    }
  }

  // rate dialog
  Future<void> rateDialog() async {
    await rateMyApp.showStarRateDialog(
      context,
      title: title,
      message: message,
      actionsBuilder: (context, stars) {
        return [
          TextButton(
            onPressed: stars == null || stars <= 0
                ? null
                : () async {
                    // user stars
                    final int userStars = stars.round();

                    // if less then 3 stars open support email
                    if (userStars <= 3) {
                      notSatisfiedAction();
                    }

                    // else open store page
                    else {
                      // OPENED APP SOTRE TO RATE
                      final LaunchStoreResult storeResult =
                          await rateMyApp.launchStore();

                      // IF STORE OPENED TRIGGER EVENT THE APP RATED
                      if (LaunchStoreResult.storeOpened == storeResult) {
                        await rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                      }
                    }

                    // close Dialog
                    // ignore: use_build_context_synchronously
                    Navigator.pop<RateMyAppDialogButton>(
                        context, RateMyAppDialogButton.rate);
                  },
            child: Text(rateButtonText),
          ),
        ];
      },
      ignoreNativeDialog: true,

      starRatingOptions:
          const StarRatingOptions(), // Custom star bar rating options.
      onDismissed: () => rateMyApp.callEvent(
        RateMyAppEventType.laterButtonPressed,
      ),
      // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
    );
  }
}
