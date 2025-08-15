import 'package:denemeye_devam/models/saloon_model.dart'; // Veriyi bu modele çevireceğiz
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/salon_category_summary_model.dart';
import '../models/salon_service_model.dart';

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

  Future<List<SaloonModel>> getTopRatedSaloons({int limit = 5}) async {
    final data = await _client
        .from('saloons')
        .select('*, saloon_services(*, services(*))')
        .order('avg_rating', ascending: false)
        .limit(limit);

    return data.map((item) => SaloonModel.fromJson(item)).toList();
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
  Future<List<SaloonModel>> searchSaloons({
    String? categoryId,
    String query = '', // Arama metni
  }) async {
    try {
      final response = await _client.rpc('search_saloons', params: {
        'category_id_filter': categoryId,
        'search_query': query,
      });

      // Gelen veri bir liste değilse hata yönetimi
      if (response is! List) {
        return [];
      }

      // Gelen veriyi SaloonModel listesine çevir
      return response.map((item) => SaloonModel.fromJson(item)).toList();

    } catch (e) {
      print('Hata - searchSaloons: $e');
      return [];
    }
  }
  Future<List<SalonCategorySummaryModel>> fetchSalonCategorySummary(String saloonId) async {
    try {
      final data = await _client
          .from('v_saloon_category_summary')
          .select()
          .eq('saloon_id', saloonId)
          .order('sort_order'); // Kategori sıralamasına göre getir

      return (data as List)
          .map((json) => SalonCategorySummaryModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Hata - fetchSalonCategorySummary: $e');
      rethrow;
    }
  }

  // YENİ EKLENDİ: Bir salonun belirli bir kategorideki servislerini çeker.
  Future<List<SalonServiceModel>> fetchSalonServicesByCategory({
    required String saloonId,
    required String categoryId,
  }) async {
    try {
      final data = await _client
          .from('v_saloon_services_by_category')
          .select()
          .eq('saloon_id', saloonId)
          .eq('category_id', categoryId)
          .eq('is_active', true) // Sadece aktif olanları getir
          .order('service_name');

      return (data as List)
          .map((json) => SalonServiceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Hata - fetchSalonServicesByCategory: $e');
      rethrow;
    }
  }
  Future<List<String>> getAvailableTimeSlots({
    required String saloonId,
    required DateTime date,
  }) async {
    try {
      // Tarihi 'YYYY-MM-DD' formatına çeviriyoruz
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final result = await _client.rpc('get_available_slots', params: {
        'p_saloon_id': saloonId,
        'p_reservation_date': formattedDate,
      });

      // Gelen veri List<dynamic> tipinde olacak, bunu List<String> yapıyoruz.
      // Örn: ["09:00:00", "09:15:00", ...]
      final slots = List<String>.from(result.map((item) => item['available_slot']));
      return slots;

    } catch (e) {
      debugPrint("getAvailableTimeSlots Hata: $e");
      rethrow; // Hatanın üst katmanda (ViewModel'de) yakalanmasını sağlar
    }
  }
  Future<List<PersonalModel>> fetchPersonalsBySaloon(String saloonId) async {
    final rows = await _client
        .from('personals')
        .select('personal_id, saloon_id, name, surname, specialty, profile_photo_url, phone_number, email, created_at, updated_at')
        .eq('saloon_id', saloonId)
        .order('name', ascending: true);

    return (rows as List)
        .map((e) => PersonalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
