import 'package:flutter/material.dart';
import 'package:morpheus/morpheus.dart';

import 'package:automator/day_night_gradients.dart';

export 'crate_sort.dart';
export 'crate_list.dart';
export 'crate_add.dart';

import 'crate_sort.dart';
import 'crate_list.dart';
import 'crate_add.dart';

const icon = Icons.apps;
const title = 'Crate';


class Crate extends StatefulWidget {
  Crate({Key key}) : super(key: key);

  @override
  CrateState createState() => CrateState();
}

class CrateState extends State<Crate> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: MorpheusTabView(
        child: Padding(
          child: Center(
              child: [
                CrateAddStatefulWidget(),
                SortingStatefulWidget(),
                AllCrateStatefulWidget(),
              ].elementAt(_selectedIndex)),
          padding: EdgeInsets.zero,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: dayNightGradient[6].colors[0],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station),
            label: 'Sorting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).backgroundColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
