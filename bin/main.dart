#! /usr/bin/env my-dart

import 'dart:core';
//import 'package:std/std.dart' as std_std;
import 'package:args/args.dart' as args_args;
//import 'package:std/command_runner.dart' as std_command_runner;
//import 'package:std/misc.dart' as std_misc;
import 'package:cs_scan/cs_scan.dart';
import 'package:debug_output/debug_output.dart';
import 'package:std/std.dart';
import 'src/app_template.dart';

Future<void> main(List<String> $args) async {
  if (isInDebugMode) {
    $args = ['gen', '~/cs-cmd/Test.Main/Test.Main.cs'];
  }
  // try {
  var $parser = args_args.ArgParser();
  var $gen = $parser.addCommand('gen');
  $gen.addFlag('nuget', abbr: 'n');
  var $generate = $parser.addCommand('generate');
  $generate.addFlag('nuget', abbr: 'n');
  var $results = $parser.parse($args);
  var $commandResults = $results.command;
  if ($commandResults == null) {
    throw 'Valid command not specified';
  }
  switch ($commandResults.name) {
    case 'gen':
    case 'generate':
      {
        await gen($commandResults);
      }
  }
}

Future<void> gen(args_args.ArgResults $commandResults) async {
  if ($commandResults.rest.isEmpty) {
    throw 'File name count is ${$commandResults.rest.length}: ${$commandResults.rest}';
  }
  bool $nuget = $commandResults.flag('nuget');
  echo($nuget, title: r'$nuget');
  String projFileName = $commandResults.rest[0];
  //String projFileName = args[0];
  projFileName = pathExpand(projFileName);
  var csScan = CsScan(projFileName);
  echo(csScan.$sourceSet);
  echo(csScan.$pkgSet);
  echo(csScan.$refSet);
  echo(csScan.$embedSet);
  List<String> srcList = csScan.$sourceSet.toList();
  List<CsNuget> pkgList = csScan.$pkgSet.toList();
  List<String> asmList = csScan.$refSet.toList();
  List<String> resList = csScan.$embedSet.toList();
  String projDir = pathDirectoryName(projFileName);
  echo(projDir, title: 'projDir');
  String baseName = pathBaseName(projFileName);
  //setCwd(projDir);
  //Directory.CreateDirectory("build-" + baseName);
  String csproj = pathJoin([projDir, 'build-$baseName', '$baseName.csproj']);
  echo(csproj, title: 'csproj');
  String csprojDir = pathDirectoryName(csproj);
  echo(csprojDir, title: 'csprojDir');
  String rootNS = baseName;
  if (baseName.endsWith('.main')) {
    rootNS = pathBaseName(baseName);
  }

  echo(rootNS, title: 'rootNs');

  String mainClass = 'MAIN_CLASS_NOT_FOUND';
  for (int i = 0; i < srcList.length; i++) {
    String srcFileName = pathFileName(srcList[i]);
    String srcBaseName = srcFileName.substring(0, srcFileName.length - 3);
    if (i == 0) {
      mainClass = "__${srcBaseName.replaceAll('.', '_').toUpperCase()}__";
    }
  }
  echo(mainClass, title: 'mainClass');
  String pkgSpec = '';
  for (int i = 0; i < pkgList.length; i++) {
    String pkgName = pkgList[i].$name;
    String pkgVer = pkgList[i].$version;
    pkgSpec +=
        "\n${"""    <PackageReference Include="{{NAME}}" Version="{{VERSION}}" />""".replaceAll("{{NAME}}", pkgName).replaceAll("{{VERSION}}", pkgVer)}";
  }
  echo(pkgSpec, title: 'pkgSpec');
  String asmSpec = '';
  for (int i = 0; i < asmList.length; i++) {
    asmSpec +=
        "\n${"""    <Reference Include="{{BASENAME}}"><HintPath>\$(HOME)/cmd/{{NAME}}</HintPath></Reference>""".replaceAll("{{BASENAME}}", pathBaseName(asmList[i])).replaceAll("{{NAME}}", asmList[i])}";
  }
  echo(asmSpec, title: 'asmSpec');
  String srcSpec = '';
  for (int i = 0; i < srcList.length; i++) {
    String srcFileName = pathFileName(srcList[i]);
    String srcFilePath = pathRelative(srcList[i], from: csprojDir);
    srcSpec +=
        "\n${"""    <Compile Include="{{PATH}}" Link="{{NAME}}" />""".replaceAll("{{NAME}}", srcFileName).replaceAll("{{PATH}}", srcFilePath)}";
  }
  echo(srcSpec, title: 'srcSpec');
  String resSpec = '';
  for (int i = 0; i < resList.length; i++) {
    String resFileName = resList[i];
    resFileName = pathRelative(resFileName, from: csprojDir);
    resSpec +=
        "\n${"""    <EmbeddedResource Include="{{PATH}}" />""".replaceAll("{{PATH}}", resFileName)}";
  }
  echo(resSpec, title: 'resSpec');
  String content = $appTemplate
      .replaceAll('{{ROOTNS}}', rootNS)
      .replaceAll('{{MAINCLASS}}', mainClass)
      .replaceAll('{{PROGRAM}}', baseName)
      .replaceAll('{{PACKAGES}}', pkgSpec)
      .replaceAll('{{ASSEMBLIES}}', asmSpec)
      .replaceAll('{{SOURCES}}', srcSpec)
      .replaceAll('{{RESOURCES}}', resSpec);
  echo(content);
  writeFileString(csproj, content);
}
