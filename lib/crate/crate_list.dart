import 'package:flutter/material.dart';
import 'package:automator/misc.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/day_night_gradients.dart';

class AllCrateStatefulWidget extends StatefulWidget {
  AllCrateStatefulWidget({Key key}) : super(key: key);

  @override
  AllCrateStatefulWidgetState createState() => AllCrateStatefulWidgetState();
}

class AllCrateStatefulWidgetState extends State<AllCrateStatefulWidget> {
  ScrollController controller;
  final _allCrateRecords = <Record>[];
  bool failed = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  double scrollExtent = 0;

  @override
  void initState() {
    super.initState();
    startLoader();
    controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _scrollListener() {
    if (scrollExtent == 0) {
      scrollExtent = controller.position.maxScrollExtent;
    }
    if (!failed &&
        (controller.position.pixels + (scrollExtent / 2)) >=
            controller.position.maxScrollExtent) {
      startLoader();
    }
  }

  startLoader() {
    print('StartLoader, loading: $isLoading');
    if (failed || isLoading) return;
    setState(() {
      isLoading = true;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print('_loadData');
    var records;
    try {
      records = await ApiService.getCrateRecords(
          offset: _allCrateRecords.length, limit: 10);
    } catch (e) {
      print('Error');
      setState(() {
        failed = true;
      });
    }
    if (!failed) {
      setState(() {
        isLoading = false;
        _allCrateRecords.addAll(records);
        _allCrateRecords.sort((a, b) => b.id.compareTo(a.id));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: failed
            ? IconTextWidget(
                Icons.clear,
                'There is no records in crate',
                textSize: 24,
                iconColor: Theme.of(context).errorColor,
              )
            : Stack(
                children: <Widget>[
                  _buildSuggestions(),
                ],
              ));
  }

  Widget _buildRow(Record record) {
    final int hour = record.creationDate.hour % 24;
    final bool isDay = hour > 10 && hour < 16;
    return Container(
        decoration: BoxDecoration(gradient: dayNightGradient[hour]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(
                record.note,
                style: TextStyle(
                    fontSize: 18.0, color: isDay ? Colors.white : Colors.white),
              ),
              subtitle: Text(
                userDateTimeFormat.format(record.creationDate),
                style: TextStyle(
                    fontSize: 12.0,
                    color: isDay ? Colors.white70 : Colors.white70),
              ),
              onTap: () {
                //TODO: open details
              },
            ),
            Divider(),
          ],
        ));
  }

  Future<void> _refresh() async {
    setState(() {
      _allCrateRecords.clear();
      isLoading = false;
      startLoader();
    });
  }

  Widget _buildSuggestions() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
            padding: const EdgeInsets.all(0),
            // The itemBuilder callback is called once per suggested word pairing,
            // and places each suggestion into a ListTile row.
            // For even rows, the function adds a ListTile row for the word pairing.
            // For odd rows, the function adds a Divider widget to visually
            // separate the entries. Note that the divider may be difficult
            // to see on smaller devices.
            controller: controller,
            itemCount: _allCrateRecords.length + 1,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              var s = _allCrateRecords.length;
              print('Building $i from $s');
              // Add a one-pixel-high divider widget before each row in theListView.
              // if (i == _allCrateRecords.length && !isLoading) {
              //   _checkForALater();
              // }
              return i < _allCrateRecords.length
                  ? _buildRow(_allCrateRecords[i])
                  : _loader();
            }));
  }

  Widget _loader() {
    return isLoading
        ? Align(
            child: Container(
              width: 70.0,
              height: 70.0,
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(child: CircularProgressIndicator())),
            ),
            alignment: FractionalOffset.bottomCenter,
          )
        : SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }

  Future<bool> isLastElemLoaded() async {
    if (isLoading) return true;
    if (_allCrateRecords.length == 0) return false;
    var list = (await ApiService.getCrateRecords(
        offset: _allCrateRecords.length, limit: 1));
    if (list.length == 0) return true;
    var last = list.elementAt(0);
    return last.id == _allCrateRecords[0].id ||
        last.id == _allCrateRecords[_allCrateRecords.length - 1].id;
  }

  Future<bool> hasNewElements() async {
    if (isLoading) return false;
    if (_allCrateRecords.length == 0) return true;
    var first =
        (await ApiService.getCrateRecords(offset: 0, limit: 1)).elementAt(0);
    return first.id != _allCrateRecords[0].id &&
        first.id != _allCrateRecords[_allCrateRecords.length - 1].id;
  }
}
