import 'package:flutter/material.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;

class ButtonApp extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final IconData icon;
  final Function onPressed;

  const ButtonApp({
    Key? key,
    this.color = Colors.red,
    this.textColor = Colors.white,
    this.icon = Icons.arrow_forward_ios,
    required this.onPressed,
    required this.text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final elevatedButtonStyle = ElevatedButton.styleFrom(
        primary: color,
        onPrimary: textColor
    );

    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: elevatedButtonStyle,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 50,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(icon, color: utils.Colors.uberCloneColor),
              ),
            ),
          )
        ],
      ),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
