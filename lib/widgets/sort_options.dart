import 'package:flutter/material.dart';

class SortOptions extends StatelessWidget {
  final Function changeSortKey;
  SortOptions(this.changeSortKey, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget sortBar(String sortString) {
      String sortText;

      switch (sortString) {
        case 'dueDate':
          sortText = 'Sort by date due';
          break;
        case 'id':
          sortText = 'Sort by date created';
          break;
        case 'desc':
          sortText = 'Sort alphabetically';
          break;
      }
      return InkWell(
        onTap: () {
          Navigator.pop(context);
          changeSortKey(sortString);
        },
        splashColor: Theme.of(context).secondaryHeaderColor,
        highlightColor: Theme.of(context).secondaryHeaderColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: 150,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              child: Text(
                sortText,
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Icon(
              sortString == 'desc' ? Icons.abc : Icons.date_range,
              size: sortString == 'desc' ? 25 : 15,
            )
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sortBar('dueDate'),
        sortBar('id'),
        sortBar('desc'),
      ],
    );
  }
}
