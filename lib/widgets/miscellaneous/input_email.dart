import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';

class InputEmailWidget extends StatefulWidget {
  final Function(String value) onSubmitted;
  final String? initialValue;
  final Function(String value)? onValueChange;
  final Widget? suffixIcon;
  final Function(bool value)? onFocus;
  const InputEmailWidget({
    super.key,
    required this.onSubmitted,
    this.initialValue,
    this.onValueChange,
    this.suffixIcon,
    this.onFocus,
  });

  @override
  State<InputEmailWidget> createState() => _InputEmailWidgetState();
}

class _InputEmailWidgetState extends State<InputEmailWidget> {
  bool hasFocus = false;
  late TextEditingController _controller;
  bool _ready = false;
  bool _timedOut = false;
  //
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _ready = magicService.instance.isReady.value;
    _timedOut = magicService.instance.isTimeout.value;
    magicService.instance.isReady.addListener(_updateStatus);
    magicService.instance.isTimeout.addListener(_updateStatus);
  }

  void _updateStatus() {
    setState(() {
      _ready = magicService.instance.isReady.value;
      _timedOut = magicService.instance.isTimeout.value;
    });
  }

  @override
  void didUpdateWidget(covariant InputEmailWidget oldWidget) {
    _updateStatus();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    magicService.instance.isTimeout.addListener(_updateStatus);
    magicService.instance.isReady.removeListener(_updateStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Web3ModalSearchBar(
      enabled: !_timedOut && _ready,
      controller: _controller,
      initialValue: _controller.text,
      hint: 'Email',
      iconPath: 'assets/icons/mail.svg',
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.go,
      onSubmitted: _validate,
      debounce: false,
      onTextChanged: (value) {
        widget.onValueChange?.call(value);
      },
      onFocusChange: _onFocusChange,
      suffixIcon: widget.suffixIcon ??
          (!magicService.instance.isReady.value
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        color: themeColors.accent100,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ],
                )
              : ValueListenableBuilder<String>(
                  valueListenable: magicService.instance.email,
                  builder: (context, value, _) {
                    if (!hasFocus) {
                      return SizedBox.shrink();
                    }
                    if (_invalidEmail(value)) {
                      return GestureDetector(
                        onTap: _clearEmail,
                        child: Padding(
                          padding: const EdgeInsets.all(kPadding8),
                          child: SvgPicture.asset(
                            AssetUtil.getThemedAsset(
                                context, 'input_cancel.svg'),
                            package: 'web3modal_flutter',
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _validate(value),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/icons/chevron_right.svg',
                          package: 'web3modal_flutter',
                          colorFilter: ColorFilter.mode(
                            themeColors.foreground300,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    );
                  },
                )),
    );
  }

  void _onFocusChange(bool focus) {
    if (hasFocus == focus) return;
    widget.onFocus?.call(focus);
    setState(() => hasFocus = focus);
  }

  bool _invalidEmail(String value) {
    return value.isEmpty || !coreUtils.instance.isValidEmail(value);
  }

  void _validate(String value) {
    if (_invalidEmail(value)) {
      return;
    }
    widget.onSubmitted(value);
  }

  void _clearEmail() {
    _controller.clear();
    magicService.instance.setEmail('');
    magicService.instance.setNewEmail('');
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
