import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// UI can build widgets, bind state, and dispatch events. Work belongs in Blocs.
class UiArchitectureVisitor extends RecursiveAstVisitor<void> {
  UiArchitectureVisitor(this.report);
  final void Function(String) report;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme != 'build') {
      report('UI must not declare logic/helper methods');
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    report('UI must not declare logic/helper functions');
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.body.isAsynchronous) {
      report('UI must not perform asynchronous work');
    }
    super.visitFunctionExpression(node);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    report('UI must not await operations');
    super.visitAwaitExpression(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    report('UI must not make imperative decisions; render state instead');
    super.visitIfStatement(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    report('UI must not handle operation failures');
    super.visitTryStatement(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    report('UI must not mutate application state');
    super.visitAssignmentExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if ({
      'setState',
      'listen',
      'then',
      'catchError',
      'unawaited',
    }.contains(node.methodName.name)) {
      report('UI must not manage asynchronous effects or state');
    }
    super.visitMethodInvocation(node);
  }
}
