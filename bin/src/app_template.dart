String $appTemplate = r'''
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
