// Packages
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _db;

  static Future<Database> db() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'final_exam.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE polling_station(
            station_id INTEGER PRIMARY KEY,
            station_name TEXT NOT NULL,
            zone TEXT NOT NULL,
            province TEXT NOT NULL
          )
        ''');

        await d.execute('''
          CREATE TABLE violation_type(
            type_id INTEGER PRIMARY KEY,
            type_name TEXT NOT NULL,
            severity TEXT NOT NULL
          )
        ''');

        await d.execute('''
          CREATE TABLE incident_report(
            report_id INTEGER PRIMARY KEY AUTOINCREMENT,
            station_id INTEGER NOT NULL,
            type_id INTEGER NOT NULL,
            reporter_name TEXT NOT NULL,
            description TEXT NOT NULL,
            evidence_photo TEXT,
            timestamp TEXT NOT NULL,
            ai_result TEXT,
            ai_confidence REAL,
            FOREIGN KEY(station_id) REFERENCES polling_station(station_id),
            FOREIGN KEY(type_id) REFERENCES violation_type(type_id)
          )
        ''');

        await d.insert('polling_station', {
          'station_id': 101,
          'station_name': 'โรงเรียนวัดพระมหาธาตุ',
          'zone': 'เขต 1',
          'province': 'นครศรีธรรมราช',
        });
        await d.insert('polling_station', {
          'station_id': 102,
          'station_name': 'เต็นท์หน้าตลาดท่าวัง',
          'zone': 'เขต 1',
          'province': 'นครศรีธรรมราช',
        });
        await d.insert('polling_station', {
          'station_id': 103,
          'station_name': 'ศาลากลางหมู่บ้านคีรีวง',
          'zone': 'เขต 2',
          'province': 'นครศรีธรรมราช',
        });
        await d.insert('polling_station', {
          'station_id': 104,
          'station_name': 'หอประชุมอำเภอทุ่งสง',
          'zone': 'เขต 3',
          'province': 'นครศรีธรรมราช',
        });

        await d.insert('violation_type', {
          'type_id': 1,
          'type_name': 'ซื้อสิทธิ์ขายเสียง (Buying Votes)',
          'severity': 'High',
        });
        await d.insert('violation_type', {
          'type_id': 2,
          'type_name': 'ขนคนไปลงคะแนน (Transportation)',
          'severity': 'High',
        });
        await d.insert('violation_type', {
          'type_id': 3,
          'type_name': 'หาเสียงเกินเวลา (Overtime Campaign)',
          'severity': 'Medium',
        });
        await d.insert('violation_type', {
          'type_id': 4,
          'type_name': 'ทำลายป้ายหาเสียง (Vandalism)',
          'severity': 'Low',
        });
        await d.insert('violation_type', {
          'type_id': 5,
          'type_name': 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)',
          'severity': 'High',
        });
      },
    );
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> stations() async {
    final d = await db();
    return d.query('polling_station', orderBy: 'station_id ASC');
  }

  static Future<List<Map<String, dynamic>>> types() async {
    final d = await db();
    return d.query('violation_type', orderBy: 'type_id ASC');
  }

  static Future<int> insertIncidentReport(Map<String, dynamic> data) async {
    final d = await db();
    return d.insert('incident_report', data);
  }

  static Future<List<Map<String, dynamic>>> pollingStation() async {
    final d = await db();
    final raw = await d.rawQuery('''
      SELECT
        *
      FROM incident_report
    ''');
    return raw.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);
  }

  static Future<List<Map<String, dynamic>>> incidentReportsJoined() async {
    final d = await db();
    final raw = await d.rawQuery('''
      SELECT
        r.report_id,
        r.station_id,
        r.type_id,
        r.timestamp,
        r.reporter_name,
        r.description,
        r.evidence_photo,
        r.ai_result,
        r.ai_confidence,
        s.station_name,
        s.zone,
        s.province,
        t.type_name,
        t.severity
      FROM incident_report r
      JOIN polling_station s ON r.station_id = s.station_id
      JOIN violation_type t ON r.type_id = t.type_id
      ORDER BY r.report_id DESC
    ''');
    return raw.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);
  }

  static Future<List<Map<String, dynamic>>> incidentReportsJoinedTopThree() async {
    final d = await db();
    final raw = await d.rawQuery('''
      SELECT
        s.station_id,
        s.station_name,
        COUNT(*) as incident_count
      FROM incident_report r
      JOIN polling_station s ON r.station_id = s.station_id
      JOIN violation_type t ON r.type_id = t.type_id
      GROUP BY s.station_id
      ORDER BY incident_count DESC
      LIMIT 3
    ''');
    return raw.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);
  }

  static Future<List<Map<String, dynamic>>> incidentReportsJoinedOnlyStationName() async {
    final d = await db();
    final raw = await d.rawQuery('''
      SELECT
        r.report_id,
        s.station_name
      FROM incident_report r
      JOIN polling_station s ON r.station_id = s.station_id
      JOIN violation_type t ON r.type_id = t.type_id
    ''');
    return raw.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);
  }

  static Future<int> updateIncidentReport(int reportId, Map<String, dynamic> data) async {
    final d = await db();
    return d.update(
      'incident_report',
      data,
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  static Future<int> deleteIncidentReport(int reportId) async {
    final d = await db();
    return d.delete(
      'incident_report',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  static Future<List<Map<String, dynamic>>> getOnlyCount() async {
    final d = await db();
    final raw = await d.rawQuery('''
      SELECT
        COUNT(*) as total_incident
      FROM incident_report 
    ''');
    return raw.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);
  }

  static Future<int?> getCount() async {
    final d = await db();
    var x = await d.rawQuery('SELECT COUNT (*) FROM incident_report');
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  static Future<bool> uidExists(String s) async {
    final d = await db();
    var result = await d.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM polling_station WHERE station_name="${s}")',
    );
    int? exists = Sqflite.firstIntValue(result);
    return exists == 1;
  }
}