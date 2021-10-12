#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl/intl.dart';

import 'package:dcli/dcli.dart' hide Settings;

import 'package:noojee_campaigner_cli/noojee_campaigner_cli.dart';

/// Retrieves recordings for the selected date and hour.

void main(List<String> args) {
  var parser = ArgParser();

  parser.addOption('date',
      abbr: 'd',
      help:
          'Date of the recordings in the format yyyy-mm-dd. If not passed then today is assumed');
  parser.addOption('hour',
      abbr: 'h',
      help:
          'Zero based integer for the hour the recording occured in. The prior hour is assumed');

  ArgResults parsed;

  try {
    parsed = parser.parse(args);
  } on FormatException catch (e) {
    printerr(red(e.message));
    showUsage(parser);
    exit(1);
  }

  DateTime date;

  try {
    var format = DateFormat('yyyy-MM-dd');
    if (parsed.wasParsed('date')) {
      date = format.parse(parsed['date'] as String);
    } else {
      date = DateTime.now();
    }
  } on FormatException catch (_) {
    printerr(red('Invalid format for date. Found: ${parsed['date']}'));
    showUsage(parser);
    exit(1);
  }

  var hour = DateTime.now().hour;

  if (parsed.wasParsed('date')) {
    hour = int.tryParse(parsed['hour'] as String) ?? DateTime.now().hour - 1;
  }
  if (hour < 0) {
    hour = 23;
    date.subtract(Duration(days: 1));
  }

  var settings = Settings.load();
  var apiKey = settings.apiKey;
  var url = settings.url;

  var format = DateFormat('yyyy/MM/dd');
  var dateArg = format.format(date);

  var uri = Uri.encodeFull(
      '$url/njadmin/rest/RecordingAPI/retrieveMetaDataByHour?apiKey=$apiKey&date=$dateArg&hour=$hour');

  withTempFile((jsonFile) {
    try {
      fetch(url: uri, saveToPath: jsonFile, method: FetchMethod.post);
    } on FetchException catch (e) {
      print('Download failed: ${e.message}');
      print(read(jsonFile).toParagraph());
      exit(1);
    }
    var response = read(jsonFile).toParagraph();
    final legs = jsonDecode(response) as List<dynamic>;

    if (legs.isEmpty) {
      print(orange('No recordings found for date: $dateArg hour: $hour'));
    }
    for (var leg in legs) {
      print(
          'UniqueId: ${leg['UniqueId']} Start: "${leg['Start']}" Duration: "${leg['Duration']}" Source: "${leg['Source']}" Destination: "${leg['Destination']}"');
    }
  }, create: false);
}

/// Show useage.
void showUsage(ArgParser parser) {
  print('Usage: field_list.dart -t <templateid>');
  print('Retrieves a list of fields for the passed campaign template.');
  print(parser.usage);
  exit(1);
}
