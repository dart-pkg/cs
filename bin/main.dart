#! /usr/bin/env dart

import 'package:cs_scan/cs_scan.dart';
import 'package:debug_output/debug_output.dart';
import 'package:std/std.dart';

void main(List<String> args) {
  if (isInDebugMode) {
    args = ['~/cs-cmd/Test.Main/Test.Main.cs'];
  }
  String projFileName = args[0];
  projFileName = pathExpand(projFileName);
  var csScan = CsScan(projFileName);
  echo(csScan.$sourceSet);
  echo(csScan.$pkgSet);
  echo(csScan.$refSet);
  echo(csScan.$embedSet);
  List<String> srcList = csScan.$sourceSet.toList();
  List<String> pkgList = csScan.$pkgSet.toList();
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
  if (baseName.endsWith(".main"))
  {
    rootNS = pathBaseName(baseName);
  }

  echo(rootNS, title: 'rootNs');

  String mainClass = "MAIN_CLASS_NOT_FOUND";
  for (int i = 0; i< srcList.length; i++)
  {
    String srcFileName = pathFileName(srcList[i]);
    String srcBaseName = srcFileName.substring(0, srcFileName.length - 3);
    if (i == 0)
    {
      mainClass = "__${srcBaseName.replaceAll('.', '_').toUpperCase()}__";
    }
  }
  echo(mainClass, title: 'mainClass');
  String pkgSpec = '';
  for (int i = 0; i < pkgList.length; i++)
  {
    String pkgName = pkgList[i];
    String pkgVer = '*';
    pkgSpec += "\n${"""    <PackageReference Include="{{NAME}}" Version="{{VERSION}}" />""".replaceAll("{{NAME}}", pkgName).replaceAll("{{VERSION}}", pkgVer)}";
  }
  echo(pkgSpec, title: 'pkgSpec');
  String asmSpec = '';
  for (int i = 0; i < asmList.length; i++)
  {
    asmSpec += "\n${"""    <Reference Include="{{BASENAME}}"><HintPath>\$(HOME)/cmd/{{NAME}}</HintPath></Reference>"""
        .replaceAll("{{BASENAME}}", pathBaseName(asmList[i]))
        .replaceAll("{{NAME}}", asmList[i])}";
  }
  echo(asmSpec, title: 'asmSpec');
  String srcSpec = '';
  for (int i = 0; i < srcList.length; i++)
  {
    String srcFileName = srcList[i];
    srcFileName = pathRelative(srcFileName, from: csprojDir);
    String srcBaseName = srcFileName.substring(0, srcFileName.length - 3);
    srcSpec += "\n${"""    <Compile Include="{{PATH}}" Link="{{NAME}}" />""".replaceAll("{{NAME}}", srcFileName).replaceAll("{{PATH}}", srcList[i])}";
  }
  echo(srcSpec, title: 'srcSpec');
  String resSpec = '';
  for (int i=0; i<resList.length; i++)
  {
    String resFileName = resList[i];
    resFileName = pathRelative(resFileName, from: csprojDir);
    resSpec += "\n${"""    <EmbeddedResource Include="{{PATH}}" />""".replaceAll("{{PATH}}", resFileName)}";
  }
  echo(resSpec, title: 'resSpec');
  String content = template
      .replaceAll('{{ROOTNS}}', rootNS)
      .replaceAll('{{MAINCLASS}}', mainClass)
      .replaceAll('{{PROGRAM}}', baseName)
      .replaceAll('{{PACKAGES}}', pkgSpec)
      .replaceAll('{{ASSEMBLIES}}', asmSpec)
      .replaceAll('{{SOURCES}}', srcSpec)
      .replaceAll('{{RESOURCES}}', resSpec)
  ;
  echo(content);
}

String template = r'''
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <LangVersion>latest</LangVersion>
    <TargetFramework>net481</TargetFramework>
    <AssemblyName>{{PROGRAM}}</AssemblyName>
    <RootNamespace>{{ROOTNS}}</RootNamespace>
    <UseWindowsForms>true</UseWindowsForms>
    <Nullable>disable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <Prefer32Bit>false</Prefer32Bit>
    <Version>0.0.0.0</Version>
  </PropertyGroup>
  <PropertyGroup>
    <DebugType>full</DebugType>
    <TieredCompilationQuickJit>false</TieredCompilationQuickJit>
  </PropertyGroup>
  <PropertyGroup>
    <!--<ApplicationIcon>./app.ico</ApplicationIcon>-->
  </PropertyGroup>
  <PropertyGroup>
    <DefineConstants>$(DefineConstants);{{MAINCLASS}}</DefineConstants>
  </PropertyGroup>
  <ItemGroup Condition="'$(TargetFramework.TrimEnd(`0123456789`))' == 'net'">
    <Reference Include="Microsoft.CSharp" />
    <Reference Include="System" />
    <Reference Include="System.Core" />
    <Reference Include="System.Data" />
    <Reference Include="System.Data.DataSetExtensions" />
    <Reference Include="System.IO.Compression" />
    <Reference Include="System.Net.Http" />
    <Reference Include="System.Runtime.Remoting" />
    <Reference Include="System.Web" />
    <Reference Include="System.Xml" />
    <Reference Include="System.Xml.Linq" />
  </ItemGroup>
  <ItemGroup>{{PACKAGES}}
  </ItemGroup>
  <ItemGroup>{{SOURCES}}
  </ItemGroup>
  <ItemGroup>{{ASSEMBLIES}}
  </ItemGroup>
  <ItemGroup>{{RESOURCES}}
  </ItemGroup>
</Project>
''';
