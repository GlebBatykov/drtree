import 'dart:io';

const pointsGeneratorPath = '../benchmark/util/points_generator.dart';
const assetFolderPath = '../benchmark/assets';

const linearBenchmarkEntryPointPath = '../benchmark/linear_benchmark.dart';
const linearBenchmarkExecutablePath = '../benchmark/linear_benchmark.exe';

const drtreeBenchmarkEntryPointPath = '../benchmark/drtree_benchmark.dart';
const drtreeBenchmarkExecutablePath = '../benchmark/drtree_benchmark.exe';

const pointsCount = <int>[100, 500, 1000, 2500, 5000, 10000, 100000];

enum CompileMode { jit, aot }

Future<void> generatePoints(bool regeneratePoints) async {
  final futures = <Future>[];

  for (final count in pointsCount) {
    final filePath = '$assetFolderPath/${count}_points.json';

    final file = File.fromUri(Uri.file(filePath));

    if (regeneratePoints || !await file.exists()) {
      final future = Process.run(
        'dart',
        [
          'run',
          pointsGeneratorPath,
          filePath,
          count.toString(),
          count.toString()
        ],
        runInShell: true,
      );

      futures.add(future);
    }
  }

  await Future.wait(futures);
}

Future<void> runLinearBenchmarks(CompileMode mode) async {
  switch (mode) {
    case CompileMode.jit:
      await runJITBenchmark(linearBenchmarkEntryPointPath);
      break;
    case CompileMode.aot:
      await runAOTBenchmark(
        linearBenchmarkEntryPointPath,
        linearBenchmarkExecutablePath,
      );
  }
}

Future<void> runDrtreeBenchmarks(CompileMode mode) async {
  switch (mode) {
    case CompileMode.jit:
      await runJITBenchmark(drtreeBenchmarkEntryPointPath);
      break;
    case CompileMode.aot:
      await runAOTBenchmark(
        drtreeBenchmarkEntryPointPath,
        drtreeBenchmarkExecutablePath,
      );
  }
}

Future<void> runJITBenchmark(String entryPointPath) async {
  for (var i = 0; i < pointsCount.length; i++) {
    final count = pointsCount[i];

    print('$count points:');
    stdout.writeln();

    final jsonfilePath = '$assetFolderPath/${count}_points.json';

    final process = await Process.start(
      'dart',
      [
        'run',
        entryPointPath,
        jsonfilePath,
      ],
      runInShell: true,
    );

    process.stdout.listen((bytes) => stdout.add(bytes));
    process.stderr.listen((bytes) => stdout.add(bytes));

    await process.exitCode;

    if (i < pointsCount.length - 1) {
      stdout.writeln();
    }
  }
}

Future<void> runAOTBenchmark(
  String entryPointPath,
  String executablePath,
) async {
  await Process.run(
    'dart',
    [
      'compile',
      'exe',
      entryPointPath,
    ],
    runInShell: true,
  );

  for (var i = 0; i < pointsCount.length; i++) {
    final count = pointsCount[i];

    final jsonfilePath = '$assetFolderPath/${count}_points.json';

    print('$count points:');
    stdout.writeln();

    final process = await Process.start(
      executablePath,
      [jsonfilePath],
    );

    process.stdout.listen((bytes) => stdout.add(bytes));
    process.stderr.listen((bytes) => stdout.add(bytes));

    await process.exitCode;

    if (i < pointsCount.length - 1) {
      stdout.writeln();
    }
  }
}

void main(List<String> arguments) async {
  var compileMode = CompileMode.jit;

  if (arguments.isNotEmpty) {
    compileMode = arguments[0] == 'aot' ? CompileMode.aot : CompileMode.jit;
  }

  var regeneratePoints = false;

  if (arguments.length > 1) {
    regeneratePoints = arguments[1] == 'generate' ? true : false;
  }

  await generatePoints(regeneratePoints);

  print('Linear benchmark');
  stdout.writeln();
  await runLinearBenchmarks(compileMode);

  stdout.writeln();

  print('Drtree benchmark');
  stdout.writeln();
  await runDrtreeBenchmarks(compileMode);
}
