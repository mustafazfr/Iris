import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';
import 'package:intl/intl.dart';

// SEKME BAR
class AppointmentTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  const AppointmentTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      "Onay Bekleyen\nRandevularım",
      "Gelecek\nRandevularım",
      "Geçmiş\nRandevularım",
    ];
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabs.length, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(i),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF4E61FA) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected ? Colors.white : Color(0xFFE4EAF6),
                          height: 1.13,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SizedBox(
            height: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => CustomPaint(
                painter: _DottedLinePainter(),
                size: Size(constraints.maxWidth, 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFDEE5F0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 6, dashSpace = 5, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ASIL SAYFA
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentsViewModel>(context, listen: false).fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentsViewModel, SearchViewModel>(
      builder: (context, appointmentsViewModel, searchViewModel, child) {
        final allAppointments = appointmentsViewModel.allAppointments;

        final List<ReservationModel> filteredAppointments =
        searchViewModel.searchQuery.isEmpty
            ? allAppointments
            : allAppointments.where((reservation) {
          final query = searchViewModel.searchQuery.toLowerCase();
          final salonName = reservation.saloon?.saloonName.toLowerCase() ?? '';
          final serviceName = reservation.service?.serviceName.toLowerCase() ?? '';
          return salonName.contains(query) || serviceName.contains(query);
        }).toList();

        final now = DateTime.now();

        final onayBekleyen = filteredAppointments.where((r) {
          return r.status == ReservationStatus.pending;
        }).toList();

        final gelecek = filteredAppointments.where((r) {
          final dateTime = r.reservationDate.add(Duration(
            hours: int.parse(r.reservationTime.split(':')[0]),
            minutes: int.parse(r.reservationTime.split(':')[1]),
          ));
          return dateTime.isAfter(now) &&
              r.status == ReservationStatus.confirmed;
        }).toList();

        final gecmis = filteredAppointments.where((r) {
          final dateTime = r.reservationDate.add(Duration(
            hours: int.parse(r.reservationTime.split(':')[0]),
            minutes: int.parse(r.reservationTime.split(':')[1]),
          ));
          return dateTime.isBefore(now) ||
              r.status == ReservationStatus.cancelled ||
              r.status == ReservationStatus.completed ||
              r.status == ReservationStatus.noShow;
        }).toList();
        gecmis.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));

        List<ReservationModel> showList;
        if (_selectedTab == 0) {
          showList = onayBekleyen;
        } else if (_selectedTab == 1) {
          showList = gelecek;
        } else {
          showList = gecmis.take(5).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          body: appointmentsViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              AppointmentTabBar(
                selectedIndex: _selectedTab,
                onTabChanged: (i) => setState(() => _selectedTab = i),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: appointmentsViewModel.fetchAppointments,
                  child: showList.isEmpty
                      ? _buildNoAppointmentsMessage(
                    _selectedTab == 0
                        ? "Onay bekleyen randevunuz bulunmamaktadır."
                        : _selectedTab == 1
                        ? "Yaklaşan randevunuz bulunmamaktadır."
                        : "Geçmiş randevunuz bulunmamaktadır.",
                    searchViewModel.searchQuery.isNotEmpty,
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: showList.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(context, showList[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// --- KART TASARIMI --- ///
  Widget _buildAppointmentCard(BuildContext context, ReservationModel reservation) {
    Color getStatusColor() {
      switch (reservation.status) {
        case ReservationStatus.pending: return Color(0xFFFFA800);
        case ReservationStatus.confirmed: return Color(0xFF24C166);
        case ReservationStatus.cancelled: return Color(0xFFFF4C4C);
        case ReservationStatus.completed: return Color(0xFF4E61FA);
        default: return Colors.grey;
      }
    }

    String getStatusText() {
      switch (reservation.status) {
        case ReservationStatus.pending: return "Onay Bekliyor";
        case ReservationStatus.confirmed: return "Onaylandı";
        case ReservationStatus.cancelled: return "İptal Edildi";
        case ReservationStatus.completed: return "Tamamlandı";
        default: return "";
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
            Spacer(),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Düzenleme talep et",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }
      if (reservation.status == ReservationStatus.cancelled ||
          reservation.status == ReservationStatus.completed) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4E61FA)),
                foregroundColor: Color(0xFF4E61FA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Hizmet detayı",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4E61FA)),
                foregroundColor: Color(0xFF4E61FA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tekrar oluştur",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }
      return SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salon adı
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      reservation.saloon?.saloonName ?? 'Salon Bilgisi Yok',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: AppColors.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Adres + Nokta + Km
              Row(
                children: [
                  Text(
                    reservation.saloon?.saloonAddress ?? 'İstanbul',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.circle, size: 10, color: Colors.grey[300]),
                  ),
                  Text(
                    "5.0 Km", // Statik
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Statik Hizmet Detayları
              Text(
                "Saç kesimi x 1 + Maske x 1", // Statik
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Tarih + Nokta + Fiyat (Statik)
              Row(
                children: [
                  Text(
                    DateFormat('d MMM y', 'tr_TR').format(reservation.reservationDate),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.circle, size: 10, color: Colors.grey[300]),
                  ),
                  Text(
                    "₺150", // Statik
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildActionRow(),
            ],
          ),
          // Status badge SAĞ ÜSTTE
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                getStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentsMessage(String message, bool isSearching) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(isSearching ? Icons.search_off : Icons.event_busy,
                size: 80, color: AppColors.iconColor.withAlpha(128)),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'Arama kriterlerinize uygun randevu bulunamadı.'
                  : message,
              style: AppFonts.bodyMedium(color: AppColors.textColorLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
