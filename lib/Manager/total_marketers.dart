import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/core/api_management_service/admin_api_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
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

class TotalMarketersM extends StatefulWidget {
  const TotalMarketersM({super.key});

  @override
  State<TotalMarketersM> createState() => _TotalMarketersMState();
}

class _TotalMarketersMState extends State<TotalMarketersM> {
  bool _isLoading = true;
  List<dynamic> _dealers = [];
  String _selectedRole = 'All Roles';

  String _searchQuery = '';
  String selectedDateFilter = 'All Dates';
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    final response = await AdminApiService.fetchMarketers();

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _dealers = response['data'];
        print("🔹 Fetched $_dealers admins");
      } else {
        _dealers = [];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    });
  }

  List<dynamic> _applyFilters() {
    List<dynamic> filtered = _dealers;

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((dealer) {
        return (dealer['name'] ?? '').toString().toLowerCase().contains(
              query,
            ) ||
            (dealer['email'] ?? '').toString().toLowerCase().contains(query) ||
            (dealer['role'] ?? '').toString().toLowerCase().contains(query) ||
            (dealer['creatorModel'] ?? '').toString().toLowerCase().contains(
              query,
            );
      }).toList();
    }

    // Role Filter (creatorModel)
    if (_selectedRole != 'All Roles') {
      filtered = filtered.where((dealer) {
        return (dealer['creatorModel'] ?? '').toString().toLowerCase() ==
            _selectedRole.toLowerCase();
      }).toList();
    }

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

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealers = _applyFilters();

    // define tablet threshold
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
            color: mythemecolor,
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
                'MARKETER MANAGEMENT',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 22 : 12,
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
      drawer: ManagerDrawer(currentPage: "Marketers Management"),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchAdmins();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              children: [
                // ----------------------
                // FILTERS AREA
                // ----------------------
                // For mobile: stacked (three rows) — same as your original layout.
                // For tablet: single row with three expanded sections.
                if (!isTablet) ...[
                  // Mobile: same as before (unchanged look)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, phone...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: mythemecolor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: mythemecolor, // your theme color
                            width: 2,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: mythemecolor),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
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
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedDateFilter,
                          items:
                              ['All Dates', 'Today', 'Specific Date', 'From-To']
                                  .map(
                                    (filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDateFilter = value ?? 'All Dates';

                              if (selectedDateFilter != 'Specific Date')
                                specificDate = null;
                              if (selectedDateFilter != 'From-To') {
                                fromDate = null;
                                toDate = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 6),
                        if (selectedDateFilter == 'Specific Date')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mythemecolor1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await _pickDate(
                                context,
                                specificDate,
                              );

                              if (picked != null) {
                                setState(() => specificDate = picked);
                              }
                            },

                            child: Text(
                              specificDate == null
                                  ? 'Pick Date'
                                  : '${specificDate!.day}/${specificDate!.month}/${specificDate!.year}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (selectedDateFilter == 'From-To')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mythemecolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await _pickDate(
                                    context,
                                    fromDate,
                                  );
                                  if (picked != null) {
                                    setState(() => fromDate = picked);
                                  }
                                },
                                child: Text(
                                  fromDate == null
                                      ? 'From'
                                      : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mythemecolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await _pickDate(
                                    context,
                                    toDate,
                                  );
                                  if (picked != null) {
                                    setState(() => toDate = picked);
                                  }
                                },
                                child: Text(
                                  toDate == null
                                      ? 'To'
                                      : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedRole,
                      items: ['All Roles', 'SuperAdmin', 'Admin', 'Manager']
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------------------------------------------------
                        // ROW 1 — SEARCH BAR (FULL WIDTH)
                        // ---------------------------------------------------------
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by name, email, phone...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: mythemecolor,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mythemecolor.withOpacity(0.4),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mythemecolor,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => _searchQuery = val);
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ---------------------------------------------------------
                        // ROW 2 — DATE FILTER (LEFT) AND STATUS FILTER (RIGHT)
                        // ---------------------------------------------------------
                        Row(
                          children: [
                            // ----------------- DATE FILTER PANEL -----------------
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Date Filter",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: selectedDateFilter,
                                      decoration: _dropDownDeco(),
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
                                          selectedDateFilter =
                                              value ?? 'All Dates';

                                          if (selectedDateFilter !=
                                              'Specific Date') {
                                            specificDate = null;
                                          }
                                          if (selectedDateFilter != 'From-To') {
                                            fromDate = null;
                                            toDate = null;
                                          }
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    if (selectedDateFilter == 'Specific Date')
                                      _tabletDateButton(
                                        label: specificDate == null
                                            ? 'Pick Date'
                                            : '${specificDate!.day}/${specificDate!.month}/${specificDate!.year}',
                                        onPressed: () async {
                                          final picked = await _pickDate(
                                            context,
                                            specificDate,
                                          );
                                          if (picked != null) {
                                            setState(
                                              () => specificDate = picked,
                                            );
                                          }
                                        },
                                      ),

                                    if (selectedDateFilter == 'From-To')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _tabletDateButton(
                                              label: fromDate == null
                                                  ? 'From'
                                                  : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                                              onPressed: () async {
                                                final picked = await _pickDate(
                                                  context,
                                                  fromDate,
                                                );
                                                if (picked != null) {
                                                  setState(
                                                    () => fromDate = picked,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _tabletDateButton(
                                              label: toDate == null
                                                  ? 'To'
                                                  : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                                              onPressed: () async {
                                                final picked = await _pickDate(
                                                  context,
                                                  toDate,
                                                );
                                                if (picked != null) {
                                                  setState(
                                                    () => toDate = picked,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // ----------------- STATUS FILTER PANEL -----------------
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Creator",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedRole,
                                      items:
                                          [
                                                'All Roles',
                                                'SuperAdmin',
                                                'Admin',
                                                'Manager',
                                              ]
                                              .map(
                                                (role) => DropdownMenuItem(
                                                  value: role,
                                                  child: Text(role),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) => setState(
                                        () => _selectedRole = value!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                // ----------------------
                // TABLE AREA (scrollable horizontally)
                // ----------------------
                // We can't use Expanded inside ListView; give the table a height.
                Builder(
                  builder: (context) {
                    // Determine a reasonable height for the table area
                    final double tableHeight = isTablet
                        ? (constraints.maxHeight * 0.65).clamp(300.0, 1000.0)
                        : 500.0;

                    if (_isLoading) {
                      return SizedBox(
                        height: 200,
                        child: const Center(child: AnimationPage1()),
                      );
                    }

                    if (dealers.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: const Center(
                          child: Text("No Marketers available"),
                        ),
                      );
                    }

                    // Table content
                    return SizedBox(
                      height: tableHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: mythemecolor,
                              fontSize: isTablet ? 20 : 14,
                            ),
                            dataTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: isTablet ? 18 : 12,
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),

                            columns: [
                              DataColumn(label: Text("Marketer Name")),
                              DataColumn(label: Text("Marketer Email")),
                              DataColumn(label: Text("Role")),
                              DataColumn(label: Text("Creator Email")),
                              DataColumn(label: Text("Creator Name")),
                              DataColumn(label: Text("Creator Role")),
                              DataColumn(label: Text("Created At")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Zone")),
                            ],
                            rows: dealers.map((dealer) {
                              final creator = dealer['createdBy'] ?? {};

                              return DataRow(
                                cells: [
                                  DataCell(Text(dealer['name'] ?? '-')),
                                  DataCell(Text(dealer['email'] ?? '-')),
                                  DataCell(Text(dealer['role'] ?? '-')),
                                  DataCell(Text(creator['email'] ?? '-')),
                                  DataCell(Text(creator['name'] ?? '-')),
                                  DataCell(Text(creator['role'] ?? '-')),
                                  DataCell(
                                    Text(
                                      dealer['createdAt'] != null
                                          ? DateTime.parse(dealer['createdAt'])
                                                .toLocal()
                                                .toString()
                                                .substring(0, 19)
                                          : '-',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dealer['isActive']
                                          ? "Active"
                                          : "Inactive",
                                    ),
                                  ),
                                  DataCell(Text(dealer['zone'] ?? '-')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _dropDownDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mythemecolor.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mythemecolor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mythemecolor, width: 2),
      ),
    );
  }

  Widget _tabletDateButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        side: BorderSide(color: mythemecolor.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
