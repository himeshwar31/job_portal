import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).loadApplicants();
    });
  }

  void _showScheduleDialog(Application app) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Schedule Interview',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'For: ${app.applicantName ?? 'Unknown'}',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF4F46E5),
                            surface: Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text('Pick Date',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<ApplicationProvider>(context, listen: false);
              await provider.scheduleInterview(
                app.id,
                selectedDate.toIso8601String(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Interview scheduled! 📅'),
                    backgroundColor: Color(0xFF22C55E),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Schedule',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Applicants',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<ApplicationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  );
                }

                if (provider.applicants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            color: Colors.white.withOpacity(0.2), size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No applicants yet',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadApplicants(),
                  color: const Color(0xFF4F46E5),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.applicants.length,
                    itemBuilder: (context, index) =>
                        _buildApplicantCard(provider.applicants[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Application app) {
    Color matchColor;
    if (app.matchScore >= 70) {
      matchColor = const Color(0xFF22C55E);
    } else if (app.matchScore >= 40) {
      matchColor = const Color(0xFFF59E0B);
    } else {
      matchColor = const Color(0xFFEF4444);
    }

    Color statusColor;
    switch (app.status) {
      case 'accepted':
        statusColor = const Color(0xFF22C55E);
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (app.applicantName ?? '?')[0].toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName ?? 'Unknown',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Applied for: ${app.jobTitle ?? ''}',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Match score badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${app.matchScore.toInt()}%',
                  style: GoogleFonts.inter(
                    color: matchColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Skills
          if (app.applicantSkills != null && app.applicantSkills!.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: app.applicantSkills!.map((s) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF818CF8),
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),

          // Education & Experience
          if (app.applicantEducation != null &&
              app.applicantEducation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    app.applicantEducation!,
                    style: GoogleFonts.inter(
                        color: Colors.white38, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Status & Actions
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (app.status == 'pending') ...[
                _buildActionButton(
                  'Accept',
                  Icons.check_rounded,
                  const Color(0xFF22C55E),
                  () async {
                    final provider =
                        Provider.of<ApplicationProvider>(context, listen: false);
                    await provider.updateStatus(app.id, 'accepted');
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  'Reject',
                  Icons.close_rounded,
                  const Color(0xFFEF4444),
                  () async {
                    final provider =
                        Provider.of<ApplicationProvider>(context, listen: false);
                    await provider.updateStatus(app.id, 'rejected');
                  },
                ),
                const SizedBox(width: 8),
              ],
              _buildActionButton(
                'Schedule',
                Icons.calendar_today_rounded,
                const Color(0xFF4F46E5),
                () => _showScheduleDialog(app),
              ),
            ],
          ),

          // Interview date
          if (app.interviewDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event, color: Color(0xFF22C55E), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Interview: ${app.interviewDate!.split('T').first}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF22C55E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
