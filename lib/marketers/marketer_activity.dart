import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketerActivityPage extends StatefulWidget {
  const MarketerActivityPage({super.key});

  @override
  State<MarketerActivityPage> createState() => _MarketerActivityPageState();
}

class _MarketerActivityPageState extends State<MarketerActivityPage> {
  List allLogs = []; // Full list from API
  List pageLogs = []; // Only logs for current page
  bool isLoading = true;

  int currentPage = 1;
  final int pageSize = 5; // 👈 Show only 5 logs per page
  int totalPages = 1;

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

      // Calculate total pages
      totalPages = (allLogs.length / pageSize).ceil();

      _updatePageLogs();

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'])));
    }
  }

  void _updatePageLogs() {
    int start = (currentPage - 1) * pageSize;
    int end = start + pageSize;

    setState(() {
      pageLogs = allLogs.sublist(
        start,
        end > allLogs.length ? allLogs.length : end,
      );
    });
  }

  Color _getActionColor(String action) {
    if (action == 'CREATE_DEALER') {
      return const Color.fromARGB(255, 229, 238, 230);
    }
    if (action == 'ACTIVATE_DEALER') {
      return const Color.fromARGB(255, 221, 233, 244);
    }
    if (action == 'DEACTIVATE_DEALER') {
      return const Color.fromARGB(255, 173, 172, 172);
    }
    if (action == 'APPROVE_DEALER') {
      return const Color.fromARGB(255, 196, 218, 216);
    }
    if (action == 'REJECT_DEALER') {
      return const Color.fromARGB(255, 218, 207, 208);
    }
    if (action == 'VERIFY_GST') return const Color.fromARGB(255, 235, 228, 218);
    if (action == 'LOGIN') return const Color.fromARGB(255, 236, 217, 187);

    return Colors.grey.shade200;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('CREATE')) return Icons.add_circle_outline;
    if (action.contains('ACTIVATE_DEALER')) return Icons.toggle_on;
    if (action.contains('DEACTIVATE_DEALER')) return Icons.toggle_off;
    if (action.contains('APPROVE')) return Icons.check_circle;
    if (action.contains('REJECT')) return Icons.cancel;
    if (action.contains('VERIFY')) return Icons.verified;
    if (action == 'LOGIN') return Icons.login;

    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MarketerDrawer(currentPage: "Activity Log"),
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
                'Activity Log!',
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                currentPage = 1;
                await _loadActivities();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: ListView.builder(
                  itemCount: pageLogs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == pageLogs.length) {
                      return _paginationWidget();
                    }

                    final log = pageLogs[index];

                    return Card(
                      color: _getActionColor(log['actionType'] ?? ''),
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: ListTile(
                        leading: Icon(_getActionIcon(log['actionType'] ?? '')),
                        title: Text(
                          log["actionType"] ?? "",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text("""
User: ${log["userName"] ?? ''}
Role: ${log["role"] ?? ''}
Resource: ${log["targetResourceName"] ?? '-'}
Status: ${log["status"] ?? '-'}
Time: ${DateTime.tryParse(log["createdAt"] ?? '')?.toLocal() ?? ''}
Description: ${log["description"] ?? ''}
                          """, style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _paginationWidget() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // ------------ PREV BUTTON ------------
        GradientButtons(
          text: "PREV",
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;       // 👈 Go to previous page
                    _updatePageLogs();   // 👈 Refresh log view
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

        // ------------ NEXT BUTTON ------------
        GradientButtons(
          text: "NEXT",
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;       // 👈 Go to next page
                    _updatePageLogs();   // 👈 Refresh log view
                  });
                }
              : null,
        ),
      ],
    ),
  );
}

}



class GradientButtons extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;   

  const GradientButtons({
    super.key,
    required this.text,
    this.onPressed,                
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,   
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [mythemecolor, mythemecolor1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,     
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

