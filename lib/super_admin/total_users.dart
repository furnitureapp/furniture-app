import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/pagination_widget.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
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

class TotalUsersSA extends StatefulWidget {
  const TotalUsersSA({super.key});

  @override
  State<TotalUsersSA> createState() => _TotalUsersSAState();
}

class _TotalUsersSAState extends State<TotalUsersSA> {
  bool _isLoading = true;
  List<dynamic> _dealers = [];
  String _selectedDealerType = 'All';
  String _selectedCreatorFilter = 'All';

  String _searchQuery = '';
  String _selectedStatus = 'All';
  String selectedDateFilter = 'All Dates';
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;

  int currentPage = 1;
  int pageSize = 4;
  List<dynamic> pageDealers = [];
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchDealers();
  }

  Future<void> _fetchDealers() async {
    setState(() => _isLoading = true);
    final response = await DealerApiService.fetchDealersManagers();

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

  List<dynamic> _applyFilters() {
    List<dynamic> filtered = _dealers;

    // 🔍 Search filter
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

    // ✔ Status filter
    filtered = filtered.where((dealer) {
      final isApproved = dealer['isApproved'] == true;
      final isRejected = dealer['isRejected'] == true;

      if (_selectedStatus == 'Approved') return isApproved;
      if (_selectedStatus == 'Rejected') return isRejected;
      if (_selectedStatus == 'Pending') return !isApproved && !isRejected;

      return true;
    }).toList();

    // 📅 Date filter
    filtered = filterDealersByDate(
      filtered,
      selectedDateFilter,
      specificDate: specificDate,
      fromDate: fromDate,
      toDate: toDate,
    );

    // 🟦 Dealer Type filter (Type 1 / Type 2)
    filtered = filtered.where((dealer) {
      final raw = dealer['DealerType']?.toString().trim();

      int? type;
      if (raw == 'Type 1') type = 1;
      if (raw == 'Type 2') type = 2;

      if (_selectedDealerType == 'Type 1') return type == 1;
      if (_selectedDealerType == 'Type 2') return type == 2;

      return true; // All
    }).toList();

    // 🟪 NEW: Creator Filter (Admin / Marketer / All)
    filtered = filtered.where((dealer) {
      final creator = (dealer['creatorModel'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      if (_selectedCreatorFilter == 'Admin') {
        return creator == 'admin';
      }

      if (_selectedCreatorFilter == 'Marketer') {
        return creator == 'marketer';
      }

      if (_selectedCreatorFilter == 'dealer') {
        return creator == 'dealer';
      }
      return true; // All
    }).toList();

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
    // final filteredDealers = _applyFilters();

    final filteredDealers = _applyFilters();

    // ---- Pagination Logic ----
    totalPages = (filteredDealers.length / pageSize).ceil();
    if (totalPages == 0) totalPages = 1;

    if (currentPage > totalPages) currentPage = totalPages;

    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    pageDealers = filteredDealers.sublist(
      startIndex,
      endIndex > filteredDealers.length ? filteredDealers.length : endIndex,
    );

    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      drawer: const SuperAdminDrawer(currentPage: "Dealers Management"),
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
            title: Text(
              'REGISTERED DEALERS!',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 22 : 12,
                fontWeight: FontWeight.w600,
                color: mythemecolor,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: mythemecolor,
        strokeWidth: 3,
        onRefresh: _fetchDealers,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!isTablet) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: mythemecolor),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                    onChanged: (val) => setState(() {
                      _searchQuery = val;
                      currentPage = 1;
                    }),

                    // onChanged: (val) => setState(() => _searchQuery = val),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------- ROW 2: DATE FILTER -----------------------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedDateFilter,
                        decoration: _dropdownDecoration("Date Filter"),
                        items:
                            ['All Dates', 'Today', 'Specific Date', 'From-To']
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      f,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => selectedDateFilter = value!),
                      ),

                      if (selectedDateFilter == 'Specific Date') ...[
                        const SizedBox(height: 10),
                        _dateButton("Pick Date", specificDate, () async {
                          final picked = await _pickDate(context, specificDate);
                          if (picked != null) {
                            setState(() => specificDate = picked);
                          }
                        }),
                      ],

                      if (selectedDateFilter == 'From-To') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _dateButton("From", fromDate, () async {
                                final picked = await _pickDate(
                                  context,
                                  fromDate,
                                );
                                if (picked != null) {
                                  setState(() => fromDate = picked);
                                }
                              }),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _dateButton("To", toDate, () async {
                                final picked = await _pickDate(context, toDate);
                                if (picked != null) {
                                  setState(() => toDate = picked);
                                }
                              }),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ---------------------- ROW 3: STATUS FILTER -----------------------
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: _dropdownDecoration("Status Filter"),
                    items: ['All', 'Approved', 'Pending', 'Rejected']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value!),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCreatorFilter,
                        items: ['All', 'Admin', 'Marketer', 'dealer']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        decoration: _dropdownDecoration("Creator By Filter"),

                        onChanged: (value) {
                          setState(() {
                            _selectedCreatorFilter = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedDealerType,
                    decoration: _dropdownDecoration("Dealer Type"),
                    items: ['All', 'Type 1', 'Type 2']
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDealerType = value!);
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---------------------- DEALER LIST -----------------------
                  if (_isLoading)
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(child: AnimationPage1()),
                    )
                  else if (filteredDealers.isEmpty)
                    Center(
                      child: Text(
                        "No dealers found",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...pageDealers
                        .map((dealer) => _dealerCard(dealer, isTablet: false))
                        .toList(),

                  if (pageDealers.isNotEmpty)
                    PaginationWidget(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPrev: currentPage > 1
                          ? () => setState(() => currentPage--)
                          : null,
                      onNext: currentPage < totalPages
                          ? () => setState(() => currentPage++)
                          : null,
                    ),
                ],
              );
            }

            // -------------------- TABLET LAYOUT (>=600px) --------------------
            // Use Approval page style: search full width, then row with Date & Status panels,
            // and then a two-column grid for dealer cards.
            final double gridSpacing = 16;
            final int crossAxisCount = 2;
            // determine card height/ratio
            final double cardWidth =
                (constraints.maxWidth - (gridSpacing * (crossAxisCount + 1))) /
                crossAxisCount;
            final double cardHeight = 450; // reasonable height for tablet cards
            final double childAspect = cardWidth / cardHeight;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // SEARCH BAR (full width, styled)
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
                      prefixIcon: const Icon(Icons.search, color: mythemecolor),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                        borderSide: BorderSide(color: mythemecolor, width: 2),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                  ),
                ),

                const SizedBox(height: 18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCreatorFilter,
                        items: ['All', 'Admin', 'Marketer', 'dealer']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        decoration: _dropdownDecoration("Creator By Filter"),

                        onChanged: (value) {
                          setState(() {
                            _selectedCreatorFilter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ROW: DATE FILTER (left) & STATUS (right)
                Row(
                  children: [
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
                                  selectedDateFilter = value ?? 'All Dates';
                                  if (selectedDateFilter != 'Specific Date') {
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
                                    setState(() => specificDate = picked);
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
                                        if (picked != null)
                                          setState(() => fromDate = picked);
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
                                        if (picked != null)
                                          setState(() => toDate = picked);
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

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
                              "Dealer Type",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDealerType,
                              decoration: _dropDownDeco(),
                              items: ['All', 'Type 1', 'Type 2']
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedDealerType = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // GRID of dealer cards (2 columns)
                if (_isLoading)
                  SizedBox(
                    height: 300,
                    child: const Center(child: AnimationPage1()),
                  )
                else if (filteredDealers.isEmpty)
                  Center(
                    child: Text(
                      "No dealers found",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  // Wrap in a fixed-height GridView inside SizedBox to avoid unbounded height issues
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: childAspect,
                      ),
                      itemCount: pageDealers.length,
                      itemBuilder: (context, index) {
                        final dealer = pageDealers[index];

                        // itemCount: filteredDealers.length,
                        // itemBuilder: (context, index) {
                        //   final dealer = filteredDealers[index];
                        return _dealerCard(dealer, isTablet: true);
                      },
                    ),
                  ),
                PaginationWidget(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPrev: currentPage > 1
                      ? () => setState(() => currentPage--)
                      : null,
                  onNext: currentPage < totalPages
                      ? () => setState(() => currentPage++)
                      : null,
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

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: mythemecolor,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }

  Widget _dateButton(String label, DateTime? date, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: mythemecolor1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        date == null ? label : "${date.day}/${date.month}/${date.year}",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _dealerCard(dealer, {bool isTablet = false}) {
    final double titleSize = isTablet ? 20 : 16;
    final double infoSize = isTablet ? 16 : 12;
    final double avatarSize = isTablet ? 70 : 55;
    final EdgeInsetsGeometry padding = isTablet
        ? const EdgeInsets.all(18)
        : const EdgeInsets.all(16);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple.shade50.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mythemecolor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: mythemecolor.withOpacity(0.15),
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: isTablet
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [mythemecolor, mythemecolor1],
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dealer['companyName'] ?? 'Unnamed Dealer',
                            style: GoogleFonts.poppins(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: mythemecolor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dealer['address'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: infoSize,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // info rows
                _infoRow(Icons.person, dealer['username'], fontSize: infoSize),
                const SizedBox(height: 4),
                _infoRow(
                  Icons.phone,
                  dealer['phoneNumber'],
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),
                _infoRow(
                  Icons.email_outlined,
                  dealer['email'],
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),
                _infoRow(
                  Icons.badge_outlined,
                  "GST: ${dealer['gstNumber']}",
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),

                _infoRow(
                  Icons.badge_outlined,
                  "Dealer Type: ${dealer['DealerType'] ?? 'N/A'}",
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),

                _infoRow(
                  Icons.badge_outlined,
                  "Created By: ${dealer['createdByName'] ?? 'N/A'}",
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),

                _infoRow(
                  Icons.badge_outlined,
                  "Created Model: ${dealer['creatorModel'] ?? 'N/A'}",
                  fontSize: infoSize,
                ),
                const SizedBox(height: 4),

                _infoRow(
                  Icons.check_box,
                  "Gst Approved by Model: ${dealer['gstApprovedByModel'] ?? 'N/A'}",
                  fontSize: infoSize,
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: dealer['isActive'] == true
                          ? mythemecolor
                          : mythemecolor1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dealer['isActive']
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dealer['isActive'] ? "Active" : "Inactive",
                          style: GoogleFonts.poppins(
                            fontSize: infoSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [mythemecolor, mythemecolor1],
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dealer['companyName'] ?? 'Unnamed Dealer',
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: mythemecolor,
                        ),
                      ),
                      const SizedBox(height: 4),

                      _infoRow(Icons.person, dealer['username']),
                      _infoRow(Icons.location_on, dealer['address']),
                      _infoRow(Icons.phone, dealer['phoneNumber']),
                      _infoRow(Icons.email_outlined, dealer['email']),
                      _infoRow(
                        Icons.badge_outlined,
                        "Dealer Type: ${dealer['DealerType'] ?? 'N/A'}",
                        fontSize: infoSize,
                      ),
                      const SizedBox(height: 4),

                      _infoRow(
                        Icons.badge_outlined,
                        "Created By: ${dealer['createdByName'] ?? 'N/A'}",
                        fontSize: infoSize,
                      ),
                      const SizedBox(height: 4),

                      _infoRow(
                        Icons.badge_outlined,
                        "Created Model: ${dealer['creatorModel'] ?? 'N/A'}",
                        fontSize: infoSize,
                      ),
                      const SizedBox(height: 4),

                      _infoRow(
                        Icons.person_2_sharp,
                        "Created Model: ${dealer['creatorModel'] ?? 'N/A'}",
                        fontSize: infoSize,
                      ),
                      const SizedBox(height: 4),

                      _infoRow(
                        Icons.check_box,
                        "Gst Approved by Model: ${dealer['gstApprovedByModel'] ?? 'N/A'}",
                        fontSize: infoSize,
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: dealer['isActive'] == true
                                ? mythemecolor
                                : mythemecolor1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                dealer['isActive']
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dealer['isActive'] ? "Active" : "Inactive",
                                style: GoogleFonts.poppins(
                                  fontSize: infoSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoRow(IconData icon, dynamic text, {double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: mythemecolor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text?.toString() ?? "N/A",
              style: GoogleFonts.poppins(fontSize: fontSize, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
