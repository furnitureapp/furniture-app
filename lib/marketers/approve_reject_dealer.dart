import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
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

class DealerApprovalPage extends StatefulWidget {
  const DealerApprovalPage({super.key});

  @override
  State<DealerApprovalPage> createState() => _DealerApprovalPageState();
}

class _DealerApprovalPageState extends State<DealerApprovalPage> {
  bool _isLoading = true;
  List<dynamic> _dealers = [];

  // 🔍 Filters
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String selectedDateFilter = 'All Dates';
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _fetchDealers();
  }

  Future<void> _fetchDealers() async {
    setState(() => _isLoading = true);
    final response = await DealerApiService.fetchDealers();

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _dealers = response['data'];
      } else {
        _dealers = [];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    });
  }

  // 🔍 Local search + status + date filter combination
  List<dynamic> _applyFilters() {
    List<dynamic> filtered = _dealers;

    // Search filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((dealer) {
        return (dealer['companyName'] ?? '').toString().toLowerCase().contains(
              query,
            ) ||
            (dealer['email'] ?? '').toString().toLowerCase().contains(query) ||
            (dealer['username'] ?? '').toString().toLowerCase().contains(
              query,
            ) ||
            (dealer['phoneNumber'] ?? '').toString().toLowerCase().contains(
              query,
            );
      }).toList();
    }

    // Status filter
    filtered = filtered.where((dealer) {
      final isApproved = dealer['isApproved'] == true;
      final isRejected = dealer['isRejected'] == true;
      if (_selectedStatus == 'Approved') return isApproved;
      if (_selectedStatus == 'Rejected') return isRejected;
      if (_selectedStatus == 'Pending') return !isApproved && !isRejected;
      return true;
    }).toList();

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

  Future<void> _approveDealer(String dealerId) async {
    int? selectedType;
    final scaffoldCtx = context; // ✅ capture parent scaffold context

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Dealer Type"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: const Text("Type 1"),
                    value: 1,
                    groupValue: selectedType,
                    onChanged: (val) {
                      setStateDialog(() => selectedType = val);
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text("Type 2"),
                    value: 2,
                    groupValue: selectedType,
                    onChanged: (val) {
                      setStateDialog(() => selectedType = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedType == null) {
                      ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a dealer type"),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogCtx); // ✅ close dialog first
                    final result = await DealerApiService.approveDealer(
                      dealerId,
                      selectedType!,
                    );

                    if (!mounted) return;
                    ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Action completed'),
                      ),
                    );

                    _fetchDealers(); // reload list
                  },
                  child: const Text("Approve"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rejectDealer(String dealerId) async {
    final parentContext = context; // 👈 store the parent scaffold context
    String reason = '';

    await showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text("Reject Dealer"),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Enter rejection reason",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => reason = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 211, 163, 160),
            ),
            onPressed: () async {
              if (reason.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reason cannot be empty")),
                );
                return;
              }

              Navigator.pop(context); // close dialog

              final result = await DealerApiService.rejectDealer(
                dealerId,
                reason,
              );

              if (!mounted) return;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Action completed'),
                ),
              );

              _fetchDealers();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // Helper to render Approve/Reject buttons (rectangular, small radius)
  Widget _actionButtons(Map<String, dynamic> dealer) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: mythemecolor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.check, size: 16),
          label: const Text("Approve"),
          onPressed: () => _approveDealer(dealer['_id']),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: mythemecolor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.close, size: 16),
          label: const Text("Reject"),
          onPressed: () => _rejectDealer(dealer['_id']),
        ),
      ],
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
                'APPROVAL & REJECTION',
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
      drawer: MarketerDrawer(currentPage: "Approve or Reject Dealers"),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchDealers();
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
                      value: _selectedStatus,
                      items: ['All', 'Approved', 'Pending', 'Rejected']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedStatus = value!);
                      },
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
                                      "Status",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _selectedStatus,
                                      decoration: _dropDownDeco(),
                                      items:
                                          [
                                                'All',
                                                'Approved',
                                                'Pending',
                                                'Rejected',
                                              ]
                                              .map(
                                                (status) => DropdownMenuItem(
                                                  value: status,
                                                  child: Text(status),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        setState(
                                          () => _selectedStatus = value!,
                                        );
                                      },
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
                          child: Text("No dealers available"),
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
                              fontSize: isTablet ? 24 : 14,
                            ),
                            dataTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: isTablet ? 20 : 12,
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  "Company",
                                 
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Owner",
                               
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Phone",
                                  
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  "Email",
                                 
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "GST",
                                  
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Actions",
                                 
                                ),
                              ),
                            ],
                            rows: dealers.map((dealer) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      dealer['companyName'] ?? '-',
                                    
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dealer['username'] ?? '-',
                                    
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dealer['phoneNumber'] ?? '-',
                                      
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dealer['email'] ?? '-',
                                    
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dealer['gstNumber'] ?? '-',
                                      
                                    ),
                                  ),

                                  DataCell(
                                    dealer['isApproved'] == true
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                255,
                                                220,
                                                213,
                                                213,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text("Approved"),
                                          )
                                        : dealer['isRejected'] == true
                                        ? GestureDetector(
                                            onTap: () {
                                              final reason =
                                                  dealer['rejection']?['reason'] ??
                                                  'No reason';
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Rejection Reason!",
                                                    ),
                                                    content: Text(reason),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  61,
                                                                  33,
                                                                  84,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                  255,
                                                  236,
                                                  218,
                                                  218,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Rejected"),
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    Icons.logout_outlined,
                                                    size: 16,
                                                    color: mythemecolor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : _actionButtons(dealer),
                                  ),
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









  // Tablet: show filters in single row with three panels
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       // Search (left)
                  //       Flexible(
                  //         flex: 4,
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(right: 8),
                  //           child: TextField(
                  //             decoration: InputDecoration(
                  //               hintText: 'Search by name, email, phone...',
                  //               prefixIcon: const Icon(
                  //                 Icons.search,
                  //                 color: mythemecolor,
                  //               ),
                  //               filled: true,
                  //               fillColor: Colors.white,
                  //               border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 borderSide: const BorderSide(
                  //                   color: mythemecolor,
                  //                 ),
                  //               ),
                  //             ),
                  //             onChanged: (val) {
                  //               setState(() => _searchQuery = val);
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Flexible(
                  //         flex: 3,
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(right: 8),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               DropdownButton<String>(
                  //                 isExpanded: true,
                  //                 value: selectedDateFilter,
                  //                 items:
                  //                     [
                  //                           'All Dates',
                  //                           'Today',
                  //                           'Specific Date',
                  //                           'From-To',
                  //                         ]
                  //                         .map(
                  //                           (filter) => DropdownMenuItem(
                  //                             value: filter,
                  //                             child: Text(filter),
                  //                           ),
                  //                         )
                  //                         .toList(),
                  //                 onChanged: (value) {
                  //                   setState(() {
                  //                     selectedDateFilter = value ?? 'All Dates';

                  //                     if (selectedDateFilter !=
                  //                         'Specific Date') {
                  //                       specificDate = null;
                  //                     }
                  //                     if (selectedDateFilter != 'From-To') {
                  //                       fromDate = null;
                  //                       toDate = null;
                  //                     }
                  //                   });
                  //                 },
                  //               ),
                  //               const SizedBox(height: 13),
                  //               if (selectedDateFilter == 'Specific Date')
                  //                 TextButton(
                  //                   onPressed: () async {
                  //                     final picked = await _pickDate(
                  //                       context,
                  //                       specificDate,
                  //                     );
                  //                     if (picked != null) {
                  //                       setState(() => specificDate = picked);
                  //                     }
                  //                   },
                  //                   child: Text(
                  //                     specificDate == null
                  //                         ? 'Pick Date'
                  //                         : '${specificDate!.day}/${specificDate!.month}/${specificDate!.year}',
                  //                   ),
                  //                 ),
                  //               if (selectedDateFilter == 'From-To')
                  //                 Row(
                  //                   children: [
                  //                     TextButton(
                  //                       onPressed: () async {
                  //                         final picked = await _pickDate(
                  //                           context,
                  //                           fromDate,
                  //                         );
                  //                         if (picked != null) {
                  //                           setState(() => fromDate = picked);
                  //                         }
                  //                       },
                  //                       child: Text(
                  //                         fromDate == null
                  //                             ? 'From'
                  //                             : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                  //                       ),
                  //                     ),
                  //                     TextButton(
                  //                       onPressed: () async {
                  //                         final picked = await _pickDate(
                  //                           context,
                  //                           toDate,
                  //                         );
                  //                         if (picked != null) {
                  //                           setState(() => toDate = picked);
                  //                         }
                  //                       },
                  //                       child: Text(
                  //                         toDate == null
                  //                             ? 'To'
                  //                             : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Flexible(
                  //         flex: 2,
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(left: 0),
                  //           child: DropdownButton<String>(
                  //             isExpanded: true,
                  //             value: _selectedStatus,
                  //             items: ['All', 'Approved', 'Pending', 'Rejected']
                  //                 .map(
                  //                   (status) => DropdownMenuItem(
                  //                     value: status,
                  //                     child: Text(status),
                  //                   ),
                  //                 )
                  //                 .toList(),
                  //             onChanged: (value) {
                  //               setState(() => _selectedStatus = value!);
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // ---------------------- TABLET FILTER UI ----------------------





















// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
// import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DealerApprovalPage extends StatefulWidget {
//   const DealerApprovalPage({super.key});

//   @override
//   State<DealerApprovalPage> createState() => _DealerApprovalPageState();
// }

// class _DealerApprovalPageState extends State<DealerApprovalPage> {
//   bool _isLoading = true;
//   List<dynamic> _dealers = [];
  // List<dynamic> _filteredDealers = [];

//   String _searchQuery = '';
//   String _selectedStatus = 'All';
//   String _selectedDateFilter = 'All Dates';
//   DateTime? _specificDate;
//   DateTime? _fromDate;
//   DateTime? _toDate;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDealers();
//   }

//   Future<void> _fetchDealers() async {
//     setState(() => _isLoading = true);
//     final response = await DealerApiService.fetchDealers();
//     if (!mounted) return;
//     setState(() {
//       _isLoading = false;
//       if (response['success']) {
//         _dealers = response['data'];
//         _filteredDealers = _dealers;
//       } else {
//         _dealers = [];
//         _filteredDealers = [];
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(response['message'])));
//       }
//     });
//   }

