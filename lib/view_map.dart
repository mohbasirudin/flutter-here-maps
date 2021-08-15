import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_here_maps/controller_main.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';

class ViewMap extends StatelessWidget {
  ControllerMain controller;
  Function(bool) funcClose;

  ViewMap({required this.controller, required this.funcClose, required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // print("${controller.loading.value}");
        return Container(
          color: Colors.white,
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: !controller.loading.value
                    ? HereMap(onMapCreated: _onMapCreated)
                    : Center(
                        child: CircularProgressIndicator(),
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
                      onTap: () {
                        funcClose(true);
                        _toUserLocation();
                      },
                    ),
                    _button(
                      icon: Icons.adjust,
                      onTap: () => _toUserLocation(),
                    ),
                    _button(
                      icon: Icons.layers_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _toUserLocation() {
    GeoCoordinates _startPoint = GeoCoordinates(
        controller.userLatitude.value, controller.userLongitude.value);

    double _distance = 8000;
    controller.mapController!.camera
        .lookAtPointWithDistance(_startPoint, _distance);
  }

  _button({required var icon, required var onTap, bool isFirst = false}) {
    return Container(
      height: 48,
      width: 48,
      margin: EdgeInsets.only(top: isFirst ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 1,
            spreadRadius: 2,
            offset: Offset(1, 1),
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

  Future<void> _drawRoute(
    GeoCoordinates start,
    GeoCoordinates finish,
    HereMapController mapController,
  ) async {
    RoutingEngine _routeEngine = RoutingEngine();
    Waypoint _wayStart = Waypoint.withDefaults(start);
    Waypoint _wayFinish = Waypoint.withDefaults(finish);
    List<Waypoint> _wayPoints = [_wayStart, _wayFinish];
    _routeEngine.calculateCarRoute(_wayPoints, CarOptions.withDefaults(),
        (error, routes) {
      if (error == null) {
        var _route = routes?.first;
        GeoPolyline _geoPolyline = GeoPolyline(_route!.polyline);
        double _depth = 12;
        controller.mapPolyline = MapPolyline(_geoPolyline, _depth, Colors.blue);
        controller.mapController?.mapScene
            .addMapPolyline(controller.mapPolyline!);
      }
    });
  }

  Future<void> _drawDot({
    required HereMapController mapController,
    required int drawIndex,
    required GeoCoordinates geoCoordinates,
    bool isUser = true,
  }) async {
    ByteData _fileData =
        await rootBundle.load(isUser ? "assets/user.png" : "assets/dot.png");
    Uint8List _pixelData = _fileData.buffer.asUint8List();
    MapImage _mapImage =
        MapImage.withPixelDataAndImageFormat(_pixelData, ImageFormat.png);
    MapMarker _mapMarker = MapMarker(geoCoordinates, _mapImage);
    mapController.mapScene.addMapMarker(_mapMarker);
  }

  Future<void> _drawPin({
    required HereMapController mapController,
    required int drawIndex,
    required GeoCoordinates geoCoordinates,
    bool isUser = true,
  }) async {
    ByteData _fileData = await rootBundle.load("assets/pin.png");
    Uint8List _pixelData = _fileData.buffer.asUint8List();
    MapImage _mapImage =
        MapImage.withPixelDataAndImageFormat(_pixelData, ImageFormat.png);

    Anchor2D _anchor2d = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker _mapMarker =
        MapMarker.withAnchor(geoCoordinates, _mapImage, _anchor2d);
    mapController.mapScene.addMapMarker(_mapMarker);
  }

  void _onMapCreated(HereMapController mapController) {
    controller.mapController = mapController;
    mapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (error) {
      if (error != null) {
        print("error map: $error");
        return;
      }
    });

    GeoCoordinates _startPoint = GeoCoordinates(
        controller.userLatitude.value, controller.userLongitude.value);
    GeoCoordinates _finishPoint = GeoCoordinates(
        controller.placeLatitude.value, controller.placeLongitude.value);

    print("geocoordinate lat1: ${controller.userLatitude.value}");
    print("geocoordinate long1: ${controller.userLongitude.value}");
    print("geocoordinate lat2: ${controller.placeLatitude.value}");
    print("geocoordinate long2: ${controller.placeLongitude.value}");

    _drawDot(
        mapController: mapController,
        drawIndex: 0,
        geoCoordinates: _startPoint);
    // _drawPin(mapController, 1, _startPoint);

    if (controller.placeLongitude.value != 0 &&
        controller.placeLatitude.value != 0) {
      print("masuk mapplace:");
      _drawDot(
        mapController: mapController,
        drawIndex: 0,
        geoCoordinates: _finishPoint,
        isUser: false,
      );
      _drawPin(
        mapController: mapController,
        drawIndex: 1,
        geoCoordinates: _finishPoint,
        isUser: false,
      );

      _drawRoute(_startPoint, _finishPoint, mapController);
    }

    double _distance = 8000;
    mapController.camera.lookAtPointWithDistance(_startPoint, _distance);
  }
}
