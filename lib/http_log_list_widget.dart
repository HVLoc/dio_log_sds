import 'dart:collection';

import 'package:dio_log_sds/theme/style.dart';
import 'package:flutter/material.dart';

import 'bean/net_options.dart';
import 'dio_log_sds.dart';
import 'page/log_widget.dart';

class HttpLogListWidget extends StatefulWidget {
  const HttpLogListWidget({this.hint, super.key});

  final String? hint;

  @override
  _HttpLogListWidgetState createState() => _HttpLogListWidgetState();
}

class _HttpLogListWidgetState extends State<HttpLogListWidget> {
  LinkedHashMap<String, NetOptions>? logMap;
  List<String>? keys;

  @override
  void initState() {
    super.initState();

    showDebugBtn(context);
  }

  @override
  Widget build(BuildContext context) {
    logMap = LogPoolManager.getInstance().logMap;
    keys = LogPoolManager.getInstance().keys;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Logs',
          style: theme.textTheme.headlineSmall,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1.0,
        iconTheme: theme.iconTheme.copyWith(color: Colors.black87),
        actions: <Widget>[
          InkWell(
            onTap: _updateOverlayState,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                child: Text(
                  debugBtnIsShow() ? 'Close overlay' : 'Open overlay',
                  style: theme.textTheme.labelLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _clearLog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                child: Text(
                  'Clear',
                  style: theme.textTheme.labelLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: logMap!.isEmpty
          ? const Center(child: Text('No request log'))
          : Column(
              children: [
                if (widget.hint != null && widget.hint!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.hint!,
                      textAlign: TextAlign.center,
                      style: Style.defText.copyWith(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    reverse: false,
                    itemCount: keys!.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _LogItem(item: logMap![keys![index]]!),
                  ),
                )
              ],
            ),
    );
  }

  void _updateOverlayState() {
    if (debugBtnIsShow()) {
      dismissDebugBtn();
    } else {
      showDebugBtn(context);
    }
    setState(() {});
  }

  void _clearLog() {
    LogPoolManager.getInstance().clear();
    setState(() {});
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({required this.item});

  final NetOptions item;

  @override
  Widget build(BuildContext context) {
    var resOpt = item.resOptions;
    var reqOpt = item.reqOptions!;

    var requestTime = getTimeStr1(reqOpt.requestTime!);

    Color? textColor = (item.errOptions != null || resOpt?.statusCode == null)
        ? Colors.red
        : Theme.of(context).textTheme.bodyLarge!.color;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LogWidget(item)));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${reqOpt.url}', style: Style.defText),
              const SizedBox(height: 8),
              Text(
                '${reqOpt.method}: ${resOpt?.statusCode}',
                style: Style.defTextBold.copyWith(
                  color: (resOpt?.statusCode ?? 0) == 200
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'requestTime: $requestTime    duration: ${resOpt?.duration ?? 0} ms',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
