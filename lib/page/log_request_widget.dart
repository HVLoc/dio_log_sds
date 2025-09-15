import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_log_sds/bean/net_options.dart';
import 'package:dio_log_sds/bean/req_options.dart';
import 'package:flutter/material.dart';

import '../dio_log_sds.dart';

class LogRequestWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogRequestWidget(this.netOptions, {super.key});

  @override
  _LogRequestWidgetState createState() => _LogRequestWidgetState();
}

class _LogRequestWidgetState extends State<LogRequestWidget>
    with AutomaticKeepAliveClientMixin {
  bool reqFail = false;
  double fontSize = 14;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var reqOpt = widget.netOptions.reqOptions!;
    var resOpt = widget.netOptions.resOptions;

    ///格式化请求时间
    var requestTime = getTimeStr(reqOpt.requestTime!);

    ///格式化返回时间
    var responseTime = getTimeStr(resOpt?.responseTime ?? reqOpt.requestTime!);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 10),
                const Text('Slider Fontsize'),
                Expanded(
                  child: Slider(
                    value: fontSize,
                    max: 30,
                    min: 1,
                    onChanged: (v) {
                      fontSize = v;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const Text(
              'Tip: long press a key to copy the value to the clipboard',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(
                          context,
                          'url:${reqOpt.url}\nmethod:${reqOpt.method}\nrequestTime:$requestTime\nresponseTime:$responseTime\n'
                          'duration:${resOpt?.duration ?? 0}ms\n${dataFormat(reqOpt.data)}'
                          '\nparams:${toJson(reqOpt.params)}\nheader:${reqOpt.headers}');
                    },
                    child: const Text('copy all'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(context, '${reqOpt.url}');
                    },
                    child: const Text(
                      'copy url',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(context, convertcURL(reqOpt));
                    },
                    child: const Text(
                      'copy cURL',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(context, '${reqOpt.headers}');
                    },
                    child: const Text(
                      'copy Headers',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(context, '${toJson(reqOpt.data)}');
                    },
                    child: const Text('copy Body'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      copyClipboard(context, '${toJson(reqOpt.params)}');
                    },
                    child: const Text('copy params'),
                  ),
                ),
              ],
            ),
            _buildKeyValue('url', reqOpt.url),
            _buildKeyValue('Method', reqOpt.method),
            _buildKeyValue('RequestTime', requestTime),
            _buildKeyValue('ResponseTime', responseTime),
            _buildKeyValue('Duration', '${resOpt?.duration ?? 0}ms'),
            _buildParam(reqOpt.data),
            _buildJsonView('Params', reqOpt.params),
            _buildJsonView('Headers', reqOpt.headers),
          ],
        ),
      ),
    );
  }

  ///构建json树的展示
  Widget _buildJsonView(key, json) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _getDefText('$key:'),
        JsonView(
          json: json,
          fontSize: fontSize,
        ),
      ],
    );
  }

  ///构建子节点的展示
  Widget _buildKeyValue(k, v) {
    Widget w = _getDefText('$k:${v is String ? v : v?.toString()}');
    if (k != null) {
      w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          copyClipboard(context, v);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: w,
        ),
      );
    }
    return w;
  }

  ///默认的文本大小
  Widget _getDefText(String str) {
    return Text(
      str,
      style: TextStyle(fontSize: fontSize),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Map? formDataMap;
  Widget _buildParam(dynamic data) {
    if (data is Map || data is List) {
      return _buildJsonView('body', data);
    } else if (data is FormData) {
      formDataMap = {}
        ..addEntries(data.fields)
        ..addEntries(data.files);
      return _getDefText('formData:${map2Json(formDataMap)}');
    } else if (data is String) {
      try {
        var decodedMap = json.decode(data);
        return _buildJsonView('body', decodedMap);
      } catch (e) {
        return Text('body: $data');
      }
    } else {
      return const SizedBox();
    }
  }

  String dataFormat(dynamic data) {
    if (data is FormData) {
      return 'formData:${map2Json(formDataMap)}';
    } else {
      return 'body:${toJson(data)}';
    }
  }

  String convertcURL(ReqOptions reqOptions) {
    try {
      String method = '--request ${reqOptions.method}';
      String url = 'curl --location $method ${reqOptions.url}';

      String header = '';
      if (reqOptions.headers != null) {
        reqOptions.headers!.forEach((key, value) {
          if (value != '') header += "--header '$key:$value' \\ \n ";
        });
      }

      String data =
          reqOptions.data != null ? "--data-raw '${toJson(reqOptions.data)}'" : "";
      String result = '$url  \n $header \n $data';
      print(result);
      return result;
    } catch (e) {
      return "";
    }
  }
}
