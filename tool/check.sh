#!/bin/bash

# Copyright (c) 2017, Herman Bergwerf. All rights reserved.
# Use of this source code is governed by an AGPL-3.0-style license
# that can be found in the LICENSE file.

set -e

# Regenerate generated files.
./lib/src/generated/generate.sh

# Check formatting.
dartfmt --dry-run --set-exit-if-changed ./

# Run analyzer checks.
dartanalyzer \
--options .analysis_options \
--fatal-hints --fatal-warnings --fatal-lints ./

# Run tests.
./tool/run-test.sh ./test/run.sh coverage.json

# Run Perl algorithm tests.
perl -Ilib/pl lib/pl/test.pl

# Upload coverage.
if [ ! -z ${CODECOV_TOKEN+x} ];
then
  bash <(curl -s https://codecov.io/bash)
fi

# Remove LCOV files.
rm -f *.lcov
