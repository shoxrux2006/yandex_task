import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_task/maxWayDio.dart';

import 'app_lat_long.dart';
import 'branch_model.dart';
import 'location_service.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({Key? key}) : super(key: key);

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  late MaxWayBranch _response;
  var branches = <Branch>[];
  final mapControllerCompleter = Completer<YandexMapController>();
  final animation = MapAnimation(type: MapAnimationType.smooth, duration: 2.0);
  final List<MapObject> mapObjects = [];
  GlobalKey mapKey = GlobalKey();
  bool progress = false;
  var selectedBranch = 0;

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
    getData();
  }

  Future<void> getData() async {
    _response = await Api().main();
    branches = _response.pageProps.branches.branches;
    await setMarkers(branches);
    _moveToCurrentLocation(AppLatLong(
        lat: branches.first.location.lat, long: branches.first.location.long));

    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: 41.311153,
            longitude: 69.279729,
          ),
          zoom: 10,
        ),
      ),
    );
    progress = true;
    setState(() {});
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation(location);
  }

  Future<void> setMarkers(List<Branch> branches) async {
    for (var element in branches) {
      mapObjects.add(PlacemarkMapObject(
          mapId: MapObjectId(element.id),
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              scale: 0.4,
              image: BitmapDescriptor.fromAssetImage("assets/images/pin.png"))),
          point: Point(
              latitude: element.location.lat,
              longitude: element.location.long)));
    }
    setState(() {});
  }

  Future<void> _moveToCurrentLocation(
    AppLatLong appLatLong,
  ) async {
    mapObjects.add(PlacemarkMapObject(
        mapId: MapObjectId("fiodnjngfnim"),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            scale: 0.8,
            image: BitmapDescriptor.fromAssetImage("assets/images/img.png"))),
        point: Point(latitude: appLatLong.lat, longitude: appLatLong.long)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: YandexMap(
              key: mapKey,
              onMapCreated: (controller) async {
                controller = controller;
                mapControllerCompleter.complete(controller);
                await controller.deselectGeoObject();
              },
              zoomGesturesEnabled: true,
              mapObjects: mapObjects,
            ),
          ),
          Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: progress ? branches.length - 1 : 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        (await mapControllerCompleter.future).moveCamera(
                          animation: const MapAnimation(
                              type: MapAnimationType.linear, duration: 1),
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: Point(
                                latitude: branches[index].location.lat,
                                longitude: branches[index].location.long,
                              ),
                              zoom: 15,
                            ),
                          ),
                        );
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Text(
                              branches[index].name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    );
                  }))
        ],
      ),
    ));
  }
}
