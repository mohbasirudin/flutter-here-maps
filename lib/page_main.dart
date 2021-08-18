import 'dart:typed_data';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_here_maps/controller_main.dart';
import 'package:flutter_here_maps/view_bottom.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as r;
import 'package:location/location.dart' as loc;

class PageMain extends GetView<ControllerMain> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            Container(
              child: HereMap(onMapCreated: _onMapCreated),
            ),
            Positioned(
              top: 36,
              right: 12,
              child: CustomPopupMenu(
                controller: controller.popupMenuController,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(1, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.layers_outlined,
                      color: Colors.black54,
                      size: 28,
                    ),
                  ),
                ),
                arrowSize: 16,
                verticalMargin: -4,
                arrowColor: Colors.white,
                barrierColor: Colors.transparent,
                menuBuilder: () => Container(
                  width: 152,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.mapSchemes.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var _selected =
                            controller.indexMapScheme.value == index;
                        return Material(
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin: EdgeInsets.only(right: 8),
                                    child: Image.asset(
                                      controller.imageScheme[index],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      controller.typeScheme[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selected
                                            ? Colors.blue
                                            : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              controller.hereMapController?.mapScene
                                  .loadSceneForMapScheme(
                                controller.mapSchemes[index],
                                (error) {
                                  if (error != null) {
                                    print("load map, error: $error");
                                    return;
                                  }
                                  controller.indexMapScheme.value = index;
                                  controller.popupMenuController.hideMenu();
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                pressType: PressType.singleClick,
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _button(
                    icon: Icons.close,
                    isFirst: true,
                    onTap: () {},
                  ),
                  _button(
                    icon: Icons.adjust,
                    onTap: () => _loadMap(
                      mapController: controller.hereMapController!,
                      funcTap: (point2D) {
                        try{
                          if (controller.mapPolyline != null) {
                            controller.hereMapController!.mapScene
                                .removeMapPolyline(controller.mapPolyline!);
                            controller.mapPolyline = null;
                          }
                          if (controller.mapMarker != null) {
                            controller.hereMapController!.mapScene
                                .removeMapMarker(controller.mapMarker!);
                            controller.mapMarker = null;
                          }

                          GeoCoordinates? coordinate = controller
                              .hereMapController!
                              .viewToGeoCoordinates(point2D);
                          _loadMap(
                            mapController: controller.hereMapController!,
                            targetLatitude: coordinate!.latitude,
                            targetLongitude: coordinate.longitude,
                          );
                        }catch(e){
                          print("error tap: $e");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Visibility(
                visible: controller.routeTime.value.isNotEmpty ||
                    controller.routeDistance.value.isNotEmpty,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${controller.routeDistance.value} (${controller.routeTime.value})",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ViewBottom(controller: controller),
      ),
    );
  }

  _button({
    required var icon,
    required var onTap,
    bool isFirst = false,
  }) {
    double size = 40;
    return Container(
      height: size,
      width: size,
      margin: EdgeInsets.only(top: isFirst ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(1, 0),
          ),
        ],
      ),
      child: GestureDetector(
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
            size: 28,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _onMapCreated(HereMapController mapController) async {
    controller.hereMapController = mapController;
    // r.Route? route;
    try {
      mapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
          (error) {
        if (error != null) {
          print("map error: $error");
          return;
        }
      });

      _loadMap(mapController: mapController);
    } catch (e) {
      print("error create map $e");
    }
  }

  void _loadMap({
    required HereMapController mapController,
    double targetLatitude = 0.0,
    double targetLongitude = 0.0,
    Function(Point2D)? funcTap,
  }) async {
    try {
      r.Route? route;
      mapController.setWatermarkPosition(WatermarkPlacement.bottomLeft, 12);
      loc.Location location = loc.Location();
      double userLat = 0.0;
      double userLong = 0.0;
      await location.requestPermission().then((value) async {
        if (value == loc.PermissionStatus.granted) {
          await location.getLocation().then((value) async {
            userLat = value.latitude!;
            userLong = value.longitude!;
            print("loc1: $userLat, $userLong");

            GeoCoordinates userCoordinates =
                GeoCoordinates(value.latitude!, value.longitude!);
            // GeoCoordinates userCoordinates =
            //     GeoCoordinates(-7.3273729, 112.6888019);

            double latitude = 0.0;
            double longitude = 0.0;

            if (targetLatitude != 0 || targetLongitude != 0) {
              latitude = targetLatitude;
              longitude = targetLongitude;
            } else {
              latitude = -7.3106989;
              longitude = 112.7167825;
            }
            print("lat: $latitude, long: $longitude");
            GeoCoordinates targetCoordinates =
                GeoCoordinates(latitude, longitude);

            //  polyline
            r.Waypoint start = r.Waypoint.withDefaults(userCoordinates);
            r.Waypoint end = r.Waypoint.withDefaults(targetCoordinates);
            List<r.Waypoint> waypoints = [start, end];
            r.RoutingEngine routing = r.RoutingEngine();
            // RouteHandle? routeHandle;
            routing.calculateCarRoute(waypoints, r.CarOptions.withDefaults(),
                (error, routes) {
              if (error == null) {
                route = routes?.first;
                // routeHandle = route!.routeHandle!;
                print("meter: ${route!.lengthInMeters}, "
                    "second: ${route!.durationInSeconds} "
                    "minute:  ${route!.durationInSeconds % 60} "
                    "hour:  ${(route!.durationInSeconds % 3600)} ");

                GeoPolyline geoPolyline = GeoPolyline(route!.polyline);
                controller.mapPolyline =
                    MapPolyline(geoPolyline, 12, Colors.blue);
                mapController.mapScene.addMapPolyline(controller.mapPolyline!);

                int intTime = route!.durationInSeconds;
                var time = "";
                if (intTime < 60) {
                  time = "$intTime detik";
                } else if (intTime >= 60 && intTime < 3600) {
                  time = "${(intTime / 60).toStringAsFixed(0)} menit";
                } else {
                  String hour = (intTime / 3600).toStringAsFixed(0);
                  String minute = "";
                  if (intTime % 3600 >= 60) {
                    minute = ((intTime % 3600) / 60).toStringAsFixed(0);
                  }

                  if (minute.isNotEmpty) {
                    time = "$hour Jam $minute Menit";
                  } else {
                    time = "$hour Jam";
                  }
                }

                int intDistance = 9051;
                var distance = "";
                if (intDistance < 1000) {
                  distance = "$intDistance M";
                } else {
                  if (intDistance % 1000 < 50) {
                    distance = "${(intDistance / 1000).toStringAsFixed(0)} KM";
                  } else {
                    distance = "${(intDistance / 1000).toStringAsFixed(1)} KM";
                  }
                }

                controller.routeTime.value = time;
                controller.routeDistance.value = distance;

                print(
                    "mapku: ${controller.routeTime.value}, ${controller.routeDistance.value}");
              }
            });

            //pin
            ByteData byteData = await rootBundle.load("assets/marker.png");
            Uint8List uint8list = byteData.buffer.asUint8List();
            MapImage mapImage = MapImage.withPixelDataAndImageFormat(
                uint8list, ImageFormat.png);
            controller.mapMarker = MapMarker(targetCoordinates, mapImage);
            mapController.mapScene.addMapMarker(controller.mapMarker!);

            //custom pin
            // mapController.pinWidget(
            //     Image.asset("assets/marker.png"), targetCoordinates);

            //location indicator
            LocationIndicator locationIndicator = LocationIndicator();
            Location hereLocation =
                Location.withDefaults(userCoordinates, DateTime.now());
            locationIndicator.locationIndicatorStyle =
                LocationIndicatorIndicatorStyle.pedestrian;
            locationIndicator.updateLocation(hereLocation);
            mapController.addLifecycleListener(locationIndicator);

            //  camera
            mapController.camera.lookAtAreaWithGeoOrientation(
              GeoBox(userCoordinates, targetCoordinates),
              // GeoOrientationUpdate(12, 45),
              GeoOrientationUpdate(12, 0),
            );

            //  gesture
            mapController.gestures.tapListener = TapListener((point) {
              funcTap!(point);

//               RefreshRouteOptions refreshRouteOptions = RefreshRouteOptions.withTaxiOptions(taxiOptions);
//
// // Update the route options and set a new start point on the route.
// // The new starting point must be on or very close to the original route, preferrably, use a map-matched waypoint if possible.
// // Note: A routeHandle is only available, when RouteOptions.enableRouteHandle was set to true when the original route was calculated.
//               routingEngine.refreshRoute(route.routeHandle, mapMatchedWaypoint, refreshRouteOptions, (routingError, routes) {
//                 if (routingError == null) {
//                   HERE.Route newRoute = routes.first;
//                   // ...
//                 } else {
//                   // Handle error.
//                 }
//               });
            });
          });
        }
      });
    } catch (e) {
      print("error load map");
    }
  }
}
