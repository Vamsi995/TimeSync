import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TSText extends StatelessWidget {
  final String text;

  TSText({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
          fontSize: 25,
          color: Colors.black,
      ),
    );
  }
}

class ButtonCard extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPress;

  ButtonCard({@required this.text, @required this.color, this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: TSText(
          text: this.text,
        ),
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: this.onPress,
    );
  }
}

class TSCard extends StatelessWidget {
  final String text;
  final Color color;
  final double padding;

  TSCard({@required this.text, @required this.color, this.padding = 10.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: TSText(
          text: text,
        ),
      ),
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(this.padding),
      decoration: BoxDecoration(
        color: this.color,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

class TSShow extends StatelessWidget {

  final String text;
  final String value;

  TSShow({@required this.text, @required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          this.text,
          style: TextStyle(color: Color(0xFFB4C1CA)),
        ),
        Text(
          this.value,
          style: TextStyle(
              color: Color(0xFF70D4FF), fontSize: 25),
        ),
      ],
    );
  }
}


class BeautyTextfield extends StatefulWidget {
  final BorderRadius cornerRadius;
  final double width, height, wordSpacing;
  final Color backgroundColor, accentColor, textColor, cursorColor, iconColor;
  final String placeholder, fontFamily;
  final Icon prefixIcon, suffixIcon;
  final TextInputType inputType;
  final EdgeInsets margin;
  final Duration duration;
  final VoidCallback onClickSuffix;
  final TextBaseline textBaseline;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final bool autofocus, autocorrect, enabled, obscureText, isShadow, readOnly;
  final FocusNode focusNode;
  final int maxLength, minLines, maxLines;
  final ValueChanged<String> onChanged, onSubmitted;
  final GestureTapCallback onTap;
  final TextEditingController controller;

  const BeautyTextfield(
      {this.height = 50,
      @required this.prefixIcon,
      this.inputType = TextInputType.text,
      this.width = 300,
      this.controller,
      this.suffixIcon,
      this.duration = const Duration(milliseconds: 200),
      this.margin = const EdgeInsets.all(10),
      this.obscureText = false,
      this.backgroundColor = Colors.lightBlue,
      this.cornerRadius = const BorderRadius.all(Radius.circular(10)),
      this.textColor = Colors.white,
      this.accentColor = Colors.lightBlue,
      this.cursorColor = Colors.black,
      this.iconColor = Colors.white,
      this.placeholder = "",
      this.isShadow = true,
      this.readOnly = false,
      this.onClickSuffix,
      this.wordSpacing,
      this.textBaseline,
      this.fontFamily,
      this.fontStyle,
      this.fontWeight,
      this.autofocus = false,
      this.autocorrect = false,
      this.focusNode,
      this.enabled = true,
      this.maxLength,
      this.maxLines,
      this.minLines,
      this.onChanged,
      this.onTap,
      this.onSubmitted})
      : assert(width != null),
        assert(height != null),
        assert(prefixIcon != null),
        assert(inputType != null);

  @override
  _BeautyTextfieldState createState() => _BeautyTextfieldState();
}

class _BeautyTextfieldState extends State<BeautyTextfield> {
  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
          boxShadow: widget.isShadow
              ? [BoxShadow(color: Colors.grey, blurRadius: 2, spreadRadius: 1)]
              : BoxShadow(spreadRadius: 0, blurRadius: 0),
          borderRadius: widget.cornerRadius,
          color: widget.suffixIcon == null
              ? isFocus ? widget.accentColor : widget.backgroundColor
              : widget.backgroundColor),
      child: Stack(
        children: <Widget>[
          widget.suffixIcon == null
              ? Container()
              : Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedContainer(
                    width: isFocus ? 500 : 40,
                    height: isFocus ? widget.height : 40,
                    margin: EdgeInsets.only(right: isFocus ? 0 : 7),
                    duration: widget.duration,
                    decoration: BoxDecoration(
                      borderRadius: isFocus ? widget.cornerRadius : BorderRadius.all(Radius.circular(60)),
                      color: widget.accentColor,
                    ),
                  ),
                ),
          widget.suffixIcon == null
              ? Container()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      isFocus ? isFocus = false : isFocus = true;
                      if (widget.onClickSuffix != null) {
                        widget.onClickSuffix();
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 15),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      widget.suffixIcon.icon,
                      color: widget.textColor,
                    ),
                  ),
                ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(
                    widget.prefixIcon.icon,
                    color: widget.iconColor,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: EdgeInsets.only(right: 50, top: 3),
                    child: TextField(
                      controller: widget.controller,
                      cursorWidth: 2,
                      cursorRadius: Radius.circular(2),
                      obscureText: widget.obscureText,
                      keyboardType: widget.inputType,
                      readOnly: widget.readOnly,
                      style: TextStyle(
                        fontFamily: widget.fontFamily,
                        fontStyle: widget.fontStyle,
                        fontWeight: widget.fontWeight,
                        wordSpacing: widget.wordSpacing,
                        textBaseline: widget.textBaseline,
                        fontSize: 18,
                        letterSpacing: 2,
                        color: widget.textColor,
                      ),
                      autofocus: widget.autofocus,
                      autocorrect: widget.autocorrect,
                      focusNode: widget.focusNode,
                      enabled: widget.enabled,
                      maxLength: widget.maxLength,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      onChanged: widget.onChanged,
                      onTap: () {
                        setState(() {
                          isFocus = true;
                        });
                        if (widget.onTap != null) {
                          widget.onTap();
                        }
                      },
                      onSubmitted: (t) {
                        setState(() {
                          isFocus = false;
                        });
                        widget.onSubmitted(t);
                      },
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: widget.textColor),
                          hintText: widget.placeholder,
                          border: InputBorder.none),
                      cursorColor: widget.cursorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: widget.duration,
    );
  }
}
