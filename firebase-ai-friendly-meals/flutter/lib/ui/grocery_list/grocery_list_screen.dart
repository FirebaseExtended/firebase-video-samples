import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_repositories.dart';
import '../../data/model/grocery_item.dart';
import '../../data/schema/store_schema.dart';
import '../theme/app_theme.dart';

sealed class StoreFinderUiState {
  const StoreFinderUiState();
}

class StoreFinderIdle extends StoreFinderUiState {
  const StoreFinderIdle();
}

class StoreFinderLoading extends StoreFinderUiState {
  const StoreFinderLoading();
}

class StoreFinderSuccess extends StoreFinderUiState {
  const StoreFinderSuccess(this.stores);
  final List<StoreSchema> stores;
}

class StoreFinderError extends StoreFinderUiState {
  const StoreFinderError(this.message);
  final String message;
}

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({
    super.key,
    required this.repositories,
    required this.showError,
  });

  final AppRepositories repositories;
  final VoidCallback showError;

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  static const String _emptyItemsError =
      'Your grocery list is empty or all items are checked.';
  static const String _emptyStoreError = 'Failed to fetch local stores.';

  final TextEditingController _inputController = TextEditingController();
  final ValueNotifier<StoreFinderUiState> _storeFinderState =
      ValueNotifier<StoreFinderUiState>(const StoreFinderIdle());

  List<GroceryItem> _groceries = const [];
  StreamSubscription<List<GroceryItem>>? _groceriesSub;
  StreamSubscription<Object?>? _authSub;
  String _subscribedUid = '';

  String get _userId =>
      widget.repositories.authRepository.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadGroceries(_userId);
    _authSub = widget.repositories.authRepository.authStateChanges.listen(
      (user) {
        final uid = user?.uid ?? '';
        if (uid != _subscribedUid) {
          _loadGroceries(uid);
        }
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _groceriesSub?.cancel();
    _inputController.dispose();
    _storeFinderState.dispose();
    super.dispose();
  }

  void _loadGroceries(String uid) {
    _groceriesSub?.cancel();
    _subscribedUid = uid;
    if (uid.isEmpty) {
      if (mounted) {
        setState(() {
          _groceries = const [];
        });
      }
      return;
    }

    _groceriesSub = widget.repositories.databaseRepository
        .getGroceriesStream(uid)
        .listen(
      (items) {
        if (!mounted) return;
        setState(() {
          _groceries = items;
        });
      },
      onError: (Object e) {
        debugPrint('Error streaming groceries: $e');
      },
    );
  }

  Future<void> _handleAdd() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _userId.isEmpty) return;
    _inputController.clear();

    try {
      final item = GroceryItem(
        userId: _userId,
        name: text,
        checked: false,
      );
      await widget.repositories.databaseRepository.addGroceryItem(item);
    } catch (e) {
      debugPrint('Error adding grocery item: $e');
    }
  }

  Future<void> _toggleItem(GroceryItem item) async {
    try {
      await widget.repositories.databaseRepository
          .updateGroceryItemChecked(item.id, !item.checked);
    } catch (e) {
      debugPrint('Error toggling grocery item: $e');
    }
  }

  Future<void> _deleteItem(GroceryItem item) async {
    try {
      await widget.repositories.databaseRepository.deleteGroceryItem(item.id);
    } catch (e) {
      debugPrint('Error deleting grocery item: $e');
    }
  }

  Future<void> _startStoreFinder() async {
    if (!kIsWeb) {
      final statuses = await [
        Permission.locationWhenInUse,
        Permission.location,
      ].request();
      final granted =
          (statuses[Permission.locationWhenInUse]?.isGranted ?? false) ||
              (statuses[Permission.location]?.isGranted ?? false);
      if (!granted) {
        return;
      }
    }

    if (!mounted) return;
    _storeFinderState.value = const StoreFinderIdle();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return _StoreFinderBottomSheet(
          uiStateListenable: _storeFinderState,
          onRetry: _fetchLocationAndStores,
        );
      },
    ).whenComplete(() {
      _storeFinderState.value = const StoreFinderIdle();
    });

    await _fetchLocationAndStores();
  }

  Future<void> _fetchLocationAndStores() async {
    _storeFinderState.value = const StoreFinderIdle();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _findStores(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        Navigator.of(context).maybePop();
        widget.showError();
      }
    }
  }

  Future<void> _findStores(double latitude, double longitude) async {
    final uncheckedIngredients = _groceries
        .where((item) => !item.checked)
        .map((item) => item.name)
        .toList();

    if (uncheckedIngredients.isEmpty) {
      _storeFinderState.value = const StoreFinderError(_emptyItemsError);
      return;
    }

    _storeFinderState.value = const StoreFinderLoading();

    try {
      final now = DateTime.now();
      final dayOfWeek = DateFormat('EEEE', 'en_US').format(now);
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final stores = await widget.repositories.aiRepository.findStores(
        ingredients: uncheckedIngredients,
        latitude: latitude,
        longitude: longitude,
        currentTime: currentTime,
        dayOfWeek: dayOfWeek,
      );

      if (stores.isEmpty) {
        _storeFinderState.value = const StoreFinderError(_emptyStoreError);
      } else {
        _storeFinderState.value = StoreFinderSuccess(stores);
      }
    } catch (e) {
      debugPrint('Error finding stores: $e');
      _storeFinderState.value = const StoreFinderError(_emptyStoreError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unfocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderColor),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'Grocery List',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: _startStoreFinder,
                    tooltip: 'Store Finder',
                    icon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.teal,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleAdd(),
                        decoration: InputDecoration(
                          hintText: 'Add an ingredient…',
                          hintStyle: const TextStyle(color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: unfocusedBorder,
                          enabledBorder: unfocusedBorder,
                          focusedBorder: focusedBorder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                        semanticLabel: 'Add',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _groceries.isEmpty
                  ? const Center(
                      child: Text(
                        'Your grocery list is empty',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _groceries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _groceries[index];
                        return _GroceryCard(
                          key: ValueKey(item.id),
                          item: item,
                          onToggle: () => _toggleItem(item),
                          onDelete: () => _deleteItem(item),
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

class _GroceryCard extends StatelessWidget {
  const _GroceryCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: item.checked ? 0 : 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.checked
                            ? AppColors.teal
                            : AppColors.lightTeal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: item.checked
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.checked
                              ? Colors.grey
                              : AppColors.textColor,
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          height: 22 / 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreFinderBottomSheet extends StatelessWidget {
  const _StoreFinderBottomSheet({
    required this.uiStateListenable,
    required this.onRetry,
  });

  final ValueListenable<StoreFinderUiState> uiStateListenable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoreFinderUiState>(
      valueListenable: uiStateListenable,
      builder: (context, uiState, _) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Ingredient-to-Store Finder',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Find stores nearby with the ingredients you need.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Flexible(
                  child: switch (uiState) {
                    StoreFinderIdle() => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  color: AppColors.teal,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Determining your location…',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    StoreFinderLoading() => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  color: AppColors.teal,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Locating nearest stores with Google Maps…',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    StoreFinderError(:final message) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: onRetry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    StoreFinderSuccess(:final stores) => stores.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No stores found matching your ingredients nearby.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: stores.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _StoreCard(store: stores[index]);
                            },
                          ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final StoreSchema store;

  Future<void> _openMapUrl() async {
    final rawUrl = store.mapUrl.trim();
    if (rawUrl.isEmpty) return;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    if (uri.scheme != 'https' && uri.scheme != 'http' && uri.scheme != 'geo') {
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch store map URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingColor =
        store.hasParking ? const Color(0xFFE3F2FD) : const Color(0xFFECEFF1);
    final parkingTextColor =
        store.hasParking ? const Color(0xFF1565C0) : const Color(0xFF455A64);
    final parkingLabel =
        store.hasParking ? '🅿️ Parking Available' : 'No Parking';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: store.mapUrl.trim().isNotEmpty ? _openMapUrl : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (store.openNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 8, height: 8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Open Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFE57373),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 8, height: 8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Closed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (store.closingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9800),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 8, height: 8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Closing Soon',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF6C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: parkingColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      parkingLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: parkingTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (store.parkingDetails.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  store.parkingDetails,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 16 / 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
