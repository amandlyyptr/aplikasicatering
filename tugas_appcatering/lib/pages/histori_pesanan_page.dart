import 'package:flutter/material.dart';
import '../models/history_pemesanan_model.dart';
import '../services/history_service.dart';

class HistoryPesananPage extends StatefulWidget {
  final String uid;
  const HistoryPesananPage({super.key, required this.uid});

  @override
  State<HistoryPesananPage> createState() => _HistoryPesananPageState();
}

class _HistoryPesananPageState extends State<HistoryPesananPage> {
  late Future<List<HistoryPemesanan>> futureHistory;

  @override
  void initState() {
    super.initState();
    futureHistory = HistoryService.fetchHistory(widget.uid);
  }

  void _refreshHistory() {
    setState(() {
      futureHistory = HistoryService.fetchHistory(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan'),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<HistoryPemesanan>>(
        future: futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF800000)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pemesanan'));
          } else {
            final historyList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color(0xFFFAE6E6),
                  child: ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Color(0xFF800000),
                    ),
                    title: Text(
                      item.namaMakanan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800000),
                      ),
                    ),
                    subtitle: Text(
                      item.waktuPesan,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Hapus Riwayat'),
                                content: const Text(
                                  'Yakin ingin menghapus riwayat ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await HistoryService.deleteHistory(item.id);
                          _refreshHistory();
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
