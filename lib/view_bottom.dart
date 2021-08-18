import 'package:flutter/material.dart';
import 'package:flutter_here_maps/controller_main.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'menu_places.dart';

class ViewBottom extends StatelessWidget {
  ControllerMain controller;

  ViewBottom({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 4,
      child: Obx(
        () => Container(
          height: 120,
          color: Colors.white,
          child: Center(
            child: ListView.builder(
              itemCount: controller.points.length,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                double _sizeIndicator = 16;
                bool _isFirst = index == 0;

                return TimelineTile(
                  alignment: TimelineAlign.start,
                  axis: TimelineAxis.vertical,
                  indicatorStyle: IndicatorStyle(
                    color: Colors.red,
                    height: _sizeIndicator,
                    width: _sizeIndicator,
                    padding: EdgeInsets.only(
                      right: 8,
                      bottom: 4,
                      top: 4,
                    ),
                    indicator: Icon(
                      _isFirst ? Icons.account_circle : Icons.place,
                      color: _isFirst ? Colors.blue : Colors.red,
                      size: _sizeIndicator,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                  isFirst: _isFirst ? true : false,
                  isLast: _isFirst ? false : true,
                  endChild: Container(
                    color: Colors.white,
                    height: 48,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.points[index].isNotEmpty
                                    ? controller.points[index]
                                    : "Choose destination",
                                style: TextStyle(
                                  color: controller.points[index].isNotEmpty
                                      ? Colors.black87
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !_isFirst,
                              child: Container(
                                margin: EdgeInsets.only(left: 12),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: _isFirst
                          ? null
                          : () => showModalBottomSheet(
                                context: context,
                                barrierColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                useRootNavigator: false,
                                isDismissible: true,
                                backgroundColor: Colors.white,
                                builder: (context) => MenuPlace(
                                  places: controller.places,
                                  curIndex: controller.indexPlace.value,
                                  funcTap: (place) async {
                                    controller.loading.value = true;

                                    controller.points[1] = place[0];
                                    controller.placeLongitude.value =
                                        double.parse(place[2]);
                                    controller.placeLatitude.value =
                                        double.parse(place[1]);
                                    controller.indexPlace.value =
                                        int.parse(place[5]);
                                    await Future.delayed(Duration(seconds: 2));
                                    controller.loading.value = false;
                                    print("loading finish");
                                  },
                                ),
                              ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
