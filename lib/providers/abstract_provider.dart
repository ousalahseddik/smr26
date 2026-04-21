import 'dart:async';
import 'package:flutter/material.dart';
import '../models/abstract_model.dart';
import '../services/abstract_service.dart';
import '../services/storage_service.dart'; // ✅ NEW

class AbstractProvider extends ChangeNotifier {
  final AbstractService _service = AbstractService();

  // --- DATA ---
  List<AbstractModel> _abstracts = [];

  // --- CACHE in-memory ---
  final Map<String, List<AbstractModel>> _cache = {};

  // --- PAGINATION ---
  int _currentPage = 1;
  bool _hasNext = true;

  // --- SEARCH ---
  String _searchQuery = "";
  Timer? _debounce;

  // --- STATES ---
  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;

  // --- GETTERS ---
  List<AbstractModel> get abstracts => _abstracts;
  bool get hasNext => _hasNext;

  // ── Search ──────────────────────────────────────────────
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadInitial);
  }

  // ── Load Initial ────────────────────────────────────────
  Future<void> loadInitial() async {
    _currentPage = 1;
    _hasNext = true;
    errorMessage = null;

    // ✅ In-memory cache check
    if (_cache.containsKey(_searchQuery)) {
      _abstracts = _cache[_searchQuery]!;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.fetchAbstracts(_currentPage, _searchQuery);
      _abstracts = result['abstracts'];
      _hasNext = result['hasNext'];
      _cache[_searchQuery] = List.from(_abstracts);

      // ✅ Save persistent cache (empty search = full list)
      if (_searchQuery.isEmpty) {
        await StorageService.cacheAbstracts(
          _abstracts.map((a) => a.toJson()).toList(),
        );
      }
    } catch (e) {
      // ✅ Fallback to persistent cache
      if (_searchQuery.isEmpty) {
        final cached = await StorageService.getCachedAbstracts();
        if (cached != null) {
          _abstracts = cached.map((e) => AbstractModel.fromJson(e)).toList();
          _hasNext = false;
        } else {
          errorMessage = "Impossible de charger les abstracts";
        }
      } else {
        errorMessage = "Impossible de charger les abstracts";
      }
      debugPrint("❌ loadInitial abstracts: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Load More ───────────────────────────────────────────
  Future<void> loadMore() async {
    if (isFetchingMore || isLoading || !_hasNext) return;
    isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _service.fetchAbstracts(_currentPage, _searchQuery);
      _abstracts.addAll(result['abstracts']);
      _hasNext = result['hasNext'];
      _cache[_searchQuery] = List.from(_abstracts);

      // ✅ Update persistent cache
      if (_searchQuery.isEmpty) {
        await StorageService.cacheAbstracts(
          _abstracts.map((a) => a.toJson()).toList(),
        );
      }
    } catch (e) {
      _currentPage--;
      debugPrint("❌ loadMore abstracts: $e");
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
