import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main() {
  final classMap = <String, Set<String>>{};
  
  // Traverse all directories in your project
  final directories = Directory('path/to/your/project').listSync(recursive: true);
  
  // Identify all Dart files and parse them
  final contextCollection = AnalysisContextCollection(
    includedPaths: directories.whereType<Directory>().map((dir) => dir.path).toList(),
  );
  
  for (final context in contextCollection.contexts) {
    final files = context.contextRoot.analyzedFiles().where((file) => file.endsWith('.dart'));
    
    for (final file in files) {
      // Parse the Dart file and extract information about classes and their dependencies
      final result = context.currentSession.getParsedUnit(file);
      final unit = result.unit;
      
      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final dependencies = <String>{};
          
          for (final member in declaration.members) {
            if (member is FieldDeclaration) {
              for (final variable in member.fields.variables) {
                final type = variable.type?.toString();
                
                if (type != null && !type.startsWith('dart')) {
                  dependencies.add(type);
                }
              }
            } else if (member is MethodDeclaration) {
              for (final parameter in member.parameters.parameters) {
                final type = parameter.type?.toString();
                
                if (type != null && !type.startsWith('dart')) {
                  dependencies.add(type);
                }
              }
            }
          }
          
          // Build a map of classes and their dependencies
          classMap[declaration.name.toString()] = dependencies;
        }
      }
    }
  }
  
  // Generate a graph representation of the map of classes and their dependencies
  // You can use a graph library like dagre-d3 or cytoscape.js to generate a visual representation of the graph
  // For example, using dagre-d3:
  print('digraph {');
  for (final entry in classMap.entries) {
    final className = entry.key;
    final dependencies = entry.value;
    
    for (final dependency in dependencies) {
      print('  "$className" -> "$dependency";');
    }
  }
  print('}');
}
