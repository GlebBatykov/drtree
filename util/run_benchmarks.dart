import 'dart:io';

const pointsGeneratorPath = '../benchmark/util/points_generator.dart';
const assetFolderPath = '../benchmark/assets';

const linearBenchmarkEntryPointPath = '../benchmark/linear_benchmark.dart';
const linearBenchmarkExecutablePath = '../benchmark/linear_benchmark.exe';

const drtreeBenchmarkEntryPointPath = '../benchmark/drtree_benchmark.dart';
const drtreeBenchmarkExecutablePath = '../benchmark/drtree_benchmark.exe';

class BenchmarkParameters {
  final int pointsCount;

  final List<String>? arguments;

  const BenchmarkParameters({
    required this.pointsCount,
    this.arguments,
  });
}

const linearBenchmarkParameters = <BenchmarkParameters>[
  BenchmarkParameters(pointsCount: 100),
  BenchmarkParameters(pointsCount: 500),
  BenchmarkParameters(pointsCount: 1000),
  BenchmarkParameters(pointsCount: 2500),
  BenchmarkParameters(pointsCount: 5000),
  BenchmarkParameters(pointsCount: 10000),
  BenchmarkParameters(pointsCount: 100000)
];

const drtreeBenchmarkParameters = <BenchmarkParameters>[
  BenchmarkParameters(
    pointsCount: 100,
    arguments: ['3', '6'],
  ),
  BenchmarkParameters(
    pointsCount: 500,
    arguments: ['4', '8'],
  ),
  BenchmarkParameters(
    pointsCount: 1000,
    arguments: ['8', '16'],
  ),
  BenchmarkParameters(
    pointsCount: 2500,
    arguments: ['12', '24'],
  ),
  BenchmarkParameters(
    pointsCount: 5000,
    arguments: ['15', '30'],
  ),
  BenchmarkParameters(
    pointsCount: 10000,
    arguments: ['18', '36'],
  ),
  BenchmarkParameters(
    pointsCount: 100000,
    arguments: ['20', '40'],
  )
];

enum CompileMode { jit, aot }

Future<void> generatePoints(bool regeneratePoints) async {
  final futures = <Future>[];

  final pointsCount = <int>{
    ...linearBenchmarkParameters.map((e) => e.pointsCount),
    ...drtreeBenchmarkParameters.map((e) => e.pointsCount),
  };

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
      await runJITBenchmark(
        linearBenchmarkEntryPointPath,
        linearBenchmarkParameters,
      );
      break;
    case CompileMode.aot:
      await runAOTBenchmark(
        entryPointPath: linearBenchmarkEntryPointPath,
        executablePath: linearBenchmarkExecutablePath,
        parameters: linearBenchmarkParameters,
      );
  }
}

Future<void> runDrtreeBenchmarks(CompileMode mode) async {
  switch (mode) {
    case CompileMode.jit:
      await runJITBenchmark(
        drtreeBenchmarkEntryPointPath,
        drtreeBenchmarkParameters,
      );
      break;
    case CompileMode.aot:
      await runAOTBenchmark(
        entryPointPath: drtreeBenchmarkEntryPointPath,
        executablePath: drtreeBenchmarkExecutablePath,
        parameters: drtreeBenchmarkParameters,
      );
  }
}

Future<void> runJITBenchmark(
  String entryPointPath,
  List<BenchmarkParameters> parameters,
) async {
  for (var i = 0; i < parameters.length; i++) {
    final count = parameters[i].pointsCount;

    print('$count points:');
    stdout.writeln();

    final jsonfilePath = '$assetFolderPath/${count}_points.json';

    final process = await Process.start(
      'dart',
      [
        'run',
        entryPointPath,
        jsonfilePath,
        ...parameters[i].arguments ?? [],
      ],
      runInShell: true,
    );

    process.stdout.listen((bytes) => stdout.add(bytes));
    process.stderr.listen((bytes) => stdout.add(bytes));

    await process.exitCode;

    if (i < parameters.length - 1) {
      stdout.writeln();
    }
  }
}

Future<void> runAOTBenchmark({
  required String entryPointPath,
  required String executablePath,
  required List<BenchmarkParameters> parameters,
}) async {
  await Process.run(
    'dart',
    [
      'compile',
      'exe',
      entryPointPath,
    ],
    runInShell: true,
  );

  for (var i = 0; i < parameters.length; i++) {
    final count = parameters[i].pointsCount;

    final jsonfilePath = '$assetFolderPath/${count}_points.json';

    print('$count points:');
    stdout.writeln();

    final process = await Process.start(
      executablePath,
      [
        jsonfilePath,
        ...parameters[i].arguments ?? [],
      ],
    );

    process.stdout.listen((bytes) => stdout.add(bytes));
    process.stderr.listen((bytes) => stdout.add(bytes));

    await process.exitCode;

    if (i < parameters.length - 1) {
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
