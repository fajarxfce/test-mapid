import 'package:core_common/core_common.dart';
import 'package:core_data/src/storage/memory_credential_store.dart';
import 'package:core_data/src/storage/secure_credential_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Uses memory on web; native platforms use OS credential storage.
CredentialStore createCredentialStore(String namespace) => kIsWeb
    ? MemoryCredentialStore()
    : SecureCredentialStore(
        const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        ),
        namespace,
      );
