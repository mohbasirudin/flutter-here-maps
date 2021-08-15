import 'dart:async';

import 'package:flutter_here_maps/model_user.dart';
import 'package:location/location.dart';

class ServiceLocation {
  Location _location = Location();
  StreamController<ModelUser> _streamUser = StreamController<ModelUser>();

  Stream<ModelUser> get locationUser => _streamUser.stream;

  ServiceLocation() {
    _location.requestPermission().then(
      (value) {
        if (value == PermissionStatus.granted) {
          _location.onLocationChanged.listen((event) {
            try {
              _streamUser.add(
                ModelUser(
                  longitude: event.longitude!,
                  latitude: event.latitude!,
                ),
              );
            } catch (e) {}
          });
        }
      },
    );
  }

  void close() => _streamUser.close();
}
