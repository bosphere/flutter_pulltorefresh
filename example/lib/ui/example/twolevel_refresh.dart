/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 16:28
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   there two example implements two level,
   the first is common,when twoRefreshing,header will follow the list to scrollDown,when closing,still follow
   list move up,
   important point:
   1. open enableTwiceRefresh bool ,default is false
   2. _refreshController.twiceRefreshComplete() can closing the two level
*/
class TwoLevelExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TwoLevelExampleState();
  }
}

class _TwoLevelExampleState extends State<TwoLevelExample> {
  RefreshController _refreshController1 = RefreshController();
  RefreshController _refreshController2 = RefreshController();
  int _tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshConfiguration(
      enableScrollWhenTwoLevel: true,
      child: LayoutBuilder(
        builder: (q, c) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: (index) {
                _tabIndex = index;
                setState(() {});
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.add), title: Text("二级刷新例子1")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.border_clear), title: Text("二级刷新例子2"))
              ],
            ),
            body: Stack(
              children: <Widget>[
                Offstage(
                  offstage: _tabIndex != 0,
                  child: LayoutBuilder(
                    builder: (_, c) {
                      return NotificationListener(
                        child: SmartRefresher(
                          header: ClassicHeader(
                            textStyle: TextStyle(color: Colors.white),
                            outerBuilder: (child) {
                              return Container(
                                height: c.biggest.height,
                                child: _refreshController1.headerStatus !=
                                            RefreshStatus.twoLeveling &&
                                        _refreshController1.headerStatus !=
                                            RefreshStatus.twoLevelOpening &&
                                        _refreshController1.headerStatus !=
                                            RefreshStatus.twoLevelClosing
                                    ? Container(
                                        height: 60.0,
                                        alignment: Alignment.center,
                                        child: child,
                                      )
                                    : child,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                          "images/secondfloor.jpg",
                                        ),
                                        fit: BoxFit.cover)),
                                alignment: Alignment.bottomCenter,
                              );
                            },
                            twoLevelView: Container(
                              height: c.biggest.height,
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Wrap(
                                      children: <Widget>[
                                        RaisedButton(
                                          color: Colors.greenAccent,
                                          onPressed: () {},
                                          child: Text("登陆"),
                                        ),
                                        RaisedButton(
                                          color: Colors.purpleAccent,
                                          child: Text('注册'),
                                          onPressed: () {},
                                        )
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: AppBar(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0.0,
                                      leading: GestureDetector(
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          _refreshController1
                                              .twoLevelComplete();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: CustomScrollView(
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: Container(
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("点击这里返回上一页!"),
                                  ),
                                  color: Colors.red,
                                  height: 1180.0,
                                ),
                              )
                            ],
                          ),
                          controller: _refreshController1,
                          enableTwoLevel: true,
                          onRefresh: () async {
                            await Future.delayed(Duration(milliseconds: 2000));
                            _refreshController1.refreshCompleted();
                          },
                          onTwoLevel: () {},
                        ),
                        onNotification: (n) {
                          if (n is ScrollUpdateNotification) {
                            if (n.dragDetails == null) {
                              if (n.metrics.pixels > 50.0 &&
                                  _refreshController1.isTwoLevel)
                                _refreshController1.twoLevelComplete();
                            }
                          } else if (n is ScrollEndNotification) {
                            if (n.metrics.pixels > 50.0 &&
                                _refreshController1.isTwoLevel)
                              _refreshController1.twoLevelComplete();
                          }
                          return false;
                        },
                      );
                    },
                  ),
                ),
                Offstage(
                  offstage: _tabIndex != 1,
                  child: SmartRefresher(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("点击这里返回上一页!"),
                            ),
                            color: Colors.red,
                            height: 680.0,
                          ),
                        )
                      ],
                    ),
                    controller: _refreshController2,
                    enableTwoLevel: true,
                    onRefresh: () async {
                      await Future.delayed(Duration(milliseconds: 2000));
                      _refreshController2.refreshCompleted();
                    },
                    onTwoLevel: () {
//                    _refreshController2.position.forcePixels( _refreshController2.position.pixels);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (c) => Scaffold(
                                    appBar: AppBar(),
                                  )))
                          .whenComplete(() {
                        _refreshController2.twoLevelComplete();
                      });
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}