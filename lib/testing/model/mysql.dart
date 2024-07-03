import 'dart:async';
import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = 'pedb.c5a2wuygo3vn.us-east-1.rds.amazonaws.com';
  static String user = 'admin';
  static String password = 'adminpedb';
  static String db = 'hallo';
  static int port = 3306;

  static final Mysql _instance = Mysql._internal();
  MySqlConnection? _connection;
  Timer? _keepAliveTimer;

  factory Mysql() {
    return _instance;
  }

  Mysql._internal();

  // Future<MySqlConnection> getConnection() async {
  //   var settings = ConnectionSettings(
  //     host: host,
  //     port: port,
  //     user: user,
  //     password: password,
  //     db: db,
  //   );
  //
  //   try {
  //     _connection = await MySqlConnection.connect(settings);
  //     print('Connected to MySQL database');
  //     return _connection!;
  //   } catch (e) {
  //     print('Error connecting to MySQL: $e');
  //     throw Exception('Failed to connect to MySQL');
  //   }
  // }

  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      _connection ??= await _initializeConnection();
      _startKeepAlive();
    } else if (!await _isConnected()) {
      _connection = await _initializeConnection();
      _startKeepAlive();
    }
    return _connection!;
  }

  Future<MySqlConnection> _initializeConnection() async {
    var settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
    print('Connecting...');
    MySqlConnection connection = await MySqlConnection.connect(settings);
    print('Connected to MySQl');
    return connection;
  }

  Future<bool> _isConnected() async {
    try {
      await _connection!.query('select 1');
      return true;
    } catch (e) {
      print('Mysql connection lost: $e');
      return false;
    }
  }

  void _startKeepAlive() {
    //cancel existing timer
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        await _connection!.query('select 1');
        print('Keep-alive query executed successfully');
      } catch (e) {
        print('Keep-alive query failed: $e');
        _connection = await _initializeConnection();
      }
    });
  }

  void closeConnection() async {
    await _connection?.close();
    _connection = null;
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    print('MySQL connection closed');
  }
}
