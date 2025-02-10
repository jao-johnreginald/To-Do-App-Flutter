import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_flutter/services/crud/crud_exceptions.dart';

class TodoService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseTodo> getTodo({required int id}) async {
    final db = _getDatabaseOrThrow();
    final todos = await db.query(
      todoTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (todos.isEmpty) {
      throw CouldNotFindTodo();
    } else {
      return DatabaseTodo.fromRow(todos.first);
    }
  }

  Future<Iterable<DatabaseTodo>> getAllTodos() async {
    final db = _getDatabaseOrThrow();
    final todos = await db.query(todoTable);
    return todos.map((todoRow) => DatabaseTodo.fromRow(todoRow));
  }

  Future<DatabaseTodo> createTodo({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    // Make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    // Create the DatabaseTodo item
    final todoId = await db.insert(todoTable, {
      userIdColumn: owner.id,
      textColumn: "",
      isSyncedWithCloudColumn: 1,
    });
    return DatabaseTodo(
      id: todoId,
      userId: owner.id,
      text: "",
      isSyncedWithCloud: true,
    );
  }

  Future<DatabaseTodo> updateTodo({
    required DatabaseTodo todo,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    final todos = await db.query(
      todoTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [todo.id],
    );
    if (todos.isEmpty) {
      throw CouldNotFindTodo();
    }
    final updatesCount = await db.update(todoTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateTodo();
    } else {
      return await getTodo(id: todo.id);
    }
  }

  Future<void> deleteTodo({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      todoTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteTodo();
    }
  }

  Future<int> deleteAllTodos() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(todoTable);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createTodoTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

const dbName = "todos.db";
const todoTable = "todo";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";

const createUserTable = """
        CREATE TABLE IF NOT EXISTS "user" (
          "id" INTEGER NOT NULL,
          "email" TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
        );
      """;
const createTodoTable = """
        CREATE TABLE IF NOT EXISTS "note" (
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "text" TEXT,
          "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY("user_id") REFERENCES "user"("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        )
      """;

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = $id, email = $email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseTodo {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseTodo({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseTodo.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Todo, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

  @override
  bool operator ==(covariant DatabaseTodo other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
