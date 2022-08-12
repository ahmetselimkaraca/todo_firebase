import 'package:flutter/material.dart';

class ColorOptions extends StatelessWidget {
  final Function changeThemeColor;
  ColorOptions(this.changeThemeColor, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget colorBar(String colorString) {
      MaterialColor color;

      switch (colorString) {
        case 'Yellow':
          color = Colors.yellow;
          break;
        case 'Orange':
          color = Colors.orange;
          break;
        case 'Red':
          color = Colors.red;
          break;
        case 'Pink':
          color = Colors.pink;
          break;
        case 'Purple':
          color = Colors.deepPurple;
          break;
        case 'Indigo':
          color = Colors.indigo;
          break;
        case 'Blue':
          color = Colors.blue;
          break;
        case 'Cyan':
          color = Colors.cyan;
          break;
        case 'Green':
          color = Colors.green;
          break;

        case 'Grey':
          color = Colors.grey;
          break;
      }
      return InkWell(
        onTap: () {
          Navigator.pop(context);
          changeThemeColor(colorString);
        },
        splashColor: color.withAlpha(31),
        highlightColor: color.withAlpha(31),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: 100,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                colorString,
                style: TextStyle(
                  color: color.shade700,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: 10,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.shade700,
                      color.withAlpha(63),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        colorBar('Yellow'),
        colorBar('Orange'),
        colorBar('Red'),
        colorBar('Pink'),
        colorBar('Purple'),
        colorBar('Indigo'),
        colorBar('Blue'),
        colorBar('Cyan'),
        colorBar('Green'),
        colorBar('Grey'),
      ],
    );
  }
}
