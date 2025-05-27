#! /usr/bin/env dart

import 'package:cs_scan/cs_scan.dart';
import 'package:debug_output/debug_output.dart';

void main() {
  var csScan = CsScan('~/cs-cmd/Test.Main/Test.Main.cs');
  echo(csScan.$sourceSet);
  echo(csScan.$refSet);
  echo(csScan.$embedSet);
}
