import 'package:flutter/material.dart';

class UtilWidget {
  static showLoadingDialog({
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 100),
      barrierColor: Colors.black.withOpacity(0.6),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (BuildContext context, a1, a2, widget) {
        return SizedBox(
          height: 50,
          width: 50,
          child: Opacity(
            opacity: a1.value,
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                content: const CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }
}
