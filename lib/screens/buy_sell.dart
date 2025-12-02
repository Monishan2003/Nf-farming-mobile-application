import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../field_footer.dart';
// imports updated - footer navigation handled centrally by AppFooter
// DevicePreview removed - running app without preview wrapper.
import 'dart:math' as math;
import 'dart:collection';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'bill_detail_screen.dart';
import '../session.dart';

// Central bill history for reporting
final List<BillDetailData> billHistory = [];

// Simple in-memory model to make future DB integration easy.
class Farmer {
  final String id;
  String name;
  String phone;
  String address;
  String mobile;
  String nic;
  String billNumber;
  String fieldVisitorCode;
  double totalBuy;
  double totalSell;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.mobile,
    required this.nic,
    this.fieldVisitorCode = '',
    this.billNumber = '',
    this.totalBuy = 0.0,
    this.totalSell = 0.0,
  });
}

// A small donut widget to show an independent percentage (non-linked pies)
// Removed SmallPie and painters — pies are no longer displayed.

class FarmerStore extends ChangeNotifier {
  final List<Farmer> _farmers = [
    Farmer(id: '1', name: 'Salman', phone: '03250', address: 'Jaffna', mobile: '0717233478', nic: '4001', billNumber: 'B001', fieldVisitorCode: '', totalBuy: 10000.0, totalSell: 20000.0),
    Farmer(id: '2', name: 'Ram kumar', phone: '0712345678', address: 'Jaffna,Srilanka', mobile: '071234678', nic: '1001', billNumber: 'B002', fieldVisitorCode: '', totalBuy: 0.0, totalSell: 0.0),
  ];

  String _query = '';
  Farmer? _selected;

  UnmodifiableListView<Farmer> get farmers => UnmodifiableListView(_farmers);

  List<Farmer> get filteredFarmers {
    if (_query.isEmpty) return List.from(_farmers);
    final q = _query.toLowerCase();
    return _farmers.where((f) => f.name.toLowerCase().contains(q) || f.mobile.toLowerCase().contains(q) || f.billNumber.toLowerCase().contains(q)).toList();
  }

  Farmer? get selected => _selected;

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void selectFarmer(Farmer f) {
    _selected = f;
    notifyListeners();
  }

  /// Add a new farmer to the store.
  void addFarmer(Farmer f) {
    _farmers.add(f);
    notifyListeners();
  }

  /// Ensure a farmer with [name] exists and select it. If not present, create a minimal record.
  void selectOrCreateByName(String name) {
    try {
      final existing = _farmers.firstWhere((f) => f.name == name);
      selectFarmer(existing);
      return;
    } catch (_) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final f = Farmer(id: id, name: name, phone: '', address: '', mobile: '', nic: '', billNumber: '', fieldVisitorCode: AppSession.displayFieldCode);
      _farmers.add(f);
      selectFarmer(f);
      notifyListeners();
    }
  }

  double get totalBuyAll => _farmers.fold(0.0, (p, e) => p + e.totalBuy);
  double get totalSellAll => _farmers.fold(0.0, (p, e) => p + e.totalSell);

  void addBuy(double amount) {
    if (_selected != null) {
      _selected!.totalBuy += amount;
      notifyListeners();
    }
  }

  void addSell(double amount) {
    if (_selected != null) {
      _selected!.totalSell += amount;
      notifyListeners();
    }
  }
}

final FarmerStore farmerStore = FarmerStore();

// Global theme notifier so any widget can toggle light/dark mode.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() { runApp(const FarmerManagementApp()); }

class FarmerManagementApp extends StatelessWidget {
  /// Optional override for the app's `home` widget. Useful for previewing
  /// individual screens (e.g. `FieldVisitorDashboard`) while reusing the
  /// same app theme.
  final Widget? homeOverride;

  const FarmerManagementApp({super.key, this.homeOverride});

