import 'package:flutter/material.dart';

class EndlessListStatefulWidget<T> extends StatefulWidget {
  final Function _elementConstructor;
  final Function _itemConstructor;

  EndlessListStatefulWidget(this._elementConstructor, this._itemConstructor,
      {Key key})
      : super(key: key);

  @override
  State createState() =>
      EndlessListStatefulWidgetState<T>(_elementConstructor, _itemConstructor);
}

enum _State { idle, loading, failed }

typedef _ElementBuilder<T> = Future<Set<T>> Function(int alreadyDisplayed);
typedef _ItemBuilder<T> = Widget Function(BuildContext context, T element);

class EndlessListStatefulWidgetState<T>
    extends State<EndlessListStatefulWidget> {
  /// (already) async => load(offset:already, size:S)
  /// <T>[S]
  final _ElementBuilder<T> _elementConstructor;

  /// (context, T element) => Widget
  final _ItemBuilder<T> _itemConstructor;
  final _all = <T>[];

  _State _state = _State.idle;
  ScrollController _scrollController;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  EndlessListStatefulWidgetState(
      this._elementConstructor, this._itemConstructor);

  @override
  initState() {
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadData();
  }

  @override
  dispose() {
    _scrollController.dispose();
  }

  _scrollListener() {
    if (_state == _State.idle && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadData();
    }
  }

  Future<void> _refresh() async {
    _all.clear();
    _loadData();
  }

  _loadData() async {
    setState(() {
      _state = _State.loading;
    });
    var dat;
    try {
      dat = await _elementConstructor(_all.length);
    } catch (e) {
      setState(() {
        _state = _State.failed;
      });
    }
    if (_state != _State.failed) {
      setState(() {
        _all.addAll(dat);
        _state = _State.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      Container(child: _all.length != 0 ? _buildList() : Text('Wow, such empty'));

  _buildList() => RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _all.length + 1,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) => i < _all.length
                ? _itemConstructor(context, _all[i])
                : ((_state == _State.loading)
                    ? _loaderWidget()
                    : const SizedBox(height: 4, width: 0))),
      );

  Widget _loaderWidget() => Align(
        child: Container(
          width: 70.0,
          height: 70.0,
          child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(child: CircularProgressIndicator())),
        ),
        alignment: FractionalOffset.bottomCenter,
      );
}
