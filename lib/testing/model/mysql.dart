import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = 'pedb.c5a2wuygo3vn.us-east-1.rds.amazonaws.com';
  static String user = 'admin';
  static String password = 'adminpedb';
  static String db = 'hallo';
  static int port = 3306;

  static final Mysql _instance = Mysql._internal();
  MySqlConnection? _connection;

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
    _connection ??= await _initializeConnection();
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
    print('Connected to MySQl');
    return await MySqlConnection.connect(settings);
  }

  void closeConnection() async {
    await _connection?.close();
    _connection = null;
    print('MySQL connection closed');
  }
}