  @override
  Widget build(BuildContext context) {
    // Listen to themeNotifier to rebuild MaterialApp with the selected ThemeMode
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Farmer Management System',
          themeMode: mode,
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: const Color(0xFFE6FFEF),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: const Color(0xFF0B1412),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B1412)),
            cardColor: const Color(0xFF0F1A18),
          ),
          home: homeOverride ?? const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // current view: 'dashboard', 'buy', 'sell'
  String _view = 'dashboard';
  // navigation index removed - footer handles navigation centrally

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_view == 'dashboard' ? 'Farmer Management System' : (_view == 'buy' ? 'Buy' : 'Sell')),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: _view == 'dashboard' ? null : BackButton(onPressed: () => setState(() => _view = 'dashboard')),
      ),
      body: _view == 'dashboard'
          ? DashboardScreen(
              onBuy: () => setState(() => _view = 'buy'),
              onSell: () => setState(() => _view = 'sell'),
            )
          : (_view == 'buy'
              ? BuyingScreen(onFinished: () => setState(() => _view = 'dashboard'))
              : SellingScreen(onFinished: () => setState(() => _view = 'dashboard'))),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onBuy;
  final VoidCallback? onSell;
  const DashboardScreen({super.key, this.onBuy, this.onSell});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    farmerStore.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  @override
  void dispose() {
    farmerStore.removeListener(_onStoreChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = farmerStore.filteredFarmers;
    final selected = farmerStore.selected ?? (filtered.isNotEmpty ? filtered.first : null);
    final buyTotal = selected?.totalBuy ?? 0.0;
    final sellTotal = selected?.totalSell ?? 0.0;
    // Totals are independent; no comparative percentage computed.

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar (name, mobile, or bill no)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (v) => farmerStore.setQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search by name, mobile or Bill number...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Matching farmers list
          if (filtered.isNotEmpty) ...[
            ListView.builder(
              itemCount: filtered.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                final f = filtered[i];
                return ListTile(
                  title: Text(f.name),
                  subtitle: Text(f.mobile),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Buy: ${f.totalBuy.toStringAsFixed(0)}'), Text('Sell: ${f.totalSell.toStringAsFixed(0)}')],
                  ),
                  onTap: () => farmerStore.selectFarmer(f),
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          // Details for the selected (or first) farmer
          Card(
            color: const Color(0xFFE6FFEF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Farmer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (selected != null) ...[
                    DetailRow(label: 'Name', value: selected.name),
                    DetailRow(label: 'Address', value: selected.address),
                    DetailRow(label: 'NIC No', value: selected.nic),
                    DetailRow(label: 'Mobile Number', value: selected.mobile),
                    DetailRow(label: 'Bill Number', value: selected.billNumber),
                  ] else ...[
                    const Text('No farmer selected', style: TextStyle(fontStyle: FontStyle.italic)),
                  ]
                ],
              ),
            ),
          ),

          // Quick actions to show the Buy / Sell sections (moved below Farmer Details)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onBuy,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Buy', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onSell,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Sell', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: const Color(0xFFE6FFEF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Selected Total Buy', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(buyTotal.toStringAsFixed(0), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.red[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Selected Total Sell', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(sellTotal.toStringAsFixed(0), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  
}

class BuyingScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const BuyingScreen({super.key, this.onFinished});

  @override
  State<BuyingScreen> createState() => _BuyingScreenState();
}

class _BuyingScreenState extends State<BuyingScreen> {
  String _stage = 'initial'; // initial, confirmation, done
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedProduct = 'Alo Vera Small (Packet)';

  @override
  Widget build(BuildContext context) {
    if (_stage == 'confirmation') {
      return _buildConfirmationScreen();
    } else if (_stage == 'done') {
      return _buildDoneScreen();
    }
    return _buildInitialScreen();
  }

