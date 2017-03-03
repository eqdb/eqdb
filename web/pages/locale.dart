// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

import '../htgen/htgen.dart';
import '../common.dart';
import 'templates.dart';

final createLocalePage = new AdminPage(
    template: (data) {
      return createResourceTemplate(data, 'locale', inputs: (data) {
        return [
          div('.form-group', [
            label('Locale ISO code', _for: 'code'),
            input('#code.form-control', type: 'text', name: 'code')
          ])
        ];
      }, success: (data) {
        return [
          a('.btn.btn-primary', 'Return to locale overview',
              href: '/locale/list', role: 'button'),
        ];
      });
    },
    postFormat: {'code': 'code'});