//   Future<DateTime?> _pickDate(DateTime? initialDate) async {
//     return await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: mythemecolor,
//               onPrimary: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//   }

//   void _applyFilters() {
//     List<dynamic> results = _dealers;

//     // 🔍 Search filter
//     if (_searchQuery.isNotEmpty) {
//       results = results.where((d) {
//         final query = _searchQuery.toLowerCase();
//         return (d['companyName'] ?? '').toLowerCase().contains(query) ||
//             (d['username'] ?? '').toLowerCase().contains(query) ||
//             (d['email'] ?? '').toLowerCase().contains(query) ||
//             (d['phoneNumber'] ?? '').toLowerCase().contains(query);
//       }).toList();
//     }

//     // 🟢 Status filter
//     if (_selectedStatus != 'All') {
//       results = results.where((d) {
//         if (_selectedStatus == 'Approved') return d['isApproved'] == true;
//         if (_selectedStatus == 'Rejected') return d['isRejected'] == true;
//         if (_selectedStatus == 'Pending') {
//           return d['isApproved'] == false && d['isRejected'] == false;
//         }
//         return true;
//       }).toList();
//     }

//     // 📅 Date filter
//     DateTime? createdAt;
//     results = results.where((d) {
//       if (d['createdAt'] == null) return true;
//       try {
//         createdAt = DateTime.parse(d['createdAt']);
//       } catch (_) {
//         return true;
//       }

