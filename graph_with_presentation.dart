import 'dart:io';
import 'dart:mirrors';
import 'package:graphview/GraphView.dart';

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

  // Create a GraphView graph
  final graph = Graph();

  // Add nodes for each class
  for (final entry in classHierarchy.entries) {
    final className = MirrorSystem.getName(reflectClass(entry.key).simpleName);
    final node = Node.Id(className);
    graph.addNode(node);
  }

  // Add edges for each dependency
  for (final entry in classHierarchy.entries) {
    final className = MirrorSystem.getName(reflectClass(entry.key).simpleName);
    final dependencies = entry.value.map((type) => MirrorSystem.getName(reflectClass(type).simpleName));

    for (final dependency in dependencies) {
      final edge = Edge(Node.Id(className), Node.Id(dependency));
      graph.addEdge(edge);
    }
  }

  // Create a GraphView widget to display the graph
  final graphView = GraphView(
    graph,
    algorithm: BuchheimWalkerAlgorithm(),
    paint: (Canvas canvas, Paint paint, Rect rect) {},
    builder: (Node node) {
      // Customize the appearance of each node
      return RectangleShape(
        borderRadius: BorderRadius.circular(5),
        color: Colors.lightBlue,
        width: 100,
        height: 50,
        label: Text(node.id),
      );
    },
  );

  // Display the graph in a Flutter app
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Dependencies Graph'),
      ),
      body: Center(
        child: graphView,
      ),
    ),
  ));
}
