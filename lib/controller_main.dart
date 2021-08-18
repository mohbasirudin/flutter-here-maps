import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_here_maps/service_location.dart';
import 'package:get/get.dart';
import 'package:here_sdk/mapview.dart';

class BindingMain extends Bindings {
  @override
  void dependencies() {
    Get.put(ControllerMain());
  }
}

class ControllerMain extends GetxController {
  CustomPopupMenuController popupMenuController = CustomPopupMenuController();
  HereMapController? hereMapController;

  RxInt indexMapScheme = 0.obs;
  RxString routeDistance = "".obs;
  RxString routeTime = "".obs;
  MapPolyline? mapPolyline;
  MapMarker? mapMarker;

  ServiceLocation _serviceLocation = ServiceLocation();
  RxDouble userLongitude = 0.0.obs;
  RxDouble userLatitude = 0.0.obs;
  RxList<String> places = <String>[].obs;
  RxInt indexPlace = 0.obs;
  RxList<String> points = <String>["Your location", ""].obs;

  RxString placeName = "".obs;
  RxDouble placeLongitude = 0.0.obs;
  RxDouble placeLatitude = 0.0.obs;
  RxBool loading = false.obs;

  List<MapScheme> mapSchemes = [
    MapScheme.normalDay,
    MapScheme.normalNight,
    MapScheme.hybridDay,
    MapScheme.hybridNight,
    MapScheme.satellite,
  ];
  List<String> typeScheme = [
    "Normal Day",
    "Normal Night",
    "Hybrid Day",
    "Hybrid Night",
    "Satelite",
  ];
  List<String> imageScheme = [
    "assets/normal_day.png",
    "assets/normal_night.png",
    "assets/hybrid_day.png",
    "assets/hybrid_night.png",
    "assets/satelite.png",
  ];

  @override
  void onInit() {
    popupMenuController.showMenu();

    //untuk akses lokasimu saat ini,
    // uncomment code nomor 1 & comment code nomor 2

    // (1)
    // _serviceLocation.locationUser.listen((event) {
    //   try {
    //     userLongitude.value = event.longitude;
    //     userLatitude.value = event.latitude;
    //   } catch (e) {}
    // });

    // (2)
    userLatitude.value = -8.2099494;
    userLongitude.value = 114.3711243;

    _setDummyPlace();

    super.onInit();
  }

  _setDummyPlace() {
    if (places.isNotEmpty) places.clear();
    places.add("Pantai Lampon"
        "&&-8.6234887"
        "&&114.0409668"
        "&&Lampon, Pesanggaran, Kabupaten Banyuwangi, Jawa Timur 68488"
        "&&https://lh5.googleusercontent.com/-e9JfNfZO6SU/VRyKmUtJneI/AAAAAAABMlo/qVVVAcDi1W8/w480-h320-no/pantai-Tni-al.jpg");
    places.add("Pantai Boom"
        "&&-8.2074376"
        "&&114.3825845"
        "&&Desa, Kampungmandar, Kec. Banyuwangi, Kabupaten Banyuwangi, Jawa Timur 68419"
        "&&https://cdn.idntimes.com/content-images/post/20200903/ga-ba5a307a1090cd6adb9acb27184246ec_600x400.jpg");
    places.add("Gunung Ijen"
        "&&-8.0587807"
        "&&114.2352035"
        "&&Terongan, Kebonrejo, Kec. Kalibaru, Kabupaten Banyuwangi, Jawa Timur"
        "&&https://www.befren.com/wp-content/uploads/2019/12/Tempat-Wisata-Populer-di-Jawa-Timur-untuk-Liburan-Tahun-Baru-2020-befren.com_.jpg");
    places.add("Teluk Hijau"
        "&&-8.5635412"
        "&&113.9218005"
        "&&Dusun Krajan, Sarongan, Pesanggaran, Kabupaten Banyuwangi, Jawa Timur 68488"
        "&&https://1.bp.blogspot.com/-D753r2cgTms/XYRDJqsHXZI/AAAAAAAA5sM/3Ru3J4ee0EYJOqjjQirANSv-4BJLEp5HgCLcBGAsYHQ/s640/Teluk%2BHijau%2B5.jpg");
    places.add("Pantai Plengkung (G-Land)"
        "&&-8.7255339"
        "&&114.3622506"
        "&&Purworejo, Kalipait, Tegaldlimo, Kabupaten Banyuwangi, Jawa Timur"
        "&&https://cdn.idntimes.com/content-images/community/2018/10/20184625-132029707396619-7499699092855980032-n-31ddb7bc91e797c47dc9835e0ea39690_600x400.jpg");
  }

  close() {
    // if (mapPolyline != null) {
    //   mapController?.mapScene.removeMapPolyline(mapPolyline!);
    //   mapPolyline = null;
    // }
    // points[1] = "";
  }

  @override
  void onClose() {
    hereMapController?.finalize();
    _serviceLocation.close();
    close();
    super.onClose();
  }
}
