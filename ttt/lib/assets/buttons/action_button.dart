import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/styles/text_style.dart';

enum ButtonType { regular, destructive }

class ActionButton extends StatefulWidget {
  final String title;
  final AsyncCallback onPressed;
  final ButtonType type;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final bool disabled;

  const ActionButton({
    required this.title,
    required this.onPressed,
    this.type = ButtonType.regular,
    this.disabled = false,
    this.loading = false,
    this.color,
    this.textColor,
    this.icon,
    this.fullWidth = false,
    Key? key,
  }) : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  bool _disabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _ios();
    }

    return _android();
  }

  Widget _buttonContent() {
    List<Widget> children = [];

    children.add(
      Text(
        widget.title,
        style: BaseTextStyle(
          color: _textColor(),
          fontSize: FontSize.button,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (widget.icon != null) {
      children.addAll([
        const SizedBox(width: 10.0),
        Icon(
          widget.icon,
          color: _textColor(),
          size: 16.0,
        )
      ]);
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AnimatedOpacity(
          opacity: widget.loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: widget.loading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 20.0,
            width: 20.0,
            child: const CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Color _textColor() {
    if (widget.type == ButtonType.destructive) {
      return Colors.white;
    }
    var color = ThemeData.estimateBrightnessForColor(_backgroundColor()) == Brightness.light ? Colors.black87 : Colors.white;
    return widget.textColor ?? color;
  }

  Color _backgroundColor() {
    if (widget.type == ButtonType.destructive) {
      return AppColors.destructive;
    }

    return widget.color ?? Theme.of(context).primaryColor;
  }

  Widget _android() {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: widget.fullWidth ? const Size.fromHeight(44) : null,
      backgroundColor: _backgroundColor(),
      elevation: 0,
      textStyle: BaseTextStyle(
        color: _textColor(),
        fontWeight: FontWeight.w600,
      ),
    );

    return ElevatedButton(
      style: buttonStyle,
      onPressed: _isDisabled ? null : _onPressed,
      child: _buttonContent(),
    );
  }

  Widget _ios() {
    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: CupertinoButton(
        color: _backgroundColor(),
        onPressed: _isDisabled ? null : _onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        borderRadius: const BorderRadius.all(
          Radius.circular(4.0),
        ),
        child: _buttonContent(),
      ),
    );
  }

  void _onPressed() async {
    if (!widget.disabled && !widget.disabled) {
      _setDisabled(true);

      await widget.onPressed();

      _setDisabled(false);
    }
  }

  bool get _isDisabled => _disabled || widget.disabled;

  void _setDisabled(bool disabled) {
    if (!mounted) {
      return;
    }
    setState(() => _disabled = disabled);
  }
}
