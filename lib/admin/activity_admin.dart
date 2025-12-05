
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/pagination_widget.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

bool isSameDate(DateTime d1, DateTime d2) =>
    d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

List<dynamic> filterDealersByDate(
  List<dynamic> dealers,
  String selectedFilter, {
  DateTime? specificDate,
  DateTime? fromDate,
  DateTime? toDate,
}) {
  if (selectedFilter == 'All Dates') return dealers;

  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);

  return dealers.where((dealer) {
    if (dealer['createdAt'] == null) return false;

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(dealer['createdAt']).toLocal();
    } catch (_) {
      return false;
    }

    switch (selectedFilter) {
      case 'Today':
        return isSameDate(createdAt, today);

      case 'Specific Date':
        if (specificDate == null) return true;
        return isSameDate(createdAt, specificDate);

      case 'From-To':
        if (fromDate == null || toDate == null) return true;
        DateTime from = DateTime(fromDate.year, fromDate.month, fromDate.day);
        DateTime to = DateTime(
          toDate.year,
          toDate.month,
          toDate.day,
          23,
          59,
          59,
        );
        return !createdAt.isBefore(from) && !createdAt.isAfter(to);

      default:
        return true;
    }
  }).toList();
}

class AdminActivitylog extends StatefulWidget {
  const AdminActivitylog({super.key});

  @override
  State<AdminActivitylog> createState() => _AdminActivitylogState();
}

class _AdminActivitylogState extends State<AdminActivitylog> {
  List<dynamic> allLogs = []; // raw logs from API

  // Filters
  String _searchQuery = '';
  // String _selectedStatus = 'All';
  String selectedDateFilter = 'All Dates';
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;
  // String _selectedStatusValue = 'All';

  // Pagination
  List<dynamic> pageLogs = [];
  bool isLoading = true;
  int currentPage = 1;
  final int pageSize = 6;
  int totalPages = 1;

  // final Map<String, String> actionTypeMap = {
  //   'All': 'All',
  //   'CREATED DEALERS': 'CREATE_DEALER',
  //   'ACTIVATED DEALERS': 'ACTIVATE_DEALER',
  //   'DEACTIVATED DEALERS': 'DEACTIVATE_DEALER',
  //   'APPROVED DEALERS': 'APPROVE_DEALER',
  //   'REJECTED DEALERS': 'REJECT_DEALER',
  //   'VERIFIED GST': 'VERIFY_GST',
  //   'LOGGED IN': 'LOGIN',
  // };


  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => isLoading = true);

    final response = await DealerApiService.fetchActivities();

    if (response['success']) {
      allLogs = response['data'] ?? [];

      // reset pagination & filters to first page
      currentPage = 1;
      _recalculatePagination();

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Error')));
    }
  }

  // Apply search + status + date filters and return filtered list
  List<dynamic> _applyFilters() {
    List<dynamic> filtered = allLogs;

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((log) {
        final actionType = (log['actionType'] ?? '').toString().toLowerCase();
        final userName = (log['userName'] ?? '').toString().toLowerCase();
        final role = (log['role'] ?? '').toString().toLowerCase();
        final description = (log['description'] ?? '').toString().toLowerCase();
        // final resource = (log['targetResourceName'] ?? '')
        //     .toString()
        //     .toLowerCase();

        return actionType.contains(query) ||
            userName.contains(query) ||
            role.contains(query) ||
            description.contains(query) ;
      }).toList();
    }

    // if (_selectedStatusValue != 'All') {
    //   filtered = filtered.where((log) {
    //     final action = (log['actionType'] ?? '').toString();
    //     return action == _selectedStatusValue;
    //   }).toList();
    // }

    // Date filter
    filtered = filterDealersByDate(
      filtered,
      selectedDateFilter,
      specificDate: specificDate,
      fromDate: fromDate,
      toDate: toDate,
    );

    return filtered;
  }

  // Recalculate pagination based on filtered results and set pageLogs
  void _recalculatePagination() {
    final filtered = _applyFilters();
    totalPages = (filtered.length / pageSize).ceil();
    if (totalPages == 0) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;
    _updatePageLogs(filtered: filtered);
  }

  void _updatePageLogs({List<dynamic>? filtered}) {
    final list = filtered ?? _applyFilters();
    int start = (currentPage - 1) * pageSize;
    int end = start + pageSize;
    setState(() {
      pageLogs = list.sublist(start, end > list.length ? list.length : end);
    });
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
  }

  void _onFiltersChanged() {
    setState(() {
      currentPage = 1;
    });
    _recalculatePagination();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentPage: "Activity Log"),
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'ACTIVITY LOG!',
                style: GoogleFonts.poppins(
                  fontSize: isTablet(context) ? 22 : 12,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: isLoading
          ? const AnimationPage1()
          : RefreshIndicator(
            color: mythemecolor,
            strokeWidth: 3,
              onRefresh: () async {
                currentPage = 1;
                await _loadActivities();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Column(
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              'Search by action, user, role, description...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: mythemecolor,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 74, 61, 84),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          _searchQuery = val;
                          _onFiltersChanged();
                        },
                      ),
                    ),

                  
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date filter dropdown
                          DropdownButton<String>(
                            isExpanded: true,
                            value: selectedDateFilter,
                            items:
                                [
                                  'All Dates',
                                  'Today',
                                  'Specific Date',
                                  'From-To',
                                ].map((filter) {
                                  return DropdownMenuItem(
                                    value: filter,
                                    child: Text(filter),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDateFilter = value ?? 'All Dates';

                                if (selectedDateFilter != 'Specific Date') {
                                  specificDate = null;
                                }
                                if (selectedDateFilter != 'From-To') {
                                  fromDate = null;
                                  toDate = null;
                                }
                              });
                              _onFiltersChanged();
                            },
                          ),

                          const SizedBox(height: 6),

                          // Date pickers area
                          if (selectedDateFilter == 'Specific Date')
                            TextButton(
                              onPressed: () async {
                                final picked = await _pickDate(
                                  context,
                                  specificDate,
                                );
                                if (picked != null) {
                                  setState(() => specificDate = picked);
                                  _onFiltersChanged();
                                }
                              },
                              child: Text(
                                specificDate == null
                                    ? 'Pick Date'
                                    : '${specificDate!.day}/${specificDate!.month}/${specificDate!.year}',
                              ),
                            ),

                          if (selectedDateFilter == 'From-To')
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final picked = await _pickDate(
                                      context,
                                      fromDate,
                                    );
                                    if (picked != null) {
                                      setState(() => fromDate = picked);
                                      _onFiltersChanged();
                                    }
                                  },
                                  child: Text(
                                    fromDate == null
                                        ? 'From'
                                        : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await _pickDate(
                                      context,
                                      toDate,
                                    );
                                    if (picked != null) {
                                      setState(() => toDate = picked);
                                      _onFiltersChanged();
                                    }
                                  },
                                  child: Text(
                                    toDate == null
                                        ? 'To'
                                        : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // ───────────────────────────────
                    // ROW 3 → STATUS FILTER
                    // ───────────────────────────────
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 4,
                    //     vertical: 4,
                    //   ),
                    //   child: DropdownButton<String>(
                    //     isExpanded: true,
                    //     value: _selectedStatus,
                    //     items: actionTypeMap.keys.map((label) {
                    //       return DropdownMenuItem(
                    //         value: label,
                    //         child: Text(label),
                    //       );
                    //     }).toList(),
                    //     onChanged: (value) {
                    //       setState(() {
                    //         _selectedStatus = value!;
                    //         _selectedStatusValue = actionTypeMap[value]!;
                    //       });
                    //       _onFiltersChanged();
                    //     },
                    //   ),
                    // ),

                    const SizedBox(height: 6),

                    // Logs list
                    Expanded(child: _buildLogsArea()),

                    // Pagination
                    _paginationWidget(),
                  ],
                ),

             
              ),
            ),
    );
  }

