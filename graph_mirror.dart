import 'dart:io';
import 'dart:mirrors';

void main() {
  final rootDir = Directory.current;

  // Search for all Dart files in the root directory and its subdirectories
  final dartFiles = rootDir.listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart'));

  // Create a Map to store the class hierarchy
  final classHierarchy = <Type, List<Type>>{};

  // Reflect on the classes and their relationships
  for (final dartFile in dartFiles) {
    final libraryMirror = reflectClass(loadLibrary(dartFile.path));
    final classes = libraryMirror.declarations.values.whereType<ClassMirror>();

    for (final classMirror in classes) {
      final superclasses = classMirror.superclass == null ? [] : [classMirror.superclass.reflectedType];
      final interfaces = classMirror.interfaces.map((interface) => interface.reflectedType);
      final mixins = classMirror.mixin == null ? [] : [classMirror.mixin.reflectedType];
      final allSuperclasses = [...superclasses, ...interfaces, ...mixins];

      classHierarchy[classMirror.reflectedType] = allSuperclasses;
    }
  }

  // Print the dependencies graph
  for (final entry in classHierarchy.entries) {
    final className = MirrorSystem.getName(reflectClass(entry.key).simpleName);
    final dependencies = entry.value.map((type) => MirrorSystem.getName(reflectClass(type).simpleName));

    print('$className -> ${dependencies.join(', ')}');
  }
}
