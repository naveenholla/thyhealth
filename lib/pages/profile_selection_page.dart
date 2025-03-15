import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../services/report_service.dart';
import '../pages/patient_profile_page.dart';
import '../pages/image_analyzer_page.dart';

class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  final ReportService _reportService = ReportService();

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Patient Profiles'),
      ),
      child: SafeArea(
        child: _buildProfileList(),
      ),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profiles'),
      ),
      body: _buildProfileList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAnalyzer(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileList() {
    return FutureBuilder<List<dynamic>>(
      future: _reportService.getAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final patients = snapshot.data ?? [];

        if (patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No patient profiles found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                if (Platform.isIOS)
                  CupertinoButton.filled(
                    onPressed: () => _navigateToAnalyzer(),
                    child: const Text('Upload Medical Report'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _navigateToAnalyzer(),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Medical Report'),
                  ),
              ],
            ),
          );
        }

        if (Platform.isIOS) {
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return CupertinoListTile(
                title: Text(patient.name),
                subtitle: Text('Created: ${_formatDate(patient.createdAt)}'),
                trailing: const CupertinoListTileChevron(),
                onTap: () => _navigateToProfile(patient),
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patient.name),
                subtitle: Text('Created: ${_formatDate(patient.createdAt)}'),
                onTap: () => _navigateToProfile(patient),
              );
            },
          );
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToProfile(dynamic patient) {
    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (context) => PatientProfilePage(patient: patient),
            )
          : MaterialPageRoute(
              builder: (context) => PatientProfilePage(patient: patient),
            ),
    );
  }

  void _navigateToAnalyzer() {
    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (context) => const ImageAnalyzerPage(),
            )
          : MaterialPageRoute(
              builder: (context) => const ImageAnalyzerPage(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }
} 