  Widget _buildInitialScreen() {
    // Do NOT auto-fill values; show empty placeholders for manual input
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          // product selector
          Row(
            children: [
              const Text('Product: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedProduct,
                items: const [
                  DropdownMenuItem(value: 'Alo Vera leaf', child: Text('Alo Vera leaf')),
                  DropdownMenuItem(value: 'Alo Vera Small (Packet)', child: Text('Alo Vera Small (Packet)')),
                  DropdownMenuItem(value: 'Alo Vera Small', child: Text('Alo Vera Small')),
                ],
                onChanged: (v) => setState(() {
                  _selectedProduct = v!;
                  _countController.clear();
                  _priceController.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProductCard(_selectedProduct),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFE6FFEF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buying Confirmation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DetailRow(label: _selectedProduct, value: ''),
                  DetailRow(label: 'Count', value: _countController.text),
                  DetailRow(label: 'Current Price', value: _priceController.text),
                  DetailRow(label: 'total price', value: _computeTotal()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
              child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_computeTotal()) ?? 0.0;
                farmerStore.addBuy(amount);
                final f = farmerStore.selected;
                final billNo = _genBillNo(prefix: 'B');
                final detail = BillDetailData(
                  billNo: billNo,
                  type: 'BUY',
                  date: DateTime.now(),
                  memberName: f?.name ?? 'Iben Israar',
                  memberPhone: f?.mobile ?? '0717234478',
                  memberAddress: f?.address ?? 'Jaffna,Srilanka',
                  product: _selectedProduct,
                  quantityLabel: 'Count',
                  quantity: int.tryParse(_countController.text) ?? 0,
                  unitPrice: double.tryParse(_priceController.text) ?? 0.0,
                  total: amount,
                  fieldVisitorName: AppSession.displayFieldName,
                  fieldVisitorPhone: AppSession.displayFieldPhone,
                  fieldVisitorCode: AppSession.displayFieldCode,
                  companyName: 'Nature Farming',
                );
                // Save to central bill history for reporting
                billHistory.add(detail);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BillDetailScreen(data: detail)),
                );
                if (mounted) widget.onFinished?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Confirmed', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 80),
          const SizedBox(height: 16),
          const Text('Purchase Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _stage = 'initial'),
            child: const Text('New Purchase'),
          ),
        ],
      ),
    );
  }

  

