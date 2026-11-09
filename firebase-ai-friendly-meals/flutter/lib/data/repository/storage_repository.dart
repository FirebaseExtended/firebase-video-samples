import 'dart:typed_data';
import '../datasource/storage_remote_datasource.dart';

class StorageRepository {
  StorageRepository(this._storageRemoteDataSource);

  final StorageRemoteDataSource _storageRemoteDataSource;

  Future<String> addImage(Uint8List imageBytes) {
    return _storageRemoteDataSource.addImage(imageBytes);
  }
}
