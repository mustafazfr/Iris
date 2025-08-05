import 'package:flutter/material.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardViewModel extends ChangeNotifier {
  String? locationError;
  GoogleMapController? mapController;
  Position? currentPosition;
  final SaloonRepository _repository = SaloonRepository(Supabase.instance.client);

  /// Tüm marker’ları burada tutacağız.
  Set<Marker> markers = {};

  DashboardViewModel();

  Future<void> initLocation() async {
    locationError = null;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Konum servisi kapalı. Açın lütfen.';
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        throw 'Konum izni reddedildi.';
      }
      if (perm == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.';
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationError = null;

      // Salonları çekip marker’ları oluştur (25 km yarıçap)
      await _loadNearbySaloonMarkers();
    } catch (e) {
      locationError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Yakındaki salonları 25 km içinde filtreleyip marker seti oluşturur
  Future<void> _loadNearbySaloonMarkers() async {
    if (currentPosition == null) return;
    final all = await _repository.getNearbySaloons();
    const maxDistance = 25 * 1000; // 25 km
    final nearby = all.where((s) {
      if (s.latitude == null || s.longitude == null) return false;
      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        s.latitude!,
        s.longitude!,
      );
      return distance <= maxDistance;
    }).toList();

    markers = nearby.map((s) {
      return Marker(
        markerId: MarkerId(s.saloonId),
        position: LatLng(s.latitude!, s.longitude!),
        infoWindow: InfoWindow(
          title: s.saloonName,
          snippet: s.saloonAddress,
        ),
      );
    }).toSet();
  }

  /// Geliştirme aşamasında tüm salonları marker olarak yükler
  Future<void> _loadAllSalonMarkers() async {
    final all = await _repository.getAllSaloons();
    markers = all
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => Marker(
      markerId: MarkerId(s.saloonId),
      position: LatLng(s.latitude!, s.longitude!),
      infoWindow: InfoWindow(
        title: s.saloonName,
        snippet: s.saloonAddress,
      ),
    ))
        .toSet();
  }

  // Repository’den veriyi döndüren metotlar
  Future<List<SaloonModel>> getNearbySaloons() => _repository.getNearbySaloons();
  Future<List<SaloonModel>> getTopRatedSaloons() => _repository.getTopRatedSaloons();
  Future<List<SaloonModel>> getCampaignSaloons() => _repository.getCampaignSaloons();

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Haritayı kullanıcıya taşı
    if (currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentPosition!.latitude,
              currentPosition!.longitude,
            ),
            zoom: 14,
          ),
        ),
      );
    }
    notifyListeners();
  }
}
