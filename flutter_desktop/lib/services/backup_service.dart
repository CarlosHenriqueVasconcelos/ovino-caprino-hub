import 'dart:async';

import '../data/backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  BackupService({required BackupRepository repository})
      : _repository = repository;

  Stream<String> backupAll() {
    final controller = StreamController<String>();
    () async {
      try {
        await _repository.backupMirrorRemote(onProgress: controller.add);
        controller.add('Concluído (upload).');
      } catch (e) {
        controller.add('Erro no upload: $e');
      } finally {
        await controller.close();
      }
    }();
    return controller.stream;
  }

  Stream<String> restoreAll() {
    final controller = StreamController<String>();
    () async {
      try {
        await _repository.restoreFromRemote(onProgress: controller.add);
        controller.add('Concluído (download).');
      } catch (e) {
        controller.add('Erro no download: $e');
      } finally {
        await controller.close();
      }
    }();
    return controller.stream;
  }
}