//       final now = DateTime.now();
//       switch (_selectedDateFilter) {
//         case 'Today':
//           return createdAt!.year == now.year &&
//               createdAt!.month == now.month &&
//               createdAt!.day == now.day;
//         case 'Specific Date':
//           if (_specificDate == null) return true;
//           return createdAt!.year == _specificDate!.year &&
//               createdAt!.month == _specificDate!.month &&
//               createdAt!.day == _specificDate!.day;
//         case 'From-To':
//           if (_fromDate == null || _toDate == null) return true;
//           return !createdAt!.isBefore(_fromDate!) &&
//               !createdAt!.isAfter(_toDate!);
//         default:
//           return true;
//       }
//     }).toList();

//     setState(() => _filteredDealers = results);
//   }

//   Future<void> _approveDealer(String dealerId) async {
//     int? selectedType;
//     final scaffoldCtx = context;

//     await showDialog(
//       context: context,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               title: const Text("Select Dealer Type"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<int>(
//                     title: const Text("Type 1"),
//                     value: 1,
//                     groupValue: selectedType,
//                     onChanged: (val) =>
//                         setStateDialog(() => selectedType = val),
//                   ),
//                   RadioListTile<int>(
//                     title: const Text("Type 2"),
//                     value: 2,
//                     groupValue: selectedType,
//                     onChanged: (val) =>
//                         setStateDialog(() => selectedType = val),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(dialogCtx),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (selectedType == null) {
//                       ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
//                         const SnackBar(content: Text("Select a dealer type")),
//                       );
//                       return;
//                     }
//                     Navigator.pop(dialogCtx);
//                     final result = await DealerApiService.approveDealer(
//                       dealerId,
//                       selectedType!,
//                     );
//                     if (!mounted) return;
//                     ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
//                       SnackBar(
//                         content: Text(result['message'] ?? 'Action done'),
//                       ),
//                     );
//                     _fetchDealers();
//                   },
//                   child: const Text("Approve"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _rejectDealer(String dealerId) async {
//     String reason = '';
//     final parentCtx = context;

