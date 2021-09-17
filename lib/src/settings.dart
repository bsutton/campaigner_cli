import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:settings_yaml/settings_yaml.dart';

class Settings {
  late final String url;
  late final String apiKey;

  late final String smsApiKey;
  late final String smsSecret;

  late final String defaultMobile;
  Settings.load() {
    var file = '.settings.yaml';
    var yaml = SettingsYaml.load(pathToSettings: file);
    url = fetch(yaml, 'url');
    apiKey = fetch(yaml, 'apiKey');
    smsApiKey = fetch(yaml, 'smsApiKey');
    smsSecret = fetch(yaml, 'smsSecret');
    defaultMobile = fetch(yaml, 'defaultMobile');
  }

  String fetch(SettingsYaml yaml, String name) {
    var value = yaml[name] as String?;
    if (value == null) {
      printerr('Your ${truepath(yaml.filePath)} is missing a value for $name');
      exit(1);
    }
    return value;
  }
}
