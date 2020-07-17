import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final bool isChecked;
  final bool visibleSwitch;
  CustomCheckBox({Key key, this.isChecked, this.visibleSwitch})
      : super(key: key);

  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  ValueNotifier<bool> isChecked = ValueNotifier(false);
  ValueNotifier<bool> visibleSwitch = ValueNotifier(false);
  @override
  void initState() {
    isChecked.value = widget.isChecked ;
    visibleSwitch.value = widget.visibleSwitch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isChecked != null
        ? ValueListenableBuilder<bool>(
            valueListenable: isChecked,
            builder: (context, value, child) {
              return Checkbox(
                value: value,
                onChanged: (val) {
                  isChecked.value = val;
                },
              );
            },
          )
        : widget.visibleSwitch == null
            ? SizedBox(height: 10, width:10,)
            : ValueListenableBuilder(
                valueListenable: visibleSwitch,
                builder: (context, value, child) {
                  return Switch(
                    onChanged: (val) {
                      visibleSwitch.value = val;
                    },
                    value: value,
                  );
                },
              );
  }
}