//     await showDialog(
//       context: parentCtx,
//       builder: (context) => AlertDialog(
//         title: const Text("Reject Dealer"),
//         content: TextField(
//           maxLines: 3,
//           decoration: const InputDecoration(
//             labelText: "Enter rejection reason",
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (val) => reason = val,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               if (reason.trim().isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Reason cannot be empty")),
//                 );
//                 return;
//               }

//               Navigator.pop(context);
//               final result = await DealerApiService.rejectDealer(
//                 dealerId,
//                 reason,
//               );
//               if (!mounted) return;
//               ScaffoldMessenger.of(parentCtx).showSnackBar(
//                 SnackBar(content: Text(result['message'] ?? 'Action done')),
//               );
//               _fetchDealers();
//             },
//             child: const Text("Submit"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 221, 197, 251),
//                 Colors.white,
//                 Color.fromARGB(255, 221, 197, 251),
//               ],
//             ),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             title: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Text(
//                 'Approval & Rejection',
//                 style: GoogleFonts.poppins(
//                   color: mythemecolor,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: mythemecolor),
//           ),
//         ),
//       ),
//       drawer: MarketerDrawer(currentPage: "Approve or Reject Dealers"),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: mythemecolor))
//           : Column(
//               children: [
//                 // 🔍 Search + Filters Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 20,
//                   ),
//                   child: Column(
//                     children: [
//                       TextField(
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: mythemecolor,
//                           ),
//                           hintText: 'Search by name, company, phone, email...',
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onChanged: (val) {
//                           setState(() => _searchQuery = val);
//                           _applyFilters();
//                         },
//                       ),
//                       const SizedBox(height: 30),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 4,
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 value: _selectedStatus,
//                                 decoration: InputDecoration(
//                                   labelText: "Status",
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical:
//                                         14, // 👈 increases space between label and dropdown
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                 ),
//                                 items:
//                                     ['All', 'Approved', 'Rejected', 'Pending']
//                                         .map(
//                                           (e) => DropdownMenuItem(
//                                             value: e,
//                                             child: Text(e),
//                                           ),
//                                         )
//                                         .toList(),
//                                 onChanged: (val) {
//                                   setState(() => _selectedStatus = val!);
//                                   _applyFilters();
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 value: _selectedDateFilter,
//                                 decoration: InputDecoration(
//                                   labelText: "Date Filter",
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                 ),
//                                 items:
//                                     [
//                                           'All Dates',
//                                           'Today',
//                                           'Specific Date',
//                                           'From-To',
//                                         ]
//                                         .map(
//                                           (e) => DropdownMenuItem(
//                                             value: e,
//                                             child: Text(e),
//                                           ),
//                                         )
//                                         .toList(),
//                                 onChanged: (val) async {
//                                   setState(() => _selectedDateFilter = val!);
//                                   if (val == 'Specific Date') {
//                                     _specificDate = await _pickDate(
//                                       _specificDate,
//                                     );
//                                   } else if (val == 'From-To') {
//                                     _fromDate = await _pickDate(_fromDate);
//                                     _toDate = await _pickDate(_toDate);
//                                   }
//                                   _applyFilters();
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // 📋 DataTable
//                 Expanded(
//                   child: _filteredDealers.isEmpty
//                       ? const Center(child: Text("No dealers found"))
//                       : SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: DataTable(
//                             headingRowColor: MaterialStateProperty.all(
//                               Colors.deepPurple.shade50,
//                             ),
//                             headingTextStyle: GoogleFonts.poppins(
//                               fontWeight: FontWeight.bold,
//                               color: mythemecolor,
//                             ),
//                             dataTextStyle: GoogleFonts.poppins(fontSize: 13),
//                             columnSpacing: 20,
//                             border: TableBorder.all(
//                               color: Colors.grey.shade300,
//                             ),
//                             columns: const [
//                               DataColumn(label: Text("Company")),
//                               DataColumn(label: Text("Owner")),
//                               DataColumn(label: Text("Phone")),
//                               DataColumn(label: Text("Email")),
//                               DataColumn(label: Text("GST")),
//                               DataColumn(label: Text("Status / Actions")),
//                             ],
//                             rows: _filteredDealers.map((dealer) {
//                               return DataRow(
//                                 cells: [
//                                   DataCell(Text(dealer['companyName'] ?? '-')),
//                                   DataCell(Text(dealer['username'] ?? '-')),
//                                   DataCell(Text(dealer['phoneNumber'] ?? '-')),
//                                   DataCell(Text(dealer['email'] ?? '-')),
//                                   DataCell(Text(dealer['gstNumber'] ?? '-')),
//                                   DataCell(
//                                     dealer['isApproved'] == true
//                                         ? _statusChip("Approved", Colors.green)
//                                         : dealer['isRejected'] == true
//                                         ? _statusChip("Rejected", Colors.red)
//                                         : Row(
//                                             children: [
//                                               ElevatedButton.icon(
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       mythemecolor1,
//                                                 ),
//                                                 icon: const Icon(
//                                                   Icons.check,
//                                                   size: 16,
//                                                 ),
//                                                 label: const Text("Approve"),
//                                                 onPressed: () => _approveDealer(
//                                                   dealer['_id'],
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 8),
//                                               ElevatedButton.icon(
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       mythemecolor1,
//                                                 ),
//                                                 icon: const Icon(
//                                                   Icons.close,
//                                                   size: 16,
//                                                 ),
//                                                 label: const Text("Reject"),
//                                                 onPressed: () => _rejectDealer(
//                                                   dealer['_id'],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _statusChip(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         border: Border.all(color: color),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: color, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }
