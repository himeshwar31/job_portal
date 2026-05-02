import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _skillController = TextEditingController();
  final List<String> _skills = [];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _skillController.dispose();
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

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one required skill'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final success = await jobProvider.postJob(
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      description: _descriptionController.text.trim(),
      requiredSkills: _skills,
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job posted successfully! 🎉'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post a Job',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                controller: _titleController,
                label: 'Job Title',
                hint: 'e.g. Senior Flutter Developer',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _companyController,
                label: 'Company Name',
                hint: 'e.g. TechCorp',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _descriptionController,
                label: 'Job Description',
                hint: 'Describe the role, responsibilities, and requirements...',
                icon: Icons.description_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g. Bangalore, India',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _salaryController,
                label: 'Salary Range',
                hint: 'e.g. ₹15,00,000 - ₹25,00,000',
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 24),

              // Skills
              Text(
                'Required Skills',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a skill...',
                        hintStyle: GoogleFonts.inter(color: Colors.white30),
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _addSkill,
                      icon:
                          const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteIconColor: Colors.white54,
                    onDeleted: () =>
                        setState(() => _skills.remove(skill)),
                    side: BorderSide(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Post Button
              Consumer<JobProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _postJob,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.publish_rounded),
                      label: Text(
                        provider.isLoading ? 'Posting...' : 'Post Job',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor:
                            const Color(0xFF4F46E5).withOpacity(0.4),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? 'This field is required' : null,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: Colors.white54),
        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.white38)
            : null,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
