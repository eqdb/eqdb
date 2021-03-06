// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';

import 'package:qedb/utils.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart' as route;

import 'router.dart';

Future<Null> main() async {
  final log = new Logger('server');
  final conf = new EnvConfig('QEDb_', 'dev_config.yaml');

  // Read some configuration values.
  final logFile = conf.string('WEB_LOG');
  final srvPort = conf.integer('WEB_PORT', 8080);

  // Setup file based logging.
  if (logFile.isNotEmpty) {
    Logger.root.onRecord.listen(new SyncFileLoggingHandler(logFile));
  }

  // Log to STDOUT.
  if (stdout.hasTerminal) {
    Logger.root.onRecord.listen(new LogPrintHandler());
  }

  // Create router.
  final router = route.router();
  await setupRouter(conf.string('API_BASE', 'http://localhost:8080/qedb/v0/'),
      conf.string('STATIC_BASE', 'build/web/'), router);

  // Create shelf handler.
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests(
          logger: (msg, isError) => isError ? log.severe(msg) : log.info(msg)))
      .addHandler(router.handler);

  // Start server.
  final server = await io.serve(handler, '0.0.0.0', srvPort);
  log.info('Listening at port ${server.port}.');

  // Gracefully handle SIGINT signals.
  ProcessSignal.SIGINT.watch().listen((signal) async {
    log.info('Received $signal, terminating...');
    await server.close();
    exit(0);
  });
}
