import 'package:denemeye_devam/models/saloon_model.dart'; // Veriyi bu modele çevireceğiz
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<Map<String, dynamic>> data = await _client.from('saloons').select(query);
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      // Hatayı daha detaylı görmek için konsola yazdır! Bu çok önemli!
      debugPrint('Supabase sorgu hatası: $e');
      return [];
    }
  }
  Future<List<SaloonModel>> getAllSaloons() async {
    // Mevcut `_saloonWithServicesQuery` sorgusu bu iş için mükemmel.
    // Tüm salonları, onlara bağlı hizmetleri ve hizmetlerin detaylarını getirir.
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  // Sorguyu tek bir yerden yönetmek daha temiz.
  static const String _saloonWithServicesQuery = '*, saloon_services(*, services(*))';

  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  Future<List<SaloonModel>> getTopRatedSaloons() {
    // order ve limit gibi eklemeleri burada yapabiliriz.
    return _fetchSaloons('$_saloonWithServicesQuery, comments(rating)');
  }

  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }
  // Belirli bir salonu ID'sine göre tüm detaylarıyla getiren fonksiyon
  Future<SaloonModel?> getSaloonById(String salonId) async {
    try {
      // İlişkili tabloları da (*) ile çekiyoruz: hizmetler ve yorumlar
      final response = await _client
          .from('saloons')
          .select('*, saloon_services(*, services(*)), comments(*)')
          .eq('saloon_id', salonId)
          .single(); // Tek bir kayıt döneceği için .single() kullanıyoruz.

      return SaloonModel.fromJson(response);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  // Bir salona bağlı tüm çalışanları getiren fonksiyon
  Future<List<PersonalModel>> getEmployeesBySaloon(String salonId) async {
    try {
      final response = await _client
          .from('personals')
          .select('*')
          .eq('saloon_id', salonId);

      return response.map((item) => PersonalModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('getEmployeesBySaloon Hata: $e');
      return [];
    }
  }
}