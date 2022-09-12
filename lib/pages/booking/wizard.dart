import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// CoolStepper
class BookingWizard extends StatefulWidget {
  /// The steps of the stepper whose titles, subtitles, content always get shown.
  ///
  /// The length of [steps] must not change.
  final List<WizardStep> steps;

  /// Actions to take when the final stepper is passed
  final VoidCallback onCompleted;

  /// Padding for the content inside the stepper
  final EdgeInsetsGeometry contentPadding;

  /// CoolStepper config
  final CoolStepperConfig config;

  /// This determines if or not a snackbar displays your error message if validation fails
  ///
  /// default is false
  final bool showErrorSnackbar;

  const BookingWizard({
    Key key,
    this.steps,
    this.onCompleted,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.config = const CoolStepperConfig(),
    this.showErrorSnackbar = false,
  }) : super(key: key);

  @override
  _CoolStepperState createState() => _CoolStepperState();
}

class _CoolStepperState extends State<BookingWizard> {
  PageController _controller = PageController();

  int currentStep = 0;

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> switchToPage(int page) async {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  void onStepNext() {
    final validation = widget.steps[currentStep].validation();

    /// [validation] is null, no validation rule
    if (validation == null) {
      if (!_isLast(currentStep)) {
        setState(() {
          currentStep++;
        });
        FocusScope.of(context).unfocus();
        switchToPage(currentStep);
      } else {
        widget.onCompleted();
      }
    } else {
      /// [showErrorSnackbar] is true, Show error snackbar rule
      if (widget.showErrorSnackbar) {
        final flush = Flushbar(
          message: validation,
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: EdgeInsets.all(8.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          icon: Icon(
            Icons.info_outline,
            size: 28.0,
            color: Theme.of(context).primaryColor,
          ),
          duration: Duration(seconds: 2),
          leftBarIndicatorColor: Theme.of(context).primaryColor,
        );
        flush.show(context);

        // final snackBar = SnackBar(content: Text(validation));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void onStepBack() {
    if (!_isFirst(currentStep)) {
      setState(() {
        currentStep--;
      });
      switchToPage(currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: widget.steps.map((step) {
          return WizardView(
            step: step,
            contentPadding: widget.contentPadding,
            config: widget.config,
          );
        }).toList(),
      ),
    );

    final counter = Container(
      child: Text(
        "${widget.config.stepText ?? 'STEP'} ${currentStep + 1} ${widget.config.ofText ?? 'OF'} ${widget.steps.length}",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );

    String getNextLabel() {
      String nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = widget.config.finalText ?? 'FINISH ';
      } else {
        if (widget.config.nextTextList != null) {
          nextLabel = widget.config.nextTextList[currentStep];
        } else {
          nextLabel = widget.config.nextText ?? 'NEXT ';
        }
      }
      return nextLabel;
    }

    String getPrevLabel() {
      String backLabel;
      if (_isFirst(currentStep)) {
        backLabel = '';
      } else {
        if (widget.config.backTextList != null) {
          backLabel = widget.config.backTextList[currentStep - 1];
        } else {
          backLabel = widget.config.backText ?? 'PREV ';
        }
      }
      return backLabel;
    }

    final buttons = Material(
        elevation: 20,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(193, 192, 192, 1.0), //New
                  blurRadius: 10.0,
                  offset: Offset(0, -1))
            ],
          ),
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: onStepBack,
                child: Text(
                  getPrevLabel(),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600),
                ),
              ),
              counter,
              TextButton(
                onPressed: onStepNext,
                child: Text(
                  getNextLabel(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ));

    return Container(
      child: Column(
        children: [content, buttons],
      ),
    );
  }
}

class WizardStep {
  final String title;
  final String subtitle;
  final String backText;
  final String nextText;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String Function() validation;
  final bool isHeaderEnabled;

  WizardStep(
      {this.title,
      this.subtitle,
      this.backText,
      this.nextText,
      this.content,
      this.onNext,
      this.onBack,
      this.validation,
      this.isHeaderEnabled = true});
}

class CoolStepperConfig {
  /// The text that should be displayed for the back button
  ///
  /// default is 'BACK'
  final String backText;

  /// The text that should be displayed for the next button
  ///
  /// default is 'NEXT'
  final String nextText;

  /// The text that describes the progress
  ///
  /// default is 'STEP'
  final String stepText;

  /// The text that describes the progress
  ///
  /// default is 'OF'
  final String ofText;

  /// This is the background color of the header
  final Color headerColor;

  /// This is the color of the icon
  ///
  /// [This does not apply when icon is set]
  final Color iconColor;

  /// This icon replaces the default icon
  final Icon icon;

  /// This is the textStyle for the title text
  final TextStyle titleTextStyle;

  /// This is the textStyle for the subtitle text
  final TextStyle subtitleTextStyle;

  /// A List of string that when supplied will override 'backText'
  ///
  /// Must be one less than the number of steps since for the first step, the backText won't be visible
  final List<String> backTextList;

  /// A List of string that when supplied will override 'nextText'
  ///
  /// Must be one less than the number of steps since the 'finalText' attribute is able to set the value for the final step's next button
  final List<String> nextTextList;

  /// The text that should be displayed for the next button on the final step
  ///
  /// default is 'FINISH'
  final String finalText;

  final bool isHeaderEnabled;

  const CoolStepperConfig({
    this.backText = 'PRE',
    this.nextText = 'NEXT',
    this.stepText = 'STEP',
    this.ofText = 'OF',
    this.headerColor,
    this.iconColor,
    this.icon,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.backTextList,
    this.nextTextList,
    this.finalText = 'FINISH',
    this.isHeaderEnabled = true,
  });
}

class WizardView extends StatelessWidget {
  final WizardStep step;
  final VoidCallback onStepNext;
  final VoidCallback onStepBack;
  final EdgeInsetsGeometry contentPadding;
  final CoolStepperConfig config;

  const WizardView({
    Key key,
    this.step,
    this.onStepNext,
    this.onStepBack,
    this.contentPadding,
    this.config,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final title = config.isHeaderEnabled && step.isHeaderEnabled
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 0.0),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: config.headerColor ??
                  Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          step.title.toUpperCase(),
                          style: config.titleTextStyle ??
                              TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black38,
                              ),
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Visibility(
                        visible: config.icon == null,
                        replacement: config.icon ?? SizedBox(),
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: config.iconColor ?? Colors.black38,
                        ),
                      )
                    ]),
                SizedBox(height: 5.0),
                Text(
                  step.subtitle,
                  style: config.subtitleTextStyle ??
                      TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          )
        : SizedBox();

    final content = Expanded(
      child: SingleChildScrollView(
        //  padding: contentPadding,
        child: step.content,
      ),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, content],
      ),
    );
  }
}
