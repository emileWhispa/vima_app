
import 'package:flutter/cupertino.dart';

class StatefulBuilder2 extends StatefulWidget {
  /// Creates a widget that both has state and delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const StatefulBuilder2({
    Key? key,
    required this.builder,
  })  : super(key: key);

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a tree of widgets and so a Builder child will not be [identical]
  /// to the corresponding old one.
  final StatefulWidgetBuilder builder;

  @override
  StatefulBuilderState2 createState() => StatefulBuilderState2();
}

class StatefulBuilderState2 extends State<StatefulBuilder2> {
  void refresh() {
    setState(() {});
  }

  void pop() {
    Navigator.pop(context);
  }

  void specialPop() {

    if(ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pop(context);
    }else{
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, setState);
}
