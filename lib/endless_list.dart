import 'package:flutter/material.dart';
import 'package:automator/misc.dart';

enum _State { idle, loading, failed, done }

typedef _ElementBuilder<T> = Future<Set<T>> Function(int alreadyDisplayed);
typedef _ItemBuilder<T> = Widget Function(BuildContext context, T element);

class EndlessListStatefulWidget<T> extends StatefulWidget {
  /// (already) async => load(offset:already, size:S)
  /// <T>[S]
  final _ElementBuilder<T> _elementConstructor;

  /// (context, T element) => Widget
  final _ItemBuilder<T> _itemConstructor;

  final Widget _emptyWidget;

  EndlessListStatefulWidget(this._elementConstructor, this._itemConstructor,
      [this._emptyWidget = const SizedBox(width: 0, height: 0), Key key])
      : super(key: key);

  @override
  State createState() => EndlessListStatefulWidgetState<T>(
      _elementConstructor, _itemConstructor, _emptyWidget);
}

class EndlessListStatefulWidgetState<T>
    extends State<EndlessListStatefulWidget> {
  /// (already) async => load(offset:already, size:S)
  /// <T>[S]
  final _ElementBuilder<T> _elementConstructor;

  /// (context, T element) => Widget
  final _ItemBuilder<T> _itemConstructor;

  final Widget _emptyWidget;

  final _all = <T>[];

  double _screenExtent = 0;

  _State _state = _State.idle;
  ScrollController _scrollController;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  EndlessListStatefulWidgetState(
      this._elementConstructor, this._itemConstructor, this._emptyWidget);

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadData();
  }

  @override
  dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  _scrollListener() {
    print(
        'SCROLL ${_scrollController.position.pixels} ${_scrollController.position.maxScrollExtent} ${_scrollController.offset}');
    if (_screenExtent == 0 && _scrollController.position.pixels == 0) {
      _screenExtent = _scrollController.position.maxScrollExtent;
      _loadData();
    } else if (_state == _State.idle &&
        ((_scrollController.position.pixels + (_screenExtent * 2)) >=
                _scrollController.position.maxScrollExtent ||
            (_scrollController.position.maxScrollExtent ==
                    _scrollController.position.pixels &&
                _state == _State.idle))) {
      _loadData();
    }
  }

  Future<void> _refresh() async {
    _all.clear();
    _state = _State.idle;
    _loadData();
  }

  _loadData() async {
    if (_state == _State.done) return;
    setState(() {
      _state = _State.loading;
    });
    Set<T> dat;
    try {
      dat = await _elementConstructor(_all.length);
    } catch (e) {
      setState(() {
        _state = _State.failed;
      });
    }
    if (_state != _State.failed) {
      setState(() {
        if (dat.length != 0) {
          for (var i in dat) {
            if (!_all.contains(i)) {
              _all.add(i);
            }
          }
          _state = _State.idle;
        } else
          _state = _State.done;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
      child: _all.length != 0
          ? _buildList()
          : (_state == _State.done
              ? Column(
                  children: [
                    _emptyWidget,
                    Container(
                        width: double.infinity,
                        child: Center(
                            child: RaisedButton(
                          child: Padding(
                              child: Text(
                                'Refresh',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              ),
                              padding: EdgeInsets.all(16)),
                          color: Theme.of(context).accentColor,
                          onPressed: _refresh,
                        )))
                  ],
                )
              : const SizedBox()));

  _buildList() => RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _all.length + 1,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              if (i >= _all.length &&
                  _state != _State.loading &&
                  _state != _State.done) {
                () async {
                  await sleep1();
                  _loadData();
                }();
                return _loaderWidget();
              } else
                return i < _all.length
                    ? _itemConstructor(context, _all[i])
                    : ((_state == _State.loading)
                        ? _loaderWidget()
                        : const SizedBox(height: 4, width: 0));
            }),
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

  get all => _all;
}
