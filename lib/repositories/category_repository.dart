// lib/repositories/category_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_summary_model.dart';

class CategoryRepository {
  final SupabaseClient sb;

  // Constructor ile SupabaseClient'i alıyoruz.
  // Bu, bağımlılıkları yönetmeyi kolaylaştırır.
  CategoryRepository(this.sb);

  // Dashboard'daki kategori listesini çekmek için.
  // Veritabanında oluşturduğumuz v_categories view'ına sorgu atar.
  Future<List<CategorySummaryModel>> fetchAllCategories() async {
    try {
      final res = await sb
          .from('v_categories')
          .select('category_id, name, icon_url, service_count')
          .order('sort_order', ascending: true) // sort_order'a göre sırala
          .order('name', ascending: true);     // İkincil sıralama olarak isme göre

      // Supabase'den gelen List<Map<String, dynamic>> tipindeki veriyi
      // List<CategorySummaryModel> tipine dönüştürüyoruz.
      // Modeldeki fromJson factory constructor'ı burada işe yarıyor.
      final categories = (res as List)
          .map((json) => CategorySummaryModel.fromJson(json))
          .toList();

      return categories;

    } catch (e) {
      // Bir hata olursa, konsola yazdır ve boş bir liste döndür.
      // Böylece uygulama çökmez.
      print('Hata - fetchAllCategories: $e');
      return [];
    }
  }

// Buraya ileride kategorilerle ilgili başka Supabase sorguları da ekleyebiliriz.
// (Örn: getCategoryDetails, vs.)
}