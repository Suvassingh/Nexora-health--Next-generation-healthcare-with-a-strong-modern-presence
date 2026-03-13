import 'package:flutter/material.dart';
import 'package:patient_app/models/appointment_model.dart';

const List<AppointmentModel> _allAppointments = [
  AppointmentModel(
    doctorName: 'डा. सुनिल श्रेष्ठ',
    specialty: 'हृदय रोग',
    date: 'आज',
    time: '३:३० PM',
    consultationType: 'video',
    status: 'upcoming',
  ),
  AppointmentModel(
    doctorName: 'डा. प्रिया पौडेल',
    specialty: 'सामान्य चिकित्सक',
    date: 'भोलि',
    time: '११:०० AM',
    consultationType: 'chat',
    status: 'upcoming',
  ),
  AppointmentModel(
    doctorName: 'डा. अर्जुन थापा',
    specialty: 'हड्डी विशेषज्ञ',
    date: '२०८१ पुष १०',
    time: '२:०० PM',
    consultationType: 'video',
    status: 'completed',
  ),
  AppointmentModel(
    doctorName: 'डा. रमेश कार्की',
    specialty: 'छाला रोग विशेषज्ञ',
    date: '२०८१ मंसिर २५',
    time: '१०:३० AM',
    consultationType: 'chat',
    status: 'completed',
  ),
  AppointmentModel(
    doctorName: 'डा. सीता राई',
    specialty: 'नेत्र विशेषज्ञ',
    date: '२०८१ मंसिर १५',
    time: '४:०० PM',
    consultationType: 'video',
    status: 'cancelled',
  ),
];

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _filtered(String status) =>
      _allAppointments.where((a) => a.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          _buildAppBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_filtered('upcoming'), 'upcoming'),
                _buildList(_filtered('completed'), 'completed'),
                _buildList(_filtered('cancelled'), 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFFB71C1C),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'मेरा अपोइन्टमेन्ट',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, size: 13, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '4G',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFB71C1C),
        indicatorWeight: 3,
        labelColor: const Color(0xFFB71C1C),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'आउँदो'),
          Tab(text: 'सम्पन्न'),
          Tab(text: 'रद्द'),
        ],
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'कुनै अपोइन्टमेन्ट छैन',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) =>
          _buildAppointmentCard(appointments[index]),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt) {
    final initials = appt.doctorName.length >= 5
        ? appt.doctorName.substring(3, 5)
        : appt.doctorName.substring(0, 2);

    final isVideo = appt.consultationType == 'video';
    final isUpcoming = appt.status == 'upcoming';
    final isCancelled = appt.status == 'cancelled';

    Color statusBgColor;
    String statusText;
    if (appt.status == 'upcoming') {
      statusBgColor = const Color(0xFFB71C1C);
      statusText = 'आउँदो';
    } else if (appt.status == 'completed') {
      statusBgColor = const Color(0xFF2E7D32);
      statusText = 'सम्पन्न';
    } else {
      statusBgColor = Colors.grey.shade500;
      statusText = 'रद्द';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFCE4EC),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFFB71C1C),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.doctorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appt.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${appt.date}, ${appt.time}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isVideo
                                ? Icons.videocam
                                : Icons.chat_bubble_outline,
                            size: 13,
                            color: const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            appt.consultationType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons for upcoming
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        isVideo ? Icons.videocam : Icons.chat_bubble,
                        size: 16,
                      ),
                      label: const Text(
                        'Join',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(
                          color: Color(0xFFDDDDDD),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'रद्द',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Rebooking button for cancelled
            if (isCancelled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Color(0xFFB71C1C),
                  ),
                  label: const Text(
                    'पुनः बुक गर्नुहोस्',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(
                      color: Color(0xFFB71C1C),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
