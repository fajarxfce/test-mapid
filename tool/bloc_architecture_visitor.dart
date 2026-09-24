import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Enforces event-driven Bloc state in handwritten production code.
class BlocArchitectureVisitor extends RecursiveAstVisitor<void> {
  BlocArchitectureVisitor(this.report);
  final void Function(String) report;

  static const _forbidden = {
    'Cubit',
    'StatefulWidget',
    'StatefulBuilder',
    'ChangeNotifier',
    'ValueNotifier',
    'ValueListenableBuilder',
    'ListenableBuilder',
    'setState',
  };

  void _check(String name) {
    if (_forbidden.contains(name)) {
      report('$name is forbidden; use Bloc with explicit events');
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _check(node.name);
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _check(node.name.lexeme);
    if (node.name.lexeme == 'State' &&
        (node.parent is ExtendsClause ||
            node.parent is ClassTypeAlias ||
            node.parent is GenericTypeAlias)) {
      report('State inheritance is forbidden; use Bloc with explicit events');
    }
    super.visitNamedType(node);
  }
}
