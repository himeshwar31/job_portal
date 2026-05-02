import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/application_provider.dart';
import 'post_job_screen.dart';
import 'applicants_screen.dart';
import '../chat/conversations_screen.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadJobs();
      Provider.of<ApplicationProvider>(context, listen: false).loadApplicants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardTab(),
      const ApplicantsScreen(),
      const ConversationsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF4F46E5),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded), label: 'Applicants'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostJobScreen()),
                );
                if (mounted) {
                  Provider.of<JobProvider>(context, listen: false).loadJobs();
                }
              },
              backgroundColor: const Color(0xFF4F46E5),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Post Job',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        'hello, ${auth.user?.name.split(' ').first ?? ''} 👋',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recruiter Dashboard',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.white54),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    final auth =
                        Provider.of<AuthProvider>(context, listen: false);
                    await auth.logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                  icon:
                      const Icon(Icons.logout_rounded, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Consumer2<JobProvider, ApplicationProvider>(
              builder: (context, jobProv, appProv, _) {
                final myJobs = jobProv.jobs
                    .where((j) =>
                        j.recruiterId ==
                        (Provider.of<AuthProvider>(context, listen: false)
                                .user
                                ?.id ??
                            0))
                    .length;

                return Row(
                  children: [
                    _buildStatCard('Posted Jobs', myJobs.toString(),
                        Icons.work_rounded, const Color(0xFF4F46E5)),
                    const SizedBox(width: 12),
                    _buildStatCard(
                        'Applicants',
                        appProv.applicants.length.toString(),
                        Icons.people_rounded,
                        const Color(0xFF14B8A6)),
                    const SizedBox(width: 12),
                    _buildStatCard(
                        'Accepted',
                        appProv.applicants
                            .where((a) => a.status == 'accepted')
                            .length
                            .toString(),
                        Icons.check_circle_rounded,
                        const Color(0xFF22C55E)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Recent Jobs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your Posted Jobs',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, _) {
                if (jobProvider.isLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  );
                }

                final userId =
                    Provider.of<AuthProvider>(context, listen: false)
                        .user
                        ?.id;
                final myJobs = jobProvider.jobs
                    .where((j) => j.recruiterId == userId)
                    .toList();

                if (myJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off_rounded,
                            color: Colors.white.withOpacity(0.2), size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs posted yet',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: myJobs.length,
                  itemBuilder: (context, index) {
                    final job = myJobs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                job.location,
                                style: GoogleFonts.inter(
                                    color: Colors.white38, fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.payments_outlined,
                                  color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.salary,
                                  style: GoogleFonts.inter(
                                      color: Colors.white38, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children:
                                job.requiredSkills.take(3).map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF818CF8),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
