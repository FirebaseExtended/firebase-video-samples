import 'datasource/ai_remote_datasource.dart';
import 'datasource/auth_remote_datasource.dart';
import 'datasource/database_remote_datasource.dart';
import 'datasource/live_ai_remote_datasource.dart';
import 'datasource/remote_config_service.dart';
import 'datasource/storage_remote_datasource.dart';
import 'repository/ai_repository.dart';
import 'repository/auth_repository.dart';
import 'repository/database_repository.dart';
import 'repository/live_ai_repository.dart';
import 'repository/storage_repository.dart';

class AppRepositories {
  AppRepositories({
    required this.remoteConfigService,
    required this.authRepository,
    required this.databaseRepository,
    required this.storageRepository,
    required this.aiRepository,
    required this.liveAiRepository,
  });

  factory AppRepositories.create(RemoteConfigService remoteConfigService) {
    final authDataSource = AuthRemoteDataSource();
    final databaseDataSource = DatabaseRemoteDataSource();
    final storageDataSource = StorageRemoteDataSource();
    final aiDataSource = AIRemoteDataSource(remoteConfig: remoteConfigService);
    final liveAiDataSource = LiveAIRemoteDataSource(
      remoteConfig: remoteConfigService,
    );

    return AppRepositories(
      remoteConfigService: remoteConfigService,
      authRepository: AuthRepository(authDataSource),
      databaseRepository: DatabaseRepository(databaseDataSource),
      storageRepository: StorageRepository(storageDataSource),
      aiRepository: AIRepository(aiDataSource),
      liveAiRepository: LiveAIRepository(liveAiDataSource),
    );
  }

  final RemoteConfigService remoteConfigService;
  final AuthRepository authRepository;
  final DatabaseRepository databaseRepository;
  final StorageRepository storageRepository;
  final AIRepository aiRepository;
  final LiveAIRepository liveAiRepository;
}
