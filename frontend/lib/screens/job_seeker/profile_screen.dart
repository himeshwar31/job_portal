import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _skillController = TextEditingController();
  late TextEditingController _educationController;
  late TextEditingController _experienceController;
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _skills = List<String>.from(user?.skills ?? []);
    _educationController = TextEditingController(text: user?.education ?? '');
    _experienceController = TextEditingController(text: user?.experience ?? '');
  }

  @override
  void dispose() {
    _skillController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateProfile(
      skills: _skills,
      education: _educationController.text,
      experience: _experienceController.text,
    );
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated! ✅'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit_rounded,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4F46E5).withOpacity(0.15),
                        const Color(0xFF14B8A6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14B8A6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.role == 'job_seeker'
                                    ? 'Job Seeker'
                                    : 'Recruiter',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF14B8A6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Skills Section
                _buildSectionTitle('Skills', Icons.code_rounded),
                const SizedBox(height: 12),
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add a skill...',
                            hintStyle:
                                GoogleFonts.inter(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF4F46E5), size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    return Chip(
                      label: Text(
                        skill,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF818CF8),
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor:
                          const Color(0xFF4F46E5).withOpacity(0.12),
                      deleteIcon: _isEditing
                          ? const Icon(Icons.close, size: 16)
                          : null,
                      deleteIconColor: Colors.white54,
                      onDeleted: _isEditing
                          ? () => setState(() => _skills.remove(skill))
                          : null,
                      side: BorderSide(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),
                if (_skills.isEmpty)
                  Text(
                    'No skills added yet',
                    style: GoogleFonts.inter(
                        color: Colors.white30, fontSize: 13),
                  ),
                const SizedBox(height: 28),

                // Education
                _buildSectionTitle('Education', Icons.school_rounded),
                const SizedBox(height: 12),
                _isEditing
                    ? _buildEditableField(_educationController, 'Your education')
                    : _buildInfoBox(
                        user.education.isNotEmpty
                            ? user.education
                            : 'Not specified',
                      ),
                const SizedBox(height: 28),

                // Experience
                _buildSectionTitle('Experience', Icons.work_history_rounded),
                const SizedBox(height: 12),
                _isEditing
                    ? _buildEditableField(
                        _experienceController, 'Your experience')
                    : _buildInfoBox(
                        user.experience.isNotEmpty
                            ? user.experience
                            : 'Not specified',
                      ),

                if (_isEditing) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        'Save Changes',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF14B8A6), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 3,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
