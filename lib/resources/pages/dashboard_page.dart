import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/dashboard_page_controller.dart';
import '/resources/widgets/household_list_widget.dart';
import '/resources/widgets/chore_list_widget.dart';
import '/app/models/household.dart';
import '/app/models/chore.dart';

class DashboardPage extends NyStatefulWidget<DashboardPageController> {
  static RouteView path = ("/dashboard", (_) => DashboardPage());
  
  DashboardPage({super.key}) : super(child: () => _DashboardPageState());
}

class _DashboardPageState extends NyPage<DashboardPage> {
  /// [DashboardPageController] controller
  DashboardPageController get controller => widget.controller;
  
  // State variables from controller
  List<Household> _households = [];
  List<Chore> _chores = [];
  bool _isLoadingHouseholds = false;
  bool _isLoadingChores = false;

  @override
  get init => () {
    // Initialize state by grabbing the current values from controller
    setState(() {
      _updateLocalState();
    });
  };
  
  @override
  void stateUpdated(data) {
    // Called when state is updated by the controller
    setState(() {
      _updateLocalState();
    });
  }
  
  void _updateLocalState() {
    try {
      // Get state values with fallbacks to defaults using safeGetState
      final householdsData = controller.safeGetState('households', []);
      if (householdsData != null && householdsData is List) {
        _households = List<Household>.from(householdsData);
      } else {
        _households = [];
      }
      
      final choresData = controller.safeGetState('chores', []);
      if (choresData != null && choresData is List) {
        _chores = List<Chore>.from(choresData);
      } else {
        _chores = [];
      }
      
      final isLoadingHouseholds = controller.safeGetState('isLoadingHouseholds', false);
      _isLoadingHouseholds = isLoadingHouseholds is bool ? isLoadingHouseholds : false;
      
      final isLoadingChores = controller.safeGetState('isLoadingChores', false);
      _isLoadingChores = isLoadingChores is bool ? isLoadingChores : false;
    } catch (e) {
      print('Error updating local state: $e');
      _households = [];
      _chores = [];
      _isLoadingHouseholds = false;
      _isLoadingChores = false;
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchUserHouseholds();
            await controller.fetchAssignedChores();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Welcome, ${controller.getUserDisplayName()}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Households section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Households',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddHouseholdDialog(context),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Household list widget with state data from controller
                HouseholdList(
                  households: _households,
                  isLoading: _isLoadingHouseholds,
                  onHouseholdTap: _navigateToHouseholdDetails,
                ),
                
                const SizedBox(height: 24),
                
                // Chores section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your Chores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Chore list widget with state data from controller
                ChoreList(
                  chores: _chores,
                  isLoading: _isLoadingChores,
                  onChoreTap: _navigateToChoreDetails,
                  onChoreComplete: _handleChoreComplete,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChoreDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  // Navigate to household details (placeholder for now)
  void _navigateToHouseholdDetails(Household household) {
    showToastSuccess(
      title: "Selection",
      description: "Household ${household.name} selected"
    );
    // TODO: Implement household details navigation
    // routeTo(HouseholdDetailsPage.path, data: household);
  }
  
  // Navigate to chore details (placeholder for now)
  void _navigateToChoreDetails(Chore chore) {
    showToastSuccess(
      title: "Selection",
      description: "Chore ${chore.title} selected"
    );
    // TODO: Implement chore details navigation
    // routeTo(ChoreDetailsPage.path, data: chore);
  }
  
  // Handle marking a chore as complete
  void _handleChoreComplete(Chore chore) {
    if (chore.id != null) {
      controller.markChoreComplete(chore.id!);
    }
  }
  
  // Show dialog to add a new household
  void _showAddHouseholdDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Household'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter household name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter household description',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  controller.createHousehold(
                    nameController.text,
                    descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  // Show dialog to add a new chore (placeholder for now)
  void _showAddChoreDialog(BuildContext context) {
    showToastInfo(
      title: "Not Implemented",
      description: "Add chore functionality not yet implemented"
    );
    // TODO: Implement add chore dialog
  }
}
