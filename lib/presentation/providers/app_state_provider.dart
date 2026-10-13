import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  static const String _keyRecentSearches = 'app_recent_searches';
  static const String _keyNotifEnabled = 'app_notif_enabled';

  // Global Search & Filter State
  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  double? _minPrice;
  double? get minPrice => _minPrice;

  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  String? _selectedRoomType;
  String? get selectedRoomType => _selectedRoomType;

  String _sortBy = 'NEWEST'; // 'NEWEST', 'PRICE_ASC', 'PRICE_DESC', 'RATING_DESC'
  String get sortBy => _sortBy;

  // Recent Search History
  List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  // Global Notification & Badge State
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  // App Preferences
  bool _isNotificationEnabled = true;
  bool get isNotificationEnabled => _isNotificationEnabled;

  AppStateProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Recent Searches
      _recentSearches = prefs.getStringList(_keyRecentSearches) ?? [];

      // Load Notification Setting
      _isNotificationEnabled = prefs.getBool(_keyNotifEnabled) ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading app state preferences: $e');
    }
  }

  // --- Search & Filter State Actions ---
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    if (keyword.trim().isNotEmpty) {
      addRecentSearch(keyword.trim());
    }
    notifyListeners();
  }

  void setSelectedDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setSelectedRoomType(String? roomType) {
    _selectedRoomType = roomType;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchKeyword = '';
    _selectedDistrict = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedRoomType = null;
    _sortBy = 'NEWEST';
    notifyListeners();
  }

  // --- Recent Search History Actions ---
  Future<void> addRecentSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    _recentSearches.removeWhere((item) => item.toLowerCase() == keyword.toLowerCase());
    _recentSearches.insert(0, keyword.trim());
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyRecentSearches, _recentSearches);
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRecentSearches);
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  // --- Notification Badge Actions ---
  void setUnreadNotificationCount(int count) {
    _unreadNotificationCount = count < 0 ? 0 : count;
    notifyListeners();
  }

  void decrementUnreadCount() {
    if (_unreadNotificationCount > 0) {
      _unreadNotificationCount--;
      notifyListeners();
    }
  }

  // --- Preference Actions ---
  Future<void> toggleNotification(bool enabled) async {
    _isNotificationEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotifEnabled, enabled);
    } catch (e) {
      debugPrint('Error saving notification setting: $e');
    }
  }
}
