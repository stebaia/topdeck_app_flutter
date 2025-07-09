import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pagina di TEST per verificare se il real-time di Supabase funziona
@RoutePage()
class TestRealtimePage extends StatefulWidget {
  const TestRealtimePage({Key? key}) : super(key: key);

  @override
  State<TestRealtimePage> createState() => _TestRealtimePageState();
}

class _TestRealtimePageState extends State<TestRealtimePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  List<Map<String, dynamic>> _lifePointsData = [];
  String _status = 'Not connected';
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
    _startRealtimeTest();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _startRealtimeTest() {
    print('🧪 TEST: Starting real-time test for life_points table');
    
    setState(() {
      _status = 'Connecting...';
    });

    _channel = _supabase
        .channel('test_life_points')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'life_points',
          callback: (payload) {
            print('🧪 TEST: Real-time event received!');
            print('🧪 TEST: Event type: ${payload.eventType}');
            print('🧪 TEST: Table: ${payload.table}');
            print('🧪 TEST: Schema: ${payload.schema}');
            print('🧪 TEST: New record: ${payload.newRecord}');
            print('🧪 TEST: Old record: ${payload.oldRecord}');
            
            setState(() {
              _updateCount++;
              _status = 'Received ${payload.eventType} event #$_updateCount';
            });
            
            _loadAllLifePoints();
          },
        )
        .subscribe((status, [error]) {
          print('🧪 TEST: Subscription status: $status');
          if (error != null) {
            print('🧪 TEST: Subscription error: $error');
            setState(() {
              _status = 'Error: $error';
            });
          } else {
            setState(() {
              _status = 'Status: $status';
            });
          }
        });

    // Carica i dati iniziali
    _loadAllLifePoints();
  }

  Future<void> _loadAllLifePoints() async {
    try {
      print('🧪 TEST: Loading all life points...');
      
      final response = await _supabase
          .from('life_points')
          .select()
          .order('updated_at', ascending: false);
      
      print('🧪 TEST: Loaded ${response.length} records');
      
      setState(() {
        _lifePointsData = List<Map<String, dynamic>>.from(response);
      });
      
    } catch (e) {
      print('🧪 TEST: Error loading data: $e');
      setState(() {
        _status = 'Load error: $e';
      });
    }
  }

  Future<void> _testUpdate() async {
    try {
      print('🧪 TEST: Performing test update...');
      
      // Prendi il primo record e incrementa i life points
      if (_lifePointsData.isNotEmpty) {
        final firstRecord = _lifePointsData.first;
        final currentLife = firstRecord['life'] as int;
        final newLife = currentLife + 100;
        
        await _supabase
            .from('life_points')
            .update({
              'life': newLife,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', firstRecord['id']);
        
        print('🧪 TEST: Updated record ${firstRecord['id']} from $currentLife to $newLife LP');
        
        setState(() {
          _status = 'Test update sent - waiting for real-time...';
        });
      }
      
    } catch (e) {
      print('🧪 TEST: Update error: $e');
      setState(() {
        _status = 'Update error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-time Status:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updates received: $_updateCount',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('SEND TEST UPDATE', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadAllLifePoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('RELOAD DATA', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data list
            const Text(
              'Life Points Data:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: _lifePointsData.isEmpty
                  ? const Center(child: Text('No data loaded'))
                  : ListView.builder(
                      itemCount: _lifePointsData.length,
                      itemBuilder: (context, index) {
                        final record = _lifePointsData[index];
                        return Card(
                          child: ListTile(
                            title: Text('Player: ${record['player_id']}'),
                            subtitle: Text(
                              'Life: ${record['life']} LP\n'
                              'Room: ${record['room_id']}\n'
                              'Updated: ${record['updated_at']}',
                            ),
                            trailing: Text(
                              'ID: ${record['id']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 