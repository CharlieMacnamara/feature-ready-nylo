import 'dart:async';
import '/app/controllers/controller.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/app/repositories/household_repository.dart';
import '/app/repositories/chore_repository.dart';
import '/app/models/household.dart';
import '/app/models/chore.dart';
import '/resources/pages/login_page.dart';

class DashboardPageController extends Controller {
  // Repository dependencies
  late final HouseholdRepository _householdRepo;
  late final ChoreRepository _choreRepo;
  
  // Supabase Realtime subscriptions
  RealtimeChannel? _choreChannel;
  RealtimeChannel? _householdChannel;
  
  // Local state storage for safer access
  final Map<String, dynamic> _localState = {};
  
  @override
  construct(BuildContext context) {
    super.construct(context);
    
    // Initialize repositories
    _householdRepo = HouseholdRepository();
    _choreRepo = ChoreRepository();
    
    // Initialize state variables
    _localState['isLoadingHouseholds'] = false;
    _localState['isLoadingChores'] = false;
    _localState['hasError'] = false;
    _localState['errorMessage'] = '';
    _localState['households'] = <Household>[];
    _localState['chores'] = <Chore>[];
    _localState['userData'] = {};
    
    // Update Nylo state
    updateState('isLoadingHouseholds', data: false);
    updateState('isLoadingChores', data: false);
    updateState('hasError', data: false);
    updateState('errorMessage', data: '');
    updateState('households', data: <Household>[]);
    updateState('chores', data: <Chore>[]);
    updateState('userData', data: {});
    
    // Load initial data and setup Realtime
    _loadUserData();
    _setupRealtimeSubscriptions();
  }
  
  // Safe method to update both local and Nylo state
  void safeUpdateState(String key, {required dynamic data}) {
    // Update local state
    _localState[key] = data;
    
    // Update Nylo state
    updateState(key, data: data);
  }
  
  // Safe method to get state
  dynamic safeGetState(String key, [dynamic defaultValue]) {
    return _localState.containsKey(key) ? _localState[key] : defaultValue;
  }
  
  /// Load authenticated user data
  Future<void> _loadUserData() async {
    try {
      // Get authenticated user data using Nylo's Auth helper
      final userData = await Auth.data();
      if (userData != null) {
        safeUpdateState('userData', data: userData);
        
        // Load user households and chores
        await fetchUserHouseholds();
        await fetchAssignedChores();
      }
    } catch (e) {
      printError('Error loading user data: $e');
      safeUpdateState('hasError', data: true);
      safeUpdateState('errorMessage', data: 'Failed to load user data');
    }
  }
  
  /// Fetch households the user belongs to
  Future<void> fetchUserHouseholds() async {
    safeUpdateState('isLoadingHouseholds', data: true);
    
    try {
      final userData = await Auth.data();
      if (userData == null || userData['user'] == null) return;
      
      final userId = userData['user']['id'];
      if (userId == null) return;
      
      final households = await _householdRepo.fetchUserHouseholds(userId);
      safeUpdateState('households', data: households);
    } catch (e) {
      printError('Error fetching households: $e');
      safeUpdateState('hasError', data: true);
      safeUpdateState('errorMessage', data: 'Failed to load households');
    } finally {
      safeUpdateState('isLoadingHouseholds', data: false);
    }
  }
  
  /// Fetch chores assigned to the user
  Future<void> fetchAssignedChores() async {
    safeUpdateState('isLoadingChores', data: true);
    
    try {
      // Default empty list
      List<Household> households = [];
      
      // Get households from local state
      final currentState = safeGetState('households', <Household>[]);
      if (currentState is List) {
        try {
          households = List<Household>.from(currentState);
        } catch (e) {
          printError('Error casting households: $e');
        }
      }
      
      List<Chore> allChores = [];
      
      // Fetch chores for each household
      for (var household in households) {
        if (household.id != null) {
          final chores = await _choreRepo.fetchByHousehold(household.id!);
          allChores.addAll(chores);
        }
      }
      
      safeUpdateState('chores', data: allChores);
    } catch (e) {
      printError('Error fetching chores: $e');
      safeUpdateState('hasError', data: true);
      safeUpdateState('errorMessage', data: 'Failed to load chores');
    } finally {
      safeUpdateState('isLoadingChores', data: false);
    }
  }
  
  /// Setup Realtime subscriptions for live updates
  void _setupRealtimeSubscriptions() {
    try {
      final client = Supabase.instance.client;
      
      // Unsubscribe from existing channels if any
      _cleanupRealtimeSubscriptions();
      
      // Subscribe to chore updates
      _choreChannel = client.channel('public:chores')
        .onPostgresChanges(
          schema: 'public',
          table: 'chore_definitions',
          event: PostgresChangeEvent.all,
          callback: (payload) {
            fetchAssignedChores();
          },
        )
        .subscribe();
      
      // Subscribe to household updates
      _householdChannel = client.channel('public:households')
        .onPostgresChanges(
          schema: 'public',
          table: 'households',
          event: PostgresChangeEvent.all,
          callback: (payload) {
            fetchUserHouseholds();
          },
        )
        .subscribe();
    } catch (e) {
      printError('Error setting up realtime subscriptions: $e');
    }
  }
  
  /// Clean up Realtime subscriptions
  void _cleanupRealtimeSubscriptions() {
    if (_choreChannel != null) {
      _choreChannel!.unsubscribe();
    }
    
    if (_householdChannel != null) {
      _householdChannel!.unsubscribe();
    }
  }
  
  /// Mark a chore as complete
  Future<void> markChoreComplete(String choreId) async {
    try {
      await _choreRepo.markComplete(choreId);
      // Realtime will trigger a refresh
    } catch (e) {
      printError('Error completing chore: $e');
      showToastDanger(
        title: "Error",
        description: "Failed to mark chore as complete"
      );
    }
  }
  
  /// Create a new household
  Future<void> createHousehold(String name, String description) async {
    try {
      final userData = await Auth.data();
      if (userData == null || userData['user'] == null) return;
      
      final userId = userData['user']['id'];
      if (userId == null) return;
      
      final household = Household(
        name: name,
        description: description,
        ownerId: userId,
      );
      
      await _householdRepo.createHousehold(household);
      // Realtime should trigger a refresh
      showToastSuccess(
        title: "Success",
        description: "Household created successfully"
      );
    } catch (e) {
      printError('Error creating household: $e');
      showToastDanger(
        title: "Error",
        description: "Failed to create household"
      );
    }
  }
  
  /// Logout the user
  Future<void> logout() async {
    safeUpdateState('isLoading', data: true);
    
    try {
      // Clean up subscriptions
      _cleanupRealtimeSubscriptions();
      
      // Logout using Nylo's Auth helper
      await Auth.logout();
      
      // Navigate to login page
      await routeTo(LoginPagePage.path);
    } catch (e) {
      printError('Error logging out: $e');
      showToastDanger(
        title: "Error",
        description: "Failed to logout. Please try again."
      );
    } finally {
      safeUpdateState('isLoading', data: false);
    }
  }
  
  /// Get user display name
  String getUserDisplayName() {
    // Default value for user data
    Map<String, dynamic> userData = {};
    
    // Get user data from local state
    final currentState = safeGetState('userData', {});
    if (currentState is Map) {
      try {
        userData = Map<String, dynamic>.from(currentState);
      } catch (e) {
        printError('Error casting userData: $e');
      }
    }
    
    if (userData.containsKey('user') && userData['user'] is Map) {
      final userMap = userData['user'] as Map;
      final email = userMap['email'];
      if (email != null) {
        return email.toString();
      }
    }
    
    return 'User';
  }
} 
