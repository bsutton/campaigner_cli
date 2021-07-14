#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/args.dart';

// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart' hide Settings;
import 'package:noojee_campaigner_cli/noojee_campaigner_cli.dart';

import 'package:dcli/src/util/parser.dart';

/// dcli script generated by:
/// dcli create inject.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

void main(List<String> args) {
  var parser = ArgParser();

  parser.addOption('template',
      abbr: 't', help: 'Campaign Template ID', mandatory: true);

  ArgResults parsed;

  try {
    parsed = parser.parse(args);
  } on FormatException catch (e) {
    printerr(red(e.message));
    showUsage(parser);
    exit(1);
  }

  var templateId = int.tryParse(parsed['template'] as String);
  if (templateId == null) {
    printerr(red('The template must be an integer'));
    showUsage(parser);
  }

  var settings = Settings.load();
  var apiKey = settings.apiKey;
  var url = settings.url;

  var uri = Uri.encodeFull(
      '$url/servicemanager/rest/CampaignAPI/getFieldDefn?apiKey=$apiKey&fTemplateId=$templateId');

  withTempFile((jsonFile) {
    fetch(url: uri, saveToPath: jsonFile);
    var lines = read(jsonFile).toList();
    var jsonList = Parser(lines).jsonDecode() as List<dynamic>;

    var temp =
        jsonList.map((dynamic field) => field as Map<String, dynamic>).toList();
    for (final field in temp) {
      print(field);
      // print('id: ${field['id']} name: "${field['name']}"')
      // print(
      //   [{"type":"unicode","key":"address_1","required":false,"label":"address_1","help_text":"address_1"},{"type":"unicode","key":"Age","required":false,"label":"Age","help_text":"Age"},{"type":"unicode","key":"Best_Contact_Time","required":false,"label":"Best_Contact_Time","help_text":"Best_Contact_Time"},{"type":"unicode","key":"email","required":false,"label":"email","help_text":"email"},{"type":"unicode","key":"gender","required":false,"label":"gender","help_text":"gender"},{"type":"unicode","key":"name_first","required":false,"label":"name_first","help_text":"name_first"},{"type":"unicode","key":"name_last","required":false,"label":"name_last","help_text":"name_last"},{"type":"unicode","key":"name_middle","required":false,"label":"name_middle","help_text":"name_middle"},{"type":"unicode","key":"name_title","required":false,"label":"name_title","help_text":"name_title"},{"type":"unicode","key":"Notes","required":false,"label":"Notes","help_text":"Notes"},{"type":"unicode","key":"person_id","required":false,"label":"person_id","help_text":"person_id"},{"type":"unicode","key":"phone","required":false,"label":"phone","help_text":"phone"},{"type":"unicode","key":"postcode","required":false,"label":"postcode","help_text":"postcode"},{"type":"unicode","key":"Relationship_Status","required":false,"label":"Relationship_Status","help_text":"Relationship_Status"},{"type":"unicode","key":"state","required":false,"label":"state","help_text":"state"},{"type":"unicode","key":"suburb","required":false,"label":"suburb","help_text":"suburb"},{"type":"unicode","key":"Superannuation_Balance","required":false,"label":"Superannuation_Balance","help_text":"Superannuation_Balance"},{"type":"unicode","key":"Superfund","required":false,"label":"Superfund","help_text":"Superfund"}]
    }
  }, create: false);
}

/// Show useage.
void showUsage(ArgParser parser) {
  print('Usage: field_definitions.dart -t <templateid>');
  print('Retrieves a list of fields for the passed campaign template.');
  print(parser.usage);
  exit(1);
}
