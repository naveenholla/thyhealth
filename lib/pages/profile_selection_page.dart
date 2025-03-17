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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  List<dynamic>? _patients;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final patients = await _reportService.getAllPatients();
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load patients: ${e.toString()}');
    }
  }

  Future<void> _refreshPatients() async {
    await _loadPatients();
  }

  void _showError(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deletePatient(dynamic patient) async {
    try {
      await _reportService.deletePatient(patient.id);
      if (!mounted) return;
      setState(() {
        _patients?.removeWhere((p) => p.id == patient.id);
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to delete patient: ${e.toString()}');
      rethrow;
    }
  }

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Patient Profiles'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToAnalyzer(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child:
            _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: _refreshPatients),
                    SliverToBoxAdapter(child: _buildProfileList()),
                  ],
                ),
      ),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profiles')),
      body: _buildProfileList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAnalyzer(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileList() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_patients == null) {
      return const Center(child: Text('Error loading patients'));
    }

    if (_patients!.isEmpty) {
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
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _patients!.length,
        itemBuilder: (context, index) {
          final patient = _patients![index];
          return Dismissible(
            key: Key(patient.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: CupertinoColors.destructiveRed,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              bool delete = false;
              await showCupertinoDialog(
                context: context,
                builder:
                    (context) => CupertinoAlertDialog(
                      title: const Text('Delete Patient'),
                      content: Text(
                        'Are you sure you want to delete ${patient.name} and all their reports? This action cannot be undone.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            delete = true;
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                        CupertinoDialogAction(
                          child: const Text('Cancel'),
                          onPressed: () {
                            delete = false;
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
              );
              if (delete) {
                try {
                  await _deletePatient(patient);
                  return true;
                } catch (e) {
                  return false;
                }
              }
              return false;
            },
            child: CupertinoListTile(
              title: Text(patient.name),
              subtitle: Text('Created: ${_formatDate(patient.createdAt)}'),
              trailing: const CupertinoListTileChevron(),
              onTap: () => _navigateToProfile(patient),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: _patients!.length,
        itemBuilder: (context, index) {
          final patient = _patients![index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(patient.name),
            subtitle: Text('Created: ${_formatDate(patient.createdAt)}'),
            onTap: () => _navigateToProfile(patient),
          );
        },
      );
    }
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
          ? CupertinoPageRoute(builder: (context) => const ImageAnalyzerPage())
          : MaterialPageRoute(builder: (context) => const ImageAnalyzerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }
}
