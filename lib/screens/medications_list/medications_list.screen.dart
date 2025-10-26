import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/database/app_database.dart';
import 'package:med_track_v2/screens/add_medication/add_medication.screen.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/viewmodels/medications_list_viewmodel.dart';
import 'package:med_track_v2/widgets/fab/fab.widget.dart';
import 'package:provider/provider.dart';

class MedicationsListScreen extends StatefulWidget {
  const MedicationsListScreen({super.key});

  @override
  State<MedicationsListScreen> createState() => _MedicationsListScreenState();
}

class _MedicationsListScreenState extends State<MedicationsListScreen> {
  late MedicationsListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final medicationService = context.read<MedicationService>();
    _viewModel = MedicationsListViewModel(medicationService);
    _viewModel.loadMedications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: CustomFloatingActionButton(
          onPressed: _onAddMedication,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      title: Text(
        'All Medications',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.darkBg,
        ),
      ),
      actions: [
        Consumer<MedicationsListViewModel>(
          builder: (context, viewModel, _) {
            return PopupMenuButton<MedicationFilter>(
              icon: Icon(
                Icons.filter_list,
                color: isDark ? Colors.white : AppColors.darkBg,
              ),
              onSelected: (filter) => viewModel.setFilter(filter),
              itemBuilder: (context) => [
                _buildFilterMenuItem(
                  MedicationFilter.all,
                  'All Medications',
                  Icons.medication,
                ),
                _buildFilterMenuItem(
                  MedicationFilter.active,
                  'Active Only',
                  Icons.check_circle,
                ),
                _buildFilterMenuItem(
                  MedicationFilter.inactive,
                  'Inactive Only',
                  Icons.cancel,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  PopupMenuItem<MedicationFilter> _buildFilterMenuItem(
    MedicationFilter filter,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<MedicationFilter>(
      value: filter,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<MedicationsListViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorView(viewModel.errorMessage!);
        }

        return Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(viewModel),
            Expanded(
              child: viewModel.hasMedications
                  ? _buildMedicationsList(viewModel)
                  : _buildEmptyState(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _viewModel.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search medications...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          suffixIcon: Consumer<MedicationsListViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.searchQuery.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearSearch();
                },
              );
            },
          ),
          filled: true,
          fillColor: isDark
              ? AppColors.darkSecondary.withValues(alpha: 0.5)
              : AppColors.lightSecondary.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MedicationsListViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'All',
            isSelected: viewModel.filter == MedicationFilter.all,
            onTap: () => viewModel.setFilter(MedicationFilter.all),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Active',
            isSelected: viewModel.filter == MedicationFilter.active,
            onTap: () => viewModel.setFilter(MedicationFilter.active),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Inactive',
            isSelected: viewModel.filter == MedicationFilter.inactive,
            onTap: () => viewModel.setFilter(MedicationFilter.inactive),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
              : (isDark
                  ? AppColors.darkSecondary.withValues(alpha: 0.5)
                  : AppColors.lightSecondary.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsList(MedicationsListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        itemCount: viewModel.medications.length,
        itemBuilder: (context, index) {
          final medication = viewModel.medications[index];
          return _buildMedicationCard(medication);
        },
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppColors.darkSecondary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkAccent.withValues(alpha: 0.3)
              : AppColors.lightSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _onMedicationTap(medication),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMedicationIcon(medication),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.darkBg,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medication.dosageAmount} ${medication.dosageUnit}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(medication),
                ],
              ),
              const SizedBox(height: 12),
              _buildMedicationInfo(medication),
              const SizedBox(height: 12),
              _buildActionButtons(medication),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationIcon(Medication medication) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medication.isActive
            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1)
            : (isDark ? AppColors.darkAccent : AppColors.lightSecondary)
                .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.medication,
        color: medication.isActive
            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
            : (isDark ? Colors.white54 : Colors.black38),
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(Medication medication) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: medication.isActive
            ? const Color(0xFF4ECDC4).withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        medication.isActive ? 'Active' : 'Inactive',
        style: theme.textTheme.bodySmall?.copyWith(
          color: medication.isActive ? const Color(0xFF4ECDC4) : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMedicationInfo(Medication medication) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
            const SizedBox(width: 8),
            Text(
              _formatFrequency(medication),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        if (medication.selectedDays != null && medication.selectedDays!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 4,
              children: medication.selectedDays!.map((day) {
                return Chip(
                  label: Text(
                    day.shortName,
                    style: theme.textTheme.bodySmall,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(Medication medication) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _onToggleActive(medication),
          icon: Icon(
            medication.isActive ? Icons.pause_circle : Icons.play_circle,
            size: 18,
          ),
          label: Text(medication.isActive ? 'Deactivate' : 'Activate'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _onEditMedication(medication),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No medications found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first medication to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _viewModel.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatFrequency(Medication medication) {
    switch (medication.frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'specificDays':
        return 'Specific days';
      default:
        return medication.frequency;
    }
  }

  void _onAddMedication() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMedicationScreen(),
      ),
    );
  }

  void _onMedicationTap(Medication medication) {
    HapticFeedback.selectionClick();
    // TODO: Navigate to medication details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details for ${medication.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onToggleActive(Medication medication) async {
    HapticFeedback.lightImpact();
    await _viewModel.toggleMedicationActive(medication);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${medication.name} ${medication.isActive ? 'deactivated' : 'activated'}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onEditMedication(Medication medication) {
    HapticFeedback.selectionClick();
    // TODO: Navigate to edit medication screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${medication.name} - Coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
