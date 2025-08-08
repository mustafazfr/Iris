import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldıktan sonra ViewModel’den randevuları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentsViewModel>(context, listen: false)
          .fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // — Sekme başlıkları
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
                indicator: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFFE4EAF6),
                labelPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  height: 1.13,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  height: 1.13,
                  letterSpacing: 0.1,
                ),
                tabs: const [
                  Tab(text: "Onay Bekleyen\nRandevularım"),
                  Tab(text: "Gelecek\nRandevularım"),
                  Tab(text: "Geçmiş\nRandevularım"),
                  Tab(text: "İptal\nRandevularım"),
                ],
              ),
            ),
          ),

          // — İçerikler
          Expanded(
            child: Consumer2<AppointmentsViewModel, SearchViewModel>(
              builder: (context, vm, searchVm, _) {
                final all = vm.allAppointments;

                // Arama filtresi uygula
                final filtered = searchVm.searchQuery.isEmpty
                    ? all
                    : all.where((r) {
                  final q = searchVm.searchQuery.toLowerCase();
                  final salon =
                      r.saloon?.saloonName.toLowerCase() ?? '';
                  final service =
                      r.service?.serviceName.toLowerCase() ?? '';
                  return salon.contains(q) || service.contains(q);
                }).toList();

                // 4 ayrı liste
                final onayBekleyen = filtered
                    .where((r) => r.status == ReservationStatus.pending)
                    .toList();

                final gelecek = filtered.where((r) {
                  final parts = r.reservationTime.split(':');
                  final dateTime = r.reservationDate.add(Duration(
                    hours: int.parse(parts[0]),
                    minutes: int.parse(parts[1]),
                  ));
                  return dateTime.isAfter(now) &&
                      r.status == ReservationStatus.confirmed;
                }).toList();

                final gecmis = filtered.where((r) {
                  final parts = r.reservationTime.split(':');
                  final dateTime = r.reservationDate.add(Duration(
                    hours: int.parse(parts[0]),
                    minutes: int.parse(parts[1]),
                  ));
                  return (dateTime.isBefore(now) &&
                      r.status == ReservationStatus.confirmed) ||
                      r.status == ReservationStatus.completed ||
                      r.status == ReservationStatus.noShow;
                }).toList()
                  ..sort((a, b) =>
                      b.reservationDate.compareTo(a.reservationDate));

                final iptal = filtered
                    .where((r) => r.status == ReservationStatus.cancelled)
                    .toList();

                final lists = [onayBekleyen, gelecek, gecmis, iptal];

                return TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: lists.map((list) {
                    if (list.isEmpty) {
                      final idx = lists.indexOf(list);
                      String msg;
                      switch (idx) {
                        case 0:
                          msg =
                          "Onay bekleyen randevunuz bulunmamaktadır.";
                          break;
                        case 1:
                          msg =
                          "Yaklaşan randevunuz bulunmamaktadır.";
                          break;
                        case 2:
                          msg =
                          "Geçmiş randevunuz bulunmamaktadır.";
                          break;
                        default:
                          msg =
                          "İptal edilen randevunuz bulunmamaktadır.";
                      }
                      return Center(
                        child: Text(
                          msg,
                          style: AppFonts.bodyMedium(
                            color: AppColors.textColorLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: vm.fetchAppointments,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: list.length,
                        itemBuilder: (c, i) =>
                            _buildAppointmentCard(c, list[i]),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, ReservationModel reservation) {
    Color getStatusColor() {
      switch (reservation.status) {
        case ReservationStatus.pending:
          return const Color(0xFFFFA800);
        case ReservationStatus.confirmed:
          return const Color(0xFF24C166);
        case ReservationStatus.cancelled:
          return const Color(0xFFFF4C4C);
        case ReservationStatus.completed:
          return const Color(0xFF4E61FA);
        default:
          return Colors.grey;
      }
    }

    String getStatusText() {
      switch (reservation.status) {
        case ReservationStatus.pending:
          return "Onay Bekliyor";
        case ReservationStatus.confirmed:
          return "Onaylandı";
        case ReservationStatus.cancelled:
          return "İptal Edildi";
        case ReservationStatus.completed:
          return "Tamamlandı";
        default:
          return "";
      }
    }

    Widget _buildActionRow() {
      if (reservation.status == ReservationStatus.pending ||
          reservation.status == ReservationStatus.confirmed) {
        return Row(
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                "Randevuyu iptal et",
                style: TextStyle(
                    color: Color(0xFFFF4C4C), fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Düzenleme talep et",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4E61FA)),
                foregroundColor: const Color(0xFF4E61FA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Hizmet detayı",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4E61FA)),
                foregroundColor: const Color(0xFF4E61FA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tekrar oluştur",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: AppColors.primaryColor.withOpacity(0.5), width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salon adı
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.saloon?.saloonName ?? 'Salon Bilgisi Yok',
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Adres + Km
              Row(
                children: [
                  Text(
                    reservation.saloon?.saloonAddress ?? 'Adres bilgisi yok',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFFDEE5F0)),
                  ),
                  Text(
                    "5.0 Km",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Hizmet detayı
              Text(
                "Saç kesimi x 1 + Maske x 1",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Tarih + Fiyat
              Row(
                children: [
                  Text(
                    DateFormat('d MMMM y, HH:mm', 'tr_TR')
                        .format(reservation.reservationDate),
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFFDEE5F0)),
                  ),
                  Text(
                    "₺150",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Aksiyonlar
              _buildActionRow(),
            ],
          ),
          // Durum rozeti
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                getStatusText(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
