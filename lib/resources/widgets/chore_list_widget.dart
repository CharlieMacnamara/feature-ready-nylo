import 'package:flutter/material.dart';
import '/app/models/chore.dart';
import 'package:intl/intl.dart';

class ChoreList extends StatefulWidget {
  final List<Chore> chores;
  final bool isLoading;
  final Function(Chore) onChoreTap;
  final Function(Chore) onChoreComplete;
  
  const ChoreList({
    super.key,
    required this.chores,
    required this.isLoading,
    required this.onChoreTap,
    required this.onChoreComplete,
  });

  @override
  createState() => _ChoreListState();
}

class _ChoreListState extends State<ChoreList> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (widget.chores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No chores found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All caught up or no chores assigned',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group chores by household ID
    final groupedChores = groupChoresByHousehold();
    
    // Build the list of chores grouped by household
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedChores.length,
      itemBuilder: (context, index) {
        final householdId = groupedChores.keys.elementAt(index);
        final chores = groupedChores[householdId]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'Household: ${householdId.substring(0, 8)}...', // Simplified for now, ideally show household name
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chores.length,
              itemBuilder: (context, index) => _buildChoreCard(chores[index]),
            ),
          ],
        );
      },
    );
  }
  
  // Group chores by household ID
  Map<String, List<Chore>> groupChoresByHousehold() {
    final Map<String, List<Chore>> grouped = {};
    for (var chore in widget.chores) {
      if (!grouped.containsKey(chore.householdId)) {
        grouped[chore.householdId] = [];
      }
      grouped[chore.householdId]!.add(chore);
    }
    
    // Sort each group by due date
    for (var householdId in grouped.keys) {
      grouped[householdId]!.sort((a, b) {
        final aDueDate = a.dueDate;
        final bDueDate = b.dueDate;
        
        if (aDueDate == null && bDueDate == null) return 0;
        if (aDueDate == null) return 1;
        if (bDueDate == null) return -1;
        
        return aDueDate.compareTo(bDueDate);
      });
    }
    
    return grouped;
  }
  
  Widget _buildChoreCard(Chore chore) {
    // Format the due date
    String? dueDateText;
    if (chore.dueDate != null) {
      final formatter = DateFormat('MMM d, yyyy');
      dueDateText = formatter.format(chore.dueDate!);
      
      // Check if due date is today
      final today = DateTime.now();
      final dueDate = chore.dueDate!;
      if (dueDate.year == today.year && 
          dueDate.month == today.month && 
          dueDate.day == today.day) {
        dueDateText = 'Today';
      }
      // Check if due date is tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      if (dueDate.year == tomorrow.year && 
          dueDate.month == tomorrow.month && 
          dueDate.day == tomorrow.day) {
        dueDateText = 'Tomorrow';
      }
    }
    
    // Determine if the chore is overdue
    bool isOverdue = false;
    if (chore.dueDate != null && !chore.completed!) {
      isOverdue = chore.dueDate!.isBefore(DateTime.now());
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () => widget.onChoreTap(chore),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox for completion status
              IconButton(
                icon: Icon(
                  chore.completed! 
                      ? Icons.check_circle 
                      : Icons.check_circle_outline,
                  color: chore.completed! 
                      ? Colors.green 
                      : isOverdue 
                          ? Colors.red 
                          : Colors.grey,
                ),
                onPressed: () => widget.onChoreComplete(chore),
              ),
              const SizedBox(width: 8),
              // Chore details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chore.title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        decoration: chore.completed! 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: chore.completed! 
                            ? Colors.grey 
                            : isOverdue 
                                ? Colors.red 
                                : null,
                      ),
                    ),
                    if (chore.description != null && chore.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chore.description!,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (dueDateText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isOverdue ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dueDateText,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: isOverdue ? Colors.red : Colors.grey,
                                fontWeight: isOverdue ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Points indicator if available
              if (chore.points != null && chore.points! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chore.points} pts',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
