import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/repairService/repair_service.dart';

class RepairRequestsScreen extends ConsumerStatefulWidget {
  const RepairRequestsScreen({super.key});

  @override
  ConsumerState<RepairRequestsScreen> createState() =>
      _RepairRequestsScreenState();
}

class _RepairRequestsScreenState extends ConsumerState<RepairRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inProgressAsync = ref.watch(inProgressRequestsProvider);
    final completedAsync = ref.watch(completedRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomTitle(
            text: 'Mes demandes de service', textColor: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 18),
                      const SizedBox(width: 8),
                      const Text('En cours'),
                      inProgressAsync.whenData((data) {
                            return data.isNotEmpty
                                ? Row(
                                    children: [
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${data.length}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          }).value ??
                          const SizedBox.shrink(),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 18),
                      const SizedBox(width: 8),
                      const Text('Terminé'),
                      completedAsync.whenData((data) {
                            return data.isNotEmpty
                                ? Row(
                                    children: [
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${data.length}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          }).value ??
                          const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(inProgressRequestsProvider);
          ref.refresh(completedRequestsProvider);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInProgressTab(inProgressAsync),
            _buildCompletedTab(completedAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressTab(
    AsyncValue<List<ServiceRequestModel>> inProgressAsync,
  ) {
    return inProgressAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.engineering_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune demande en cours',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tirez vers le bas pour actualiser',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _RequestCard(request: request);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTab(
    AsyncValue<List<ServiceRequestModel>> completedAsync,
  ) {
    return completedAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune demande terminée',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _RequestCard(request: request);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequestModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: primaryColor.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDetailsModal(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getServiceIcon(request.serviceType),
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.serviceType,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          request.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: request.status ?? 'pending'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Date:',
                value: request.scheduledDate,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.access_time,
                label: 'Heure:',
                value: request.scheduledTime,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Adresse:',
                value: request.address,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestDetailsModal(request: request),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plomberie':
        return Icons.plumbing;
      case 'électricité':
        return Icons.electric_bolt;
      case 'menuiserie':
        return Icons.handyman;
      case 'climatisation':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getStatusLabel(status),
        style: GoogleFonts.poppins(
          color: getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RequestDetailsModal extends StatelessWidget {
  final ServiceRequestModel request;

  const _RequestDetailsModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Détails de la demande',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusChip(status: request.status ?? 'pending'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailItem(
                    icon: _getServiceIcon(request.serviceType),
                    title: 'Type de service',
                    value: request.serviceType,
                  ),
                  _DetailItem(
                    icon: Icons.person,
                    title: 'Nom',
                    value: request.name,
                  ),
                  _DetailItem(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: request.phone,
                  ),
                  _DetailItem(
                    icon: Icons.location_on,
                    title: 'Adresse',
                    value: request.address,
                  ),
                  _DetailItem(
                    icon: Icons.calendar_today,
                    title: 'Date prévue',
                    value: request.scheduledDate,
                  ),
                  _DetailItem(
                    icon: Icons.access_time,
                    title: 'Heure prévue',
                    value: request.scheduledTime,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plomberie':
        return Icons.plumbing;
      case 'électricité':
        return Icons.electric_bolt;
      case 'menuiserie':
        return Icons.handyman;
      case 'climatisation':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
