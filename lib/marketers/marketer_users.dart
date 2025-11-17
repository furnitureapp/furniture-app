import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
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

class DealersListPage extends StatefulWidget {
  const DealersListPage({super.key});

  @override
  State<DealersListPage> createState() => _DealersListPageState();
}

class _DealersListPageState extends State<DealersListPage> {
  bool _isLoading = true;
  List<dynamic> _dealers = [];
  String? _updatingDealerId;

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

    filtered = filtered.where((dealer) {
      final isApproved = dealer['isApproved'] == true;
      final isRejected = dealer['isRejected'] == true;
      if (_selectedStatus == 'Approved') return isApproved;
      if (_selectedStatus == 'Rejected') return isRejected;
      if (_selectedStatus == 'Pending') return !isApproved && !isRejected;
      return true;
    }).toList();

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
    final filteredDealers = _applyFilters();

    return Scaffold(
      drawer: const MarketerDrawer(currentPage: "Dealers Details"),
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
                'Registered Dealers!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone...',
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 53, 39, 64)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 53, 39, 64)),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedDateFilter,
                    items: ['All Dates', 'Today', 'Specific Date', 'From-To']
                        .map(
                          (filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedDateFilter = value!);
                    },
                  ),
                ),
                if (selectedDateFilter == 'Specific Date')
                  TextButton(
                    onPressed: () async {
                      final picked = await _pickDate(context, specificDate);
                      if (picked != null) setState(() => specificDate = picked);
                    },
                    child: Text(
                      specificDate == null
                          ? 'Pick Date'
                          : '${specificDate!.day}/${specificDate!.month}/${specificDate!.year}',
                    ),
                  ),
                if (selectedDateFilter == 'From-To') ...[
                  TextButton(
                    onPressed: () async {
                      final picked = await _pickDate(context, fromDate);
                      if (picked != null) setState(() => fromDate = picked);
                    },
                    child: Text(
                      fromDate == null
                          ? 'From'
                          : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await _pickDate(context, toDate);
                      if (picked != null) setState(() => toDate = picked);
                    },
                    child: Text(
                      toDate == null
                          ? 'To'
                          : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: mythemecolor),
                  )
                : filteredDealers.isEmpty
                ? const Center(
                    child: Text(
                      "No dealers found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDealers.length,
                    itemBuilder: (context, index) {
                      final dealer = filteredDealers[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              const Color.fromARGB(
                                255,
                                185,
                                180,
                                189,
                              ).withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                247,
                                213,
                                246,
                              ).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(4, 6),
                            ),
                          ],
                          border: Border.all(
                            color: mythemecolor.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [mythemecolor, mythemecolor1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mythemecolor.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(2, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.storefront,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Dealer info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dealer['companyName'] ?? 'Unnamed Dealer',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: mythemecolor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _infoRow(
                                      Icons.person,
                                      dealer['username'] ?? 'N/A',
                                    ),
                                    _infoRow(
                                      Icons.location_on,
                                      dealer['address'] ?? 'N/A',
                                    ),
                                    _infoRow(
                                      Icons.phone,
                                      dealer['phoneNumber'] ?? 'N/A',
                                    ),
                                    _infoRow(
                                      Icons.email_outlined,
                                      dealer['email'] ?? 'N/A',
                                    ),
                                    _infoRow(
                                      Icons.badge_outlined,
                                      "GST: ${dealer['gstNumber'] ?? 'N/A'}",
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              dealer['isActive'] == true
                                              ? Colors.green
                                              : Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: _updatingDealerId == dealer['_id']
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Icon(
                                                dealer['isActive'] == true
                                                    ? Icons.toggle_on
                                                    : Icons.toggle_off,
                                                color: Colors.white,
                                              ),
                                        label: Text(
                                          dealer['isActive'] == true
                                              ? "Active"
                                              : "Inactive",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed:
                                            _updatingDealerId == dealer['_id']
                                            ? null
                                            : () async {
                                                final newStatus =
                                                    !(dealer['isActive'] ??
                                                        false);
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text(
                                                      "Confirm ${newStatus ? 'Activation' : 'Deactivation'}",
                                                      style: const TextStyle(
                                                        color: mythemecolor,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      "Are you sure you want to set this dealer as ${newStatus ? 'Active' : 'Inactive'}?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          "Cancel",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  mythemecolor1,
                                                            ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          "Yes",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm != true) return;

                                                setState(
                                                  () => _updatingDealerId =
                                                      dealer['_id'],
                                                );

                                                final result =
                                                    await DealerApiService.setUserActiveStatus(
                                                      dealerId: dealer['_id'],
                                                      isActive: newStatus,
                                                    );

                                                if (!mounted) return;
                                                setState(
                                                  () =>
                                                      _updatingDealerId = null,
                                                );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      result['message'] ??
                                                          'Status updated',
                                                    ),
                                                    backgroundColor:
                                                        result['success']
                                                        ? Colors.green
                                                        : Colors.redAccent,
                                                  ),
                                                );

                                                if (result['success']) {
                                                  setState(() {
                                                    dealer['isActive'] =
                                                        newStatus;
                                                  });
                                                }
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _infoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 16, color: mythemecolor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: mythemecolor,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}




// previous code before any filters
// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
// import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DealersListPage extends StatefulWidget {
//   const DealersListPage({super.key});

//   @override
//   State<DealersListPage> createState() => _DealersListPageState();
// }

// class _DealersListPageState extends State<DealersListPage> {
//   bool _isLoading = true;
//   List<dynamic> _dealers = [];
//   String? _updatingDealerId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDealers();
//   }

//   Future<void> _fetchDealers() async {
//     setState(() => _isLoading = true);

//     final response = await DealerApiService.fetchDealers();

//     setState(() {
//       _isLoading = false;
//       if (response['success']) {
//         _dealers = response['data'];
//       } else {
//         _dealers = [];
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(response['message'])));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const MarketerDrawer(currentPage: "Dealers Details"),
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
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             color: mythemecolor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: mythemecolor),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 'Registered Dealers!',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: mythemecolor,
//                 ),
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: mythemecolor),
//                   )
//                 : _dealers.isEmpty
//                 ? const Center(
//                     child: Text(
//                       "No dealers found",
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _dealers.length,
//                     itemBuilder: (context, index) {
//                       final dealer = _dealers[index];

//                       return Container(
//                         margin: const EdgeInsets.symmetric(vertical: 10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(18),
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.white,
//                               const Color.fromARGB(
//                                 255,
//                                 185,
//                                 180,
//                                 189,
//                               ).withOpacity(0.08),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color.fromARGB(
//                                 255,
//                                 247,
//                                 213,
//                                 246,
//                               ).withOpacity(0.25),
//                               blurRadius: 12,
//                               offset: const Offset(4, 6),
//                             ),
//                           ],
//                           border: Border.all(
//                             color: mythemecolor.withOpacity(0.15),
//                             width: 1,
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Left side avatar with gradient background
//                               Container(
//                                 width: 55,
//                                 height: 55,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: LinearGradient(
//                                     colors: [mythemecolor, mythemecolor1],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: mythemecolor.withOpacity(0.4),
//                                       blurRadius: 6,
//                                       offset: const Offset(2, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.storefront,
//                                   color: Colors.white,
//                                   size: 28,
//                                 ),
//                               ),

//                               const SizedBox(width: 16),

//                               // Dealer info
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       dealer['companyName'] ?? 'Unnamed Dealer',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         color: mythemecolor,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     _infoRow(
//                                       Icons.person,
//                                       dealer['username'] ?? 'N/A',
//                                     ),
//                                     _infoRow(
//                                       Icons.location_on,
//                                       dealer['address'] ?? 'N/A',
//                                     ),
//                                     _infoRow(
//                                       Icons.phone,
//                                       dealer['phoneNumber'] ?? 'N/A',
//                                     ),
//                                     _infoRow(
//                                       Icons.email_outlined,
//                                       dealer['email'] ?? 'N/A',
//                                     ),
//                                     _infoRow(
//                                       Icons.badge_outlined,
//                                       "GST: ${dealer['gstNumber'] ?? 'N/A'}",
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Align(
//                                       alignment: Alignment.centerRight,
//                                       child: ElevatedButton.icon(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor:
//                                               dealer['isActive'] == true
//                                               ? Colors.green
//                                               : Colors.red,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                         ),
//                                         icon: _updatingDealerId == dealer['_id']
//                                             ? const SizedBox(
//                                                 width: 18,
//                                                 height: 18,
//                                                 child:
//                                                     CircularProgressIndicator(
//                                                       color: Colors.white,
//                                                       strokeWidth: 2,
//                                                     ),
//                                               )
//                                             : Icon(
//                                                 dealer['isActive'] == true
//                                                     ? Icons.toggle_on
//                                                     : Icons.toggle_off,
//                                                 color: Colors.white,
//                                               ),
//                                         label: Text(
//                                           dealer['isActive'] == true
//                                               ? "Active"
//                                               : "Inactive",
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         onPressed:
//                                             _updatingDealerId == dealer['_id']
//                                             ? null
//                                             : () async {
//                                                 final newStatus =
//                                                     !(dealer['isActive'] ??
//                                                         false);
//                                                 final confirm = await showDialog<bool>(
//                                                   context: context,
//                                                   builder: (context) => AlertDialog(
//                                                     title: Text(
//                                                       "Confirm ${newStatus ? 'Activation' : 'Deactivation'}",
//                                                       style: const TextStyle(
//                                                         color: mythemecolor,
//                                                       ),
//                                                     ),
//                                                     content: Text(
//                                                       "Are you sure you want to set this dealer as ${newStatus ? 'Active' : 'Inactive'}?",
//                                                     ),
//                                                     actions: [
//                                                       TextButton(
//                                                         onPressed: () =>
//                                                             Navigator.pop(
//                                                               context,
//                                                               false,
//                                                             ),
//                                                         child: const Text(
//                                                           "Cancel",
//                                                         ),
//                                                       ),
//                                                       ElevatedButton(
//                                                         style:
//                                                             ElevatedButton.styleFrom(
//                                                               backgroundColor:
//                                                                   mythemecolor,
//                                                             ),
//                                                         onPressed: () =>
//                                                             Navigator.pop(
//                                                               context,
//                                                               true,
//                                                             ),
//                                                         child: const Text(
//                                                           "Yes",
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );

//                                                 if (confirm != true) return;

//                                                 setState(
//                                                   () => _updatingDealerId =
//                                                       dealer['_id'],
//                                                 );

//                                                 final result =
//                                                     await DealerApiService.setUserActiveStatus(
//                                                       dealerId: dealer['_id'],
//                                                       isActive: newStatus,
//                                                     );

//                                                 if (!mounted) return;
//                                                 setState(
//                                                   () =>
//                                                       _updatingDealerId = null,
//                                                 );

//                                                 ScaffoldMessenger.of(
//                                                   context,
//                                                 ).showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                       result['message'] ??
//                                                           'Status updated',
//                                                     ),
//                                                     backgroundColor:
//                                                         result['success']
//                                                         ? Colors.green
//                                                         : Colors.redAccent,
//                                                   ),
//                                                 );

//                                                 if (result['success']) {
//                                                   setState(() {
//                                                     dealer['isActive'] =
//                                                         newStatus;
//                                                   });
//                                                 }
//                                               },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget _infoRow(IconData icon, String text) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 2),
//     child: Row(
//       children: [
//         Icon(icon, size: 16, color: mythemecolor),
//         const SizedBox(width: 6),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(fontSize: 13.5, color: mythemecolor, height: 1.4),
//           ),
//         ),
//       ],
//     ),
//   );
// }

