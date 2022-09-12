import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

/// The `title` argument is used to title of alert dialog.\
/// The `textOK` argument is used to text for 'OK' Button of alert dialog.\
/// The `textCancel` argument is used to text for 'Cancel' Button of alert dialog.\
/// The `initialValue` argument is used to an initial value of alert dialog.\
/// The `isSelectedInitialValue` argument is used to select an initial value of alert dialog.\
/// The `hintText` argument will be hintText text field form of alert dialog.\
/// The `validator` argument will be validator text field form of alert dialog.\
/// The `minLines` argument will be minLines text field form of alert dialog.\
/// The `maxLines` argument will be maxLines text field form of alert dialog.\
/// The `autoFocus` argument will be autoFocus text field form of alert dialog.\
/// The `keyboardType` argument will be keyboardType text field form of alert dialog.\
/// The `textInputAction` argument will be textInputAction text field form of alert dialog.\
/// The `obscureText` argument will be obscureText text field form of alert dialog.\
/// The `obscuringCharacter` argument will be obscuringCharacter text field form of alert dialog.\
/// The `showPasswordIcon` visible for show password icon. default is false.\
/// The `barrierDismissible` argument will be barrierDismissible showDialog form of alert dialog.\
/// The `textCapitalization` argument will be textCapitalization text field form of alert dialog.
/// The `textAlign` argument will be textAlign text field form of alert dialog.
///
/// Returns a [Future<String?>].
Future<String> prompt(
  BuildContext context, {
  Widget title,
  Widget textOK,
  Widget textCancel,
  String initialValue,
  bool isSelectedInitialValue = true,
  String hintText,
  TextStyle hintStyle,
  TextStyle inputStyle,
  String Function(String) validator,
  int minLines = 1,
  int maxLines = 1,
  bool autoFocus = true,
  TextInputType keyboardType,
  TextInputAction textInputAction,
  bool obscureText = false,
  String obscuringCharacter = '•',
  bool showPasswordIcon = false,
  bool barrierDismissible = false,
  TextCapitalization textCapitalization = TextCapitalization.none,
  TextAlign textAlign = TextAlign.start,
  EdgeInsetsGeometry dialogPadding,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return _PromptDialog(
        title: title,
        textOK: textOK,
        textCancel: textCancel,
        initialValue: initialValue,
        isSelectedInitialValue: isSelectedInitialValue,
        hintText: hintText,
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        autoFocus: autoFocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        showPasswordIcon: showPasswordIcon,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        hintStyle: hintStyle,
        inputStyle: inputStyle,
        dialogPadding: dialogPadding,
      );
    },
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    Key key,
    this.title,
    this.textOK,
    this.textCancel,
    this.initialValue,
    this.isSelectedInitialValue,
    this.hintText,
    this.validator,
    this.minLines,
    this.maxLines,
    this.autoFocus,
    this.keyboardType,
    this.textInputAction,
    this.obscureText,
    this.obscuringCharacter,
    this.showPasswordIcon,
    this.textCapitalization,
    this.hintStyle,
    this.inputStyle,
    this.textAlign,
    this.dialogPadding,
  }) : super(key: key);

  final Widget title;
  final dialogPadding;
  final Widget textOK;
  final Widget textCancel;
  final String initialValue;
  final bool isSelectedInitialValue;
  final String hintText;
  final String Function(String) validator;
  final int minLines;
  final int maxLines;
  final bool autoFocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final String obscuringCharacter;
  final bool showPasswordIcon;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle hintStyle;
  final TextStyle inputStyle;

  @override
  __PromptDialogState createState() => __PromptDialogState();
}

class __PromptDialogState extends State<_PromptDialog> {
  TextEditingController controller;
  bool stateObscureText = false;

  String value;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, null);
        return true;
      },
      child: AlertDialog(
        title: widget.title,
        contentPadding:
            widget.dialogPadding ?? EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        content: Form(
          key: _formKey,
          child: TextFormField(
            style: widget.inputStyle,
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              // NumberInputFormatter(),
            ],
            decoration: InputDecoration(
              hintStyle: widget.hintStyle,
              hintText: widget.hintText,
              prefixText: 'TSh ',
              prefixStyle: TextStyle(textBaseline: TextBaseline.alphabetic),
              suffixText: '/=',
              suffixStyle: TextStyle(textBaseline: TextBaseline.alphabetic),
              labelStyle: TextStyle(fontSize: 15),
              suffixIcon: widget.showPasswordIcon
                  ? IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: stateObscureText ? Colors.grey : Colors.blueGrey,
                      ),
                      onPressed: () {
                        stateObscureText = stateObscureText;
                        setState(() {
                          controller.selection = TextSelection.fromPosition(
                            const TextPosition(offset: 0),
                          );
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                        });
                      },
                    )
                  : null,
            ),
            validator: widget.validator,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            autofocus: widget.autoFocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: (String text) => value = text,
            obscureText: stateObscureText,
            obscuringCharacter: widget.obscuringCharacter,
            textCapitalization: widget.textCapitalization,
            onEditingComplete: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context, value);
              }
            },
            textAlign: widget.textAlign,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: (widget.textCancel != null)
                ? widget.textCancel
                : const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context, value);
              }
            },
            child: (widget.textOK != null) ? widget.textOK : const Text('OK'),
          ),
        ],
      ),
    );
  }
}