Widget _buildLogsArea() {
  final filtered = _applyFilters();

  if (filtered.isEmpty) {
    return const Center(child: Text("No activity logs available"));
  }

  // ensure page logs match filters/page
  _updatePageLogs(filtered: filtered);

  final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

  // ✅ MOBILE VIEW (UNCHANGED LISTVIEW)
  if (!isTablet) {
    return ListView.builder(
      itemCount: pageLogs.length,
      itemBuilder: (context, index) {
        final log = pageLogs[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(
              log["actionType"] ?? "",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text("""
User: ${log["userName"] ?? ''}
Role: ${log["role"] ?? ''}
Status: ${log["status"] ?? '-'}
Time: ${DateTime.tryParse(log["createdAt"] ?? '')?.toLocal() ?? ''}
Description: ${log["description"] ?? ''}
              """, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        );
      },
    );
  }

  // ✅ TABLET VIEW — PREMIUM TWO-COLUMN GRID
  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,                 // ✅ Two logs per row
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 2.5,             // ✅ Balanced layout esthetics
    ),
    itemCount: pageLogs.length,
    itemBuilder: (context, index) {
      final log = pageLogs[index];

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
             
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    log["actionType"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                """
User: ${log["userName"] ?? ''}
Role: ${log["role"] ?? ''}
Status: ${log["status"] ?? '-'}
Time: ${DateTime.tryParse(log["createdAt"] ?? '')?.toLocal() ?? ''}
                """,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  height: 1.25,
                ),
              ),
            ),
            Divider(color: Colors.white.withOpacity(.4)),
            Text(
              log["description"] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            )
          ],
        ),
      );
    },
  );
}


  Widget _paginationWidget() {
    // ensure totalPages is based on filtered list
    final filtered = _applyFilters();
    totalPages = (filtered.length / pageSize).ceil();
    if (totalPages == 0) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientButtons(
            text: "PREV",
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      _updatePageLogs(filtered: filtered);
                    });
                  }
                : null,
          ),
          const SizedBox(width: 20),
          Text(
            "Page $currentPage of $totalPages",
            style: const TextStyle(color: mythemecolor),
          ),
          const SizedBox(width: 20),
          GradientButtons(
            text: "NEXT",
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      _updatePageLogs(filtered: filtered);
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}



