import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

class W3MIconButton extends StatelessWidget {
  const W3MIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final Widget icon;
  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return MaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusColor: themeData.overlay030,
      hoverColor: themeData.overlay020,
      child: Container(
        // constraints: const BoxConstraints(
        //   maxWidth: 100,
        // ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          // horizontal: 4,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: themeData.primary100,
                  fontSize: 12,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}