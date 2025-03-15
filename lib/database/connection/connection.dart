// This file exports the appropriate connection implementation based on the platform
export 'connection_vm.dart' if (dart.library.html) 'connection_web.dart'; 