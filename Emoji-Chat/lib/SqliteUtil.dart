import 'package:flutterapp/SoundData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Sqlite 관련 작업을 수행하는 class
class SqliteUtil {
  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'sound_database.db'),
      onCreate: (db, version) {
        // 데이터베이스에 CREATE TABLE 수행
        return db.execute(
          "CREATE TABLE SoundData(sId INTEGER PRIMARY KEY AUTOINCREMENT, averageDecibel INTEGER, maxDecibel INTEGER, date TEXT)",
        );
      },
      version: 1,
    );
  }

  /// 데이터베이스에 SoundData 값을 추가한다.
  /// conflictAlgorithm : 동일한 아이템이 두번 추가되는 경우를 처리 (여기서는 갱신 처리)
  static Future<void> onAdd(SoundData soundData) async {
    final Database database = await getDatabase();

    await database.insert(
      'SoundData',
      soundData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 데이터베이스에 있는 모든 SoundData 값을 가져온다. (최신순)
  static Future<List<SoundData>> getSoundData() async {
    final Database database = await getDatabase();

    final List<Map<String, dynamic>> maps = await database.query('SoundData');
    return List.generate(maps.length, (i) {
      return SoundData.fromMap(maps[i]);
    }).reversed.toList();
  }
}
