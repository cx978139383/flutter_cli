import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:cli/src/generate_module.dart';

const module = 'module';

void main(List<String> arguments) {
  exitCode = 0;

  runZonedGuarded(() {
    final ArgParser generateModuleParser = ArgParser();

    //定义命令行参数
    final parser = ArgParser()
      ..addCommand(module, generateModuleParser);

    /// 创建module命令的相关配置
    ///
    /// [dir_name] 生成文件的路径
    /// [name] 模块名
    generateModuleParser
      ..addOption('dir', abbr: 'd')
      ..addOption('name', abbr: 'n', defaultsTo: 'xxx');

    final argResults = parser.parse(arguments);

    switch (argResults.command?.name) {
      case module:
        GenerateModule().parse(argResults.command!);
        break;
    }
  }, (Object error, StackTrace stack) {
    print(error);
    exit(0);
  });
}

