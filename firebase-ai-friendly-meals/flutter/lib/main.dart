import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/app_repositories.dart';
import 'data/datasource/remote_config_service.dart';
import 'firebase_options.dart';
import 'ui/generate/generate_screen.dart';
import 'ui/grocery_list/grocery_list_screen.dart';
import 'ui/live/live_assistant_screen.dart';
import 'ui/recipe/recipe_screen.dart';
import 'ui/recipe_list/filter_screen.dart';
import 'ui/recipe_list/recipe_list_controller.dart';
import 'ui/recipe_list/recipe_list_screen.dart';
import 'ui/scan_meal/scan_meal_screen.dart';
import 'ui/shared/bottom_nav_bar.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initializeAppCheck();

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  final repositories = AppRepositories.create(remoteConfigService);

  if (repositories.authRepository.currentUser == null) {
    try {
      final user = await repositories.authRepository.createAnonymousAccount();
      await repositories.databaseRepository.addUser(user);
    } catch (e) {
      debugPrint('Error creating anonymous guest user on startup: $e');
    }
  }

  runApp(FriendlyMealsApp(repositories: repositories));
}

Future<void> _initializeAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleDeviceCheckProvider(),
    );
  } catch (e) {
    debugPrint('Error activating Firebase App Check: $e');
  }
}

class FriendlyMealsApp extends StatefulWidget {
  const FriendlyMealsApp({
    super.key,
    required this.repositories,
  });

  final AppRepositories repositories;

  @override
  State<FriendlyMealsApp> createState() => _FriendlyMealsAppState();
}

class _FriendlyMealsAppState extends State<FriendlyMealsApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  BottomNavTab _selectedTab = BottomNavTab.generate;
  late final RecipeListController _recipeListController;

  @override
  void initState() {
    super.initState();
    _recipeListController = RecipeListController(widget.repositories);
  }

  @override
  void dispose() {
    _recipeListController.dispose();
    widget.repositories.remoteConfigService.dispose();
    super.dispose();
  }

  void _showError([String message = 'Sorry, something went wrong :(']) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onTabSelected(BottomNavTab tab) {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _selectedTab = tab;
    });
  }

  void _openRecipeScreen(String recipeId) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeScreen(
          key: ValueKey('recipe_$recipeId'),
          recipeId: recipeId,
          repositories: widget.repositories,
          navigateBack: () => _navigatorKey.currentState?.maybePop(),
          navigateToLiveAssistant: _openLiveAssistantScreen,
        ),
      ),
    );
  }

  void _openFilterScreen() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => FilterScreen(
          controller: _recipeListController,
          navigateBack: () => _navigatorKey.currentState?.maybePop(),
        ),
      ),
    );
  }

  void _openLiveAssistantScreen(String recipeId) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => LiveAssistantScreen(
          key: ValueKey('live_$recipeId'),
          recipeId: recipeId,
          repositories: widget.repositories,
          navigateBack: () => _navigatorKey.currentState?.maybePop(),
          showError: () => _showError('Error loading camera'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendly Meals',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      theme: FriendlyMealsTheme.lightTheme,
      home: PopScope(
        canPop: _selectedTab == BottomNavTab.generate,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_selectedTab != BottomNavTab.generate) {
            setState(() {
              _selectedTab = BottomNavTab.generate;
            });
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavBar(
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
          ),
          body: IndexedStack(
            index: _selectedTab.index,
            children: [
              ScanMealScreen(
                repositories: widget.repositories,
                showError: _showError,
              ),
              GenerateScreen(
                repositories: widget.repositories,
                openRecipeScreen: _openRecipeScreen,
                showError: _showError,
              ),
              RecipeListScreen(
                controller: _recipeListController,
                openRecipeScreen: _openRecipeScreen,
                openFilterScreen: _openFilterScreen,
              ),
              GroceryListScreen(
                repositories: widget.repositories,
                showError: _showError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