  Widget _buildHeader() {
    final f = farmerStore.selected;
    return Card(
      color: const Color(0xFFE6FFEF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (f != null) ...[
              DetailRow(label: 'Name', value: f.name),
              DetailRow(label: 'Address', value: f.address),
              DetailRow(label: 'Mobile Number', value: f.mobile),
              DetailRow(label: 'NIC No.', value: f.nic),
            ] else ...[
              const DetailRow(label: 'Name', value: 'Iben Israar'),
              const DetailRow(label: 'Address', value: 'Jaffna,Srilanka'),
              const DetailRow(label: 'Mobile Number', value: '0717234478'),
              const DetailRow(label: 'NIC No.', value: '4001'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: [
                TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Count', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Price', hintText: 'Enter the current price', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(_computeTotal(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _stage = 'confirmation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart),
                        SizedBox(width: 8),
                        Text('Proceed to Buy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _computeTotal() {
    final count = int.tryParse(_countController.text.replaceAll(',', '')) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;
    final total = count * price;
    return total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _countController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class SellingScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const SellingScreen({super.key, this.onFinished});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  String _stage = 'initial';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  String _selectedSellProduct = 'Alo Vera leaf';

  @override
  Widget build(BuildContext context) {
    if (_stage == 'confirmation') {
      return _buildConfirmationScreen();
    } else if (_stage == 'done') {
      return _buildDoneScreen();
    }
    return _buildInitialScreen();
  }

  Widget _buildInitialScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),

          SectionCard(
            title: 'Selling',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Product: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedSellProduct,
                      items: const [
                        DropdownMenuItem(value: 'Alo Vera leaf', child: Text('Alo Vera leaf')),
                        DropdownMenuItem(value: 'Alo Vera Small (Packet)', child: Text('Alo Vera Small (Packet)')),
                        DropdownMenuItem(value: 'Alo Vera Small', child: Text('Alo Vera Small')),
                      ],
                      onChanged: (v) => setState(() {
                        _selectedSellProduct = v!;
                        _weightController.clear();
                        _sellPriceController.clear();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_selectedSellProduct, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                // color applied via surrounding theme or AppColors where needed
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'weight', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sellPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Price', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DetailRow(label: 'total price', value: _computeSellTotal()),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _stage = 'confirmation'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Sell', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Selling Confirmation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: _selectedSellProduct, value: ''),
                DetailRow(label: 'weight', value: _weightController.text),
                DetailRow(label: 'Current Price', value: _sellPriceController.text),
                DetailRow(label: 'total price', value: _computeSellTotal()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
              child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_computeSellTotal()) ?? 0.0;
                farmerStore.addSell(amount);
                final f = farmerStore.selected;
                final billNo = _genBillNo(prefix: 'S');
                final detail = BillDetailData(
                  billNo: billNo,
                  type: 'SELL',
                  date: DateTime.now(),
                  memberName: f?.name ?? 'Iben Israar',
                  memberPhone: f?.mobile ?? '0717234478',
                  memberAddress: f?.address ?? 'Jaffna,Srilanka',
                  product: _selectedSellProduct,
                  quantityLabel: 'Weight',
                  quantity: int.tryParse(_weightController.text) ?? 0,
                  unitPrice: double.tryParse(_sellPriceController.text) ?? 0.0,
                  total: amount,
                  fieldVisitorName: AppSession.displayFieldName,
                  fieldVisitorPhone: AppSession.displayFieldPhone,
                  fieldVisitorCode: AppSession.displayFieldCode,
                  companyName: 'Nature Farming',
                );
                // Save to central bill history for reporting
                billHistory.add(detail);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BillDetailScreen(data: detail)),
                );
                if (mounted) widget.onFinished?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Confirmed', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          const Text('Sale Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _stage = 'initial'),
            child: const Text('New Sale'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final f = farmerStore.selected;
    return Card(
      color: const Color(0xFFE6FFEF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (f != null) ...[
              DetailRow(label: 'Name', value: f.name),
              DetailRow(label: 'Address', value: f.address),
              DetailRow(label: 'Mobile Number', value: f.mobile),
              DetailRow(label: 'NIC No.', value: f.nic),
            ] else ...[
              const DetailRow(label: 'Name', value: 'Iben Israar'),
              const DetailRow(label: 'Address', value: 'Jaffna,Srilanka'),
              const DetailRow(label: 'Mobile Number', value: '0717234478'),
              const DetailRow(label: 'NIC No.', value: '4001'),
            ]
          ],
        ),
      ),
    );
  }

  String _computeSellTotal() {
    final qty = int.tryParse(_weightController.text.replaceAll(',', '')) ?? 0;
    final price = double.tryParse(_sellPriceController.text.replaceAll(',', '')) ?? 0.0;
    return (qty * price).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                  fontSize: 14)),
          Text(value),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;

  /// When [strokeWidth] > 0 the painter draws a donut (stroke) chart. Otherwise it draws a filled pie.

  PieChartPainter({required this.percentage, required this.color, this.backgroundColor, this.strokeWidth = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;

    if (strokeWidth > 0) {
      final bgPaint = Paint()
        ..color = backgroundColor ?? Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final rect = Rect.fromCircle(center: center, radius: radius);
      // draw full background ring (start at top for consistency)
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bgPaint);
      // draw foreground arc starting at top (-pi/2)
      canvas.drawArc(rect, -math.pi / 2, percentage * 2 * math.pi, false, fgPaint);
    } else {
      final backgroundPaint = Paint()
        ..color = backgroundColor ?? Colors.grey[300]!
        ..style = PaintingStyle.fill;

      final foregroundPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, backgroundPaint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        percentage * 2 * math.pi,
        true,
        foregroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is PieChartPainter) {
      return oldDelegate.percentage != percentage || oldDelegate.color != color;
    }
    return true;
  }
}

// Animated wrapper for pie chart that smoothly animates to the target percentage.
class AnimatedPieChart extends StatefulWidget {
  final double percentage;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;
  final Widget? child;
  const AnimatedPieChart({super.key, required this.percentage, required this.color, this.backgroundColor, this.strokeWidth = 0.0, this.child});

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  double _lastTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _lastTarget = widget.percentage;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0.0, end: widget.percentage).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.percentage != _lastTarget) {
      _controller.stop();
      _controller.reset();
      _anim = Tween<double>(begin: 0.0, end: widget.percentage).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
        ..addListener(() => setState(() {}));
      _lastTarget = widget.percentage;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PieChartPainter(percentage: _anim.value, color: widget.color, backgroundColor: widget.backgroundColor, strokeWidth: widget.strokeWidth),
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}

// Removed SellingAlternateScreen per request: alternate UI no longer used.

// A small reusable widget that renders a green title strip and content card beneath it
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }
}

// A styled card showing a donut-style pie chart, legend and amount (used on Dashboard).
// StatPieCard removed — dashboard uses simple stat cards + pie charts now.

// ---------------------------
// Bill popup + PDF utilities
// ---------------------------

class BillData {
  final String billNo;
  final String type; // BUY or SELL
  final DateTime date;
  final String customerName;
  final String customerMobile;
  final String customerAddress;
  final String product;
  final String quantityLabel; // Count or Weight
  final int quantity;
  final double unitPrice;
  final double total;

