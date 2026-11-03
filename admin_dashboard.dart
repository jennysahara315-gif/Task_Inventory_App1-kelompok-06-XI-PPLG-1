import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final dynamic user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'All';

  bool get _isMainAdmin => widget.user.username == 'admin1';

  @override
  void initState() {
    super.initState();
  }

  int get pendingCount => globalItemList.where((i) => i.status == 'Pending').length;
  int get processCount => globalItemList.where((i) => i.status == 'Proses').length;
  int get completedCount => globalItemList.where((i) => i.status == 'Selesai').length;
  
  int get taskCount => globalItemList.where((i) => i.category == 'Task').length;
  int get inventoryCount => globalItemList.where((i) => i.category == 'Inventaris').length;

  List<dynamic> get filteredItems {
    if (_selectedFilter == 'All') return globalItemList;
    return globalItemList.where((i) => i.status == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFEF4444);
      case 'Proses':
        return const Color(0xFFF59E0B);
      case 'Selesai':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  // Memperbaiki logout agar kembali bersih ke halaman login tanpa layar hitam
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _changeStatus(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  item.status = 'Pending';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Proses', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  item.status = 'Proses';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Selesai', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  item.status = 'Selesai';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteItem(dynamic item) {
    setState(() {
      globalItemList.remove(item);
    });
  }

  void _confirmDeleteAccount(dynamic accUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Text('Apakah Anda yakin ingin menghapus akun ${accUser.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                registeredUsers.remove(accUser);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountApproval() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Persetujuan Akun Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (registeredUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Tidak ada akun yang menunggu persetujuan.', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...registeredUsers.map((accUser) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accUser.username,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${accUser.role} | Status: ${accUser.status}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            accUser.status = 'Active';
                          });
                        },
                        child: const Text('Approve', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteAccount(accUser),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9A3412), Color(0xFFC2410C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Admin Panel', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  widget.user.username,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Kelola data Task & Inventory.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _buildMetricCard('Need Action', '$pendingCount', Icons.pending_actions, const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _buildMetricCard('In Progress', '$processCount', Icons.sync, const Color(0xFFF59E0B)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildMetricCard('Completed', '$completedCount', Icons.check_circle, const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildMetricCard('Total Data', '${globalItemList.length}', Icons.storage, const Color(0xFF0284C7)),
            ],
          ),

          const SizedBox(height: 24),

          const Text('Distribusi Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildLegendDot('Task', taskCount, const Color(0xFF0284C7)),
                const SizedBox(height: 14),
                _buildLegendDot('Inventaris', inventoryCount, const Color(0xFFD97706)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Filter Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Proses'),
                _buildFilterChip('Selesai'),
                if (_isMainAdmin) _buildFilterChip('Approve'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_selectedFilter == 'Approve' && _isMainAdmin) ...[
            _buildAccountApproval(),
            const SizedBox(height: 20),
          ],

          if (_selectedFilter != 'Approve') ...[
            const Text('Data Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (filteredItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Tidak ada data.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

            ...filteredItems.map((item) {
              final statusColor = _getStatusColor(item.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: ${item.category} | Status: ${item.status}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      tooltip: 'Ubah Status',
                      onPressed: () => _changeStatus(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus Item',
                      onPressed: () => _deleteItem(item),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(user: widget.user)),
          );

          if (result == true) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Entry'),
        backgroundColor: const Color(0xFFC2410C),
      ),
    );
  }
}