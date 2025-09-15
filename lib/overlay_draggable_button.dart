import 'package:flutter/material.dart';
import 'dio_log_sds.dart';

OverlayEntry? itemEntry;

showDebugBtn(BuildContext context, {Widget? button, Color? btnColor}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    dismissDebugBtn();
    itemEntry = OverlayEntry(
        builder: (BuildContext context) =>
            button ?? DraggableButtonWidget(btnColor: btnColor));

    Overlay.of(context).insert(itemEntry!);
  });
}

dismissDebugBtn() {
  try {
    itemEntry?.remove();
    itemEntry = null;
  } catch (ex) {}
}

bool debugBtnIsShow() {
  return !(itemEntry == null);
}

class DraggableButtonWidget extends StatefulWidget {
  final String title;
  final Function? onTap;
  final double btnSize;
  final Color? btnColor;

  const DraggableButtonWidget({
    super.key,
    this.title = 'Show log',
    this.onTap,
    this.btnSize = 66,
    this.btnColor,
  });

  @override
  _DraggableButtonWidgetState createState() => _DraggableButtonWidgetState();
}

class _DraggableButtonWidgetState extends State<DraggableButtonWidget> {
  double left = 30;
  double top = 100;
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    tap() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const HttpLogListWidget(hint: "All http requests from dio"),
        ),
      );
    }

    Widget w;
    Color primaryColor =
        widget.btnColor ?? Colors.redAccent; // Theme.of(context).primaryColor;
    // primaryColor = primaryColor.withOpacity(0.6);
    w = GestureDetector(
      onTap: widget.onTap as void Function()? ?? tap,
      onPanUpdate: _dragUpdate,
      child: Container(
        width: widget.btnSize,
        height: widget.btnSize,
        color: primaryColor,
        child: Center(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );

    w = ClipRRect(
      borderRadius: BorderRadius.circular(widget.btnSize / 2),
      child: w,
    );

    if (left < 1) {
      left = 1;
    }
    if (left > screenWidth - widget.btnSize) {
      left = screenWidth - widget.btnSize;
    }

    if (top < 1) {
      top = 1;
    }
    if (top > screenHeight - widget.btnSize) {
      top = screenHeight - widget.btnSize;
    }
    w = Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: left, top: top),
      child: w,
    );
    return w;
  }

  _dragUpdate(DragUpdateDetails detail) {
    Offset offset = detail.delta;
    left = left + offset.dx;
    top = top + offset.dy;
    setState(() {});
  }
}
