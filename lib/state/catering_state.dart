import 'package:flutter/foundation.dart';
import '../models/catalogue_item.dart';
import '../services/catalogue_api.dart';

class CateringState extends ChangeNotifier {
  CateringState(this._api);
  final CatalogueApi _api;

  bool isLoading = false;
  String? error;
  List<CatalogueItem> items = [];
  int guests = 20;
  String selectedCategory = 'All';
  String searchQuery = '';
  final Set<String> _selectedFoodIds = {};
  final Map<String, int> _addOnCounts = {};

  List<CatalogueItem> get foodItems => items.where((item) => item.isFood).toList();
  List<CatalogueItem> get addOnItems => items.where((item) => item.isAddOn).toList();
  Set<String> get selectedFoodIds => Set.unmodifiable(_selectedFoodIds);
  Map<String, int> get addOnCounts => Map.unmodifiable(_addOnCounts);
  List<String> get categories {
    final values = foodItems.map((e) => e.categoryLabel).toSet().toList()..sort();
    return ['All', ...values];
  }
  List<CatalogueItem> get visibleFoodItems {
    final query = searchQuery.trim().toLowerCase();
    return foodItems.where((item) {
      final categoryMatch = selectedCategory == 'All' || item.categoryLabel == selectedCategory;
      final searchMatch = query.isEmpty || item.displayName.toLowerCase().contains(query) || item.categoryLabel.toLowerCase().contains(query);
      return categoryMatch && searchMatch;
    }).toList();
  }
  List<CatalogueItem> get selectedFoods => foodItems.where((item) => _selectedFoodIds.contains(item.stableId)).toList();
  List<CatalogueItem> get selectedAddOns => addOnItems.where((item) => (_addOnCounts[item.stableId] ?? 0) > 0).toList();
  int addOnCount(CatalogueItem item) => _addOnCounts[item.stableId] ?? 0;
  bool isFoodSelected(CatalogueItem item) => _selectedFoodIds.contains(item.stableId);
  double get foodTotal => selectedFoods.fold(0, (sum, item) => sum + item.perPersonPrice * guests);
  double get addOnTotal => selectedAddOns.fold(0, (sum, item) => sum + item.fixedPrice * addOnCount(item));
  double get total => foodTotal + addOnTotal;
  double get perGuestTotal => selectedFoods.fold(0, (sum, item) => sum + item.perPersonPrice);

  Future<void> loadCatalogue() async {
    isLoading = true; error = null; notifyListeners();
    try {
      items = await _api.fetchCatalogue();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setGuests(int value) { guests = value.clamp(1, 10000); notifyListeners(); }
  void setCategory(String value) { selectedCategory = value; notifyListeners(); }
  void setSearch(String value) { searchQuery = value; notifyListeners(); }
  void toggleFood(CatalogueItem item) {
    if (!_selectedFoodIds.add(item.stableId)) _selectedFoodIds.remove(item.stableId);
    notifyListeners();
  }
  void setAddOnCount(CatalogueItem item, int count) {
    if (count <= 0) { _addOnCounts.remove(item.stableId); }
    else { _addOnCounts[item.stableId] = count.clamp(0, 999); }
    notifyListeners();
  }
  void clearCart() { _selectedFoodIds.clear(); _addOnCounts.clear(); notifyListeners(); }
}
