import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'constants/module_generator.dart';

/// 创建module的命令
class GenerateModule {

  /// 文件名前缀
  static final String _prefix = '';

  final String configFilePath = '${Directory.current.path}/$config_file_name';

  final env = Platform.environment;

  /// 要创建的目录的绝对地址
  late String dirPath;

  /// 解析generate_module的相关命令
  void parse(ArgResults results) async {

    String name = results['name'];
    String dir = results['dir'];

    dir = '${Directory.current.path}/$dir';

    dirPath = '$dir/$_prefix$name';

    if (! await File(configFilePath).exists()) {
      stderr.writeln('当前目录下未找到${config_file_name}文件，请检查');
      exit(2);
    }

    if (await Directory(dirPath).exists()) {
      stderr.writeln('${dirPath}目录已存在，请检查');
      exit(2);
    }

    Directory directory = Directory(dir);

    /// 不是文件
    if (!await File(directory.path).exists()) {
      // 不是一个已存在的文件夹
      if (!await FileSystemEntity.isDirectory(dir)) {
        await directory.create();
      }
      // 创建目录
      _createSimpleModuleDir();
    } else {
      stderr.writeln('${directory.path} 不是一个目录文件, 请检查');
      /// 直接退出
      exit(2);
    }

  }

  _createSimpleModuleDir() async {
    Directory directory = Directory(dirPath);
    if (! await directory.exists()) {
      directory.create();
      Directory('${directory.path}/').create();
    }
    await _generateDirAndFileByConfig();
  }

  _generateDirAndFileByConfig() async {
    String path = '${Directory.current.path}/$config_file_name';
    File file = File(path);
    if (await file.exists()) {
      String yaml = await file.readAsString();
      Map doc = loadYaml(yaml);
      _parseToDirectoryStructure(doc, [dirPath]);
    }
  }

  _parseToDirectoryStructure(Object parent, List<String> paths) {

    if (parent is Map) {
      parent.forEach((key, value) async {
        String path = pathFromPaths(paths) + key;
        if (key.contains('.dart')) {
          File file = File(path);
          if (!await file.exists()) {
            await file.create();
          }
        } else {
          await Directory(path).create();
          if (value != null) {
            _parseToDirectoryStructure(value, List.from(paths)..add(key));
          }
        }
      });
    }

    if (parent is List) {
      parent.forEach((element) async {
        String path = pathFromPaths(paths);
        if (element is String && element.contains('.dart')) {
          File file = File('$path/$element');
          if (!await file.exists()) {
            await file.create();
          }
        } else {
          if (element.runtimeType != Null) {
            _parseToDirectoryStructure(element, paths);
          }
        }
      });
    }

  }

  pathFromPaths(List<String> paths) {
    String path = '';
    paths.forEach((element) {
      path += element;
      path += '/';
    });
    return path;
  }

}