  BillData({
    required this.billNo,
    required this.type,
    required this.date,
    required this.customerName,
    required this.customerMobile,
    required this.customerAddress,
    required this.product,
    required this.quantityLabel,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

String _genBillNo({required String prefix}) {
  final now = DateTime.now();
  final y = now.year.toString();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  final seq = now.millisecondsSinceEpoch.toString().substring(8);
  return 'NF-$prefix-$y$m$d-$seq';
}

Future<void> showBillDialog(BuildContext context, BillData data) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nature Farming', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('${data.type} BILL  •  ${data.billNo}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _billRow('Date', _fmtDateTime(data.date)),
                  _billRow('Customer', data.customerName),
                  _billRow('Mobile', data.customerMobile),
                  _billRow('Address', data.customerAddress),
                  const Divider(height: 24),
                  _billRow('Product', data.product),
                  _billRow(data.quantityLabel, data.quantity.toString()),
                  _billRow('Unit Price', data.unitPrice.toStringAsFixed(2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(data.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final bytes = await buildBillPdf(data);
              await Printing.sharePdf(bytes: bytes, filename: 'NF_${data.type}_${data.billNo}.pdf');
            },
            icon: const Icon(Icons.download, size: 18, color: Colors.white),
            label: const Text('Download', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          ),
        ],
      );
    },
  );
}

Widget _billRow(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54)),
        Flexible(child: Text(v, textAlign: TextAlign.right)),
      ],
    ),
  );
}

String _fmtDateTime(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

Future<Uint8List> buildBillPdf(BillData data) async {
  final pdf = pw.Document();
  final c = AppColors.primaryGreen;
  final int a = ((c.a * 255.0).round() & 0xff);
  final int r = ((c.r * 255.0).round() & 0xff);
  final int g = ((c.g * 255.0).round() & 0xff);
  final int b = ((c.b * 255.0).round() & 0xff);
  final int argb = (a << 24) | (r << 16) | (g << 8) | b;
  final green = PdfColor.fromInt(argb);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              color: green,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('Nature Farming', style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('${data.type} BILL', style: const pw.TextStyle(color: PdfColors.white))
                  ]),
                  pw.Text(data.billNo, style: const pw.TextStyle(color: PdfColors.white))
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            _pdfKeyValue('Date', _fmtDateTime(data.date)),
            _pdfKeyValue('Customer', data.customerName),
            _pdfKeyValue('Mobile', data.customerMobile),
            _pdfKeyValue('Address', data.customerAddress),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _pdfKeyValue('Product', data.product),
            _pdfKeyValue(data.quantityLabel, data.quantity.toString()),
            _pdfKeyValue('Unit Price', data.unitPrice.toStringAsFixed(2)),
            pw.SizedBox(height: 8),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text(data.total.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ]),
          ]),
        );
      },
    ),
  );

  return Uint8List.fromList(await pdf.save());
}

pw.Widget _pdfKeyValue(String k, String v) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(k, style: const pw.TextStyle(color: PdfColors.grey)),
      pw.Expanded(child: pw.Text(v, textAlign: pw.TextAlign.right)),
    ]),
  );
}