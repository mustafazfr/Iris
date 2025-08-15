import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

import '../../../widgets/countdown_chip.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = Provider.of<AppointmentsViewModel>(context, listen: false);
      await vm.syncServerTime(); // önce sunucu saati
      await vm.fetchAppointments(); // sonra veriler
      await _ensurePosition();
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
                labelPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
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
                final q = searchVm.searchQuery.trim().toLowerCase();

                // önce tüm liste
                List<ReservationModel> filtered = all;

                // arama varsa filtrele
                if (q.isNotEmpty) {
                  filtered = all.where((r) {
                    final salon = r.saloon?.saloonName.toLowerCase() ?? '';
                    final servicesText = (r.services.isNotEmpty)
                        ? r.services
                              .map((s) => s.serviceName.toLowerCase())
                              .join(', ')
                        : (r.service?.serviceName.toLowerCase() ?? '');
                    return salon.contains(q) || servicesText.contains(q);
                  }).toList();
                }

                // arama sonucu boşsa (ama verin varsa) fallback olarak tüm randevuları göster
                final source = (filtered.isEmpty && all.isNotEmpty)
                    ? all
                    : filtered;

                // 4 ayrı liste
                final onayBekleyen = source.where((r) {
                  final s = r.status; // nullable olabilir
                  if (s == null) return true; // statüsü çözülemeyenleri pending gibi göster
                  // pending dışındaki net statüleri ayır, kalan her şeyi "onay bekleyen" say
                  return s != ReservationStatus.confirmed &&
                      s != ReservationStatus.cancelled &&
                      s != ReservationStatus.completed &&
                      s != ReservationStatus.noShow;
                }).toList();

                final gelecek = source.where((r) {
                  final dt = _combineDateAndTime(r);
                  return dt.isAfter(now) &&
                      r.status == ReservationStatus.confirmed;
                }).toList();

                final gecmis =
                    source.where((r) {
                      final dt = _combineDateAndTime(r);
                      return (dt.isBefore(now) &&
                              r.status == ReservationStatus.confirmed) ||
                          r.status == ReservationStatus.completed ||
                          r.status == ReservationStatus.noShow;
                    }).toList()..sort(
                      (a, b) => _combineDateAndTime(
                        b,
                      ).compareTo(_combineDateAndTime(a)),
                    );

                final iptal = source
                    .where((r) => r.status == ReservationStatus.cancelled)
                    .toList();

                final lists = [onayBekleyen, gelecek, gecmis, iptal];

                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: lists.map((list) {
                    if (list.isEmpty) {
                      final idx = lists.indexOf(list);
                      String msg;
                      switch (idx) {
                        case 0:
                          msg = "Onay bekleyen randevunuz bulunmamaktadır.";
                          break;
                        case 1:
                          msg = "Yaklaşan randevunuz bulunmamaktadır.";
                          break;
                        case 2:
                          msg = "Geçmiş randevunuz bulunmamaktadır.";
                          break;
                        default:
                          msg = "İptal edilen randevunuz bulunmamaktadır.";
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
                          horizontal: 16,
                          vertical: 10,
                        ),
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

  Position? _pos;
  Future<void> _ensurePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      }
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      if (mounted) setState(() => _pos = p);
    } catch (_) {/* sessiz */}
  }

  String? _distanceTextFor(ReservationModel r) {
    final s = r.saloon;
    if (_pos == null || s?.latitude == null || s?.longitude == null) return null;
    final meters = Geolocator.distanceBetween(
      _pos!.latitude, _pos!.longitude, s!.latitude!, s.longitude!,
    );
    final km = meters / 1000.0;
    return km < 10 ? '${km.toStringAsFixed(1)} Km' : '${km.toStringAsFixed(0)} Km';
  }

  DateTime _combineDateAndTime(ReservationModel r) {
    // Gün bilgisi UTC geldiyse yerelleştir
    final d = r.reservationDate.toLocal();
    final parts = r.reservationTime.split(':'); // "HH:mm" veya "HH:mm:ss"
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(d.year, d.month, d.day, h, m);
  }

  Widget _statusBadge(ReservationStatus status) {
    Color color;
    String text;
    switch (status) {
      case ReservationStatus.pending:
        color = AppColors.warning; // turuncu
        text = 'Onay Bekliyor';
        break;
      case ReservationStatus.confirmed:
        color = AppColors.success; // yeşil
        text = 'Onaylandı';
        break;
      case ReservationStatus.cancelled:
        color = AppColors.error; // kırmızı
        text = 'İptal Edildi';
        break;
      case ReservationStatus.completed:
        color = AppColors.primaryColor; // mor
        text = 'Tamamlandı';
        break;
      default:
        color = AppColors.greyMedium;
        text = '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    ReservationModel reservation,
  ) {
    final vm = context.watch<AppointmentsViewModel>();

    // Birleşik datetime (kullanıcı saat dilimi)
    final dtLocal = _combineDateAndTime(reservation);

    final addr = reservation.saloon?.saloonAddress?.trim();
    final hasAddr = addr != null && addr.isNotEmpty;

    // Onay süresi sayacı (15 dk)
    final createdUtc = (reservation.createdAt ?? DateTime.now()).toUtc();
    final expiresAtUtc = createdUtc.add(const Duration(minutes: 15));

    // Çoklu hizmet metni
    final servicesText = reservation.services.isNotEmpty
        ? reservation.services.map((s) => s.serviceName).join(', ')
        : 'Hizmet bilgisi yok';

    // Aksiyon satırı
    Widget _buildActionRow() {
      // Sunucu saat farkı ile “şimdi (UTC)”
      final nowAlignedUtc = DateTime.now().toUtc().add(vm.serverOffset);

      // Randevu zamanı (UTC)
      final dtUtc = DateTime.utc(
        dtLocal.year,
        dtLocal.month,
        dtLocal.day,
        dtLocal.hour,
        dtLocal.minute,
      );

      // Yalnızca CONFIRMED için 12 saat kuralı
      final canCancelConfirmed =
          dtUtc.difference(nowAlignedUtc) >= const Duration(hours: 12);

      Future<void> _cancel() async {
        final id = reservation.reservationId;
        if (id == null || id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rezervasyon ID bulunamadı.')),
          );
          return;
        }
        try {
          await context.read<AppointmentsViewModel>().cancelAppointment(id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Randevu iptal edildi.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('İptal edilirken hata: $e')));
        }
      }

      void _openServicesSheet() {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hizmet Detayı',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(servicesText, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }

      if (reservation.status == ReservationStatus.pending) {
        // pending: her zaman iptal edilebilir
        return Row(
          children: [
            TextButton(
              onPressed: _cancel,
              child: const Text(
                "Randevuyu iptal et",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Düzenleme talep et",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      } else if (reservation.status == ReservationStatus.confirmed) {
        // confirmed: 12 saatten fazla varsa iptal edilebilir
        return Row(
          children: [
            if (canCancelConfirmed)
              TextButton(
                onPressed: _cancel,
                child: const Text(
                  "Randevuyu iptal et",
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Düzenleme talep et",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      } else {
        // completed / cancelled
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _openServicesSheet,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Hizmet detayı",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Tekrar oluştur",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık: Salon adı + sağda rozet & sayaç
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,          // rozet ile sayacın arası
                runSpacing: 4,       // alta inerse aradaki düşey boşluk
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _statusBadge(reservation.status),
                  if (reservation.status == ReservationStatus.pending)
                    CountdownChip(
                      expiresAtUtc: expiresAtUtc,
                      serverOffset: vm.serverOffset,
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Adres + Km
          Builder(
            builder: (_) {
              final addr = reservation.saloon?.saloonAddress;
              final dist = _distanceTextFor(reservation); // null olabilir

              final left = Text(
                (addr != null && addr.isNotEmpty) ? addr : 'Adres bilgisi yok',
                style: TextStyle(color: AppColors.textColorLight, fontSize: 12, fontWeight: FontWeight.w400),
              );

              if (dist == null) return Row(children: [left]);

              return Row(
                children: [
                  left,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFFDEE5F0)),
                  ),
                  Text(
                    dist,
                    style: TextStyle(color: AppColors.textColorLight, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // Hizmetler
          Text(
            servicesText,
            style: TextStyle(
              color: AppColors.textColorLight,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Tarih + Fiyat
          Row(
            children: [
              Text(
                DateFormat('d MMMM y, HH:mm', 'tr_TR').format(dtLocal),
                style: TextStyle(
                  color: AppColors.textColorDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.circle, size: 6, color: Color(0xFFDEE5F0)),
              ),
              Text(
                '₺${reservation.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  color: AppColors.textColorDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Aksiyonlar
          _buildActionRow(),
        ],
      ),
    );
  }
}
