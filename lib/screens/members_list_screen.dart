import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ashhab_app_bar.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notificationService = NotificationService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Member>> _getMembersStream(bool expiredOnly) {
    return FirebaseFirestore.instance
        .collection('members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Member.fromJson({...doc.data(), 'id': doc.id}))
          .where((member) => !expiredOnly || member.isExpired)
          .where((member) => _searchQuery.isEmpty ||
              member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              member.name.contains(_searchQuery))
          .toList();
    });
  }

  Future<void> _deleteMember(BuildContext context, Member member) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('members')
            .doc(member.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.memberDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeletingMember),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _sendReminder(Member member) async {
    try {
      await _notificationService.sendExpiryReminder(member);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMemberList(bool expiredOnly) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchMembers,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Member>>(
            stream: _getMembersStream(expiredOnly),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.loadingMembers),
                    ],
                  ),
                );
              }

              final members = snapshot.data!;

              if (members.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : expiredOnly
                                ? Icons.warning_outlined
                                : Icons.people_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? l10n.noSearchResults
                            : expiredOnly
                                ? l10n.noExpiredMemberships
                                : l10n.noMembersFound,
                        style: const TextStyle(
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
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: member.isExpired
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: member.isExpired ? Colors.red : Colors.blue,
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(member.phoneNumber),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.expires}: ${member.membershipEndDate.toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: member.isExpired ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.payment, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.paymentStatus}: ${member.paymentStatus.toDisplayString(context)}',
                              ),
                            ],
                          ),
                          if (member.remainingAmount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.remainingAmount}: ${member.remainingAmount}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (member.isExpired)
                            IconButton(
                              icon: const Icon(Icons.notification_important),
                              color: Colors.red,
                              onPressed: () => _sendReminder(member),
                              tooltip: l10n.sendReminder,
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteMember(context, member),
                            tooltip: l10n.deleteMember,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AshhabAppBar(
        title: l10n.allMembers,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people),
              text: l10n.allMembers,
            ),
            Tab(
              icon: const Icon(Icons.warning),
              text: l10n.expiredMembers,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMemberList(false),
            _buildMemberList(true),
          ],
        ),
      ),
    );
  }
} 