import 'package:flutter/material.dart';

abstract class WidgetView<T1, T2> extends StatelessWidget {
  const WidgetView(this.state, {Key? key}) : super(key: key);

  final T2 state;

  T1 get widget => (state as State).widget as T1;

  @override
  Widget build(BuildContext context);
}
