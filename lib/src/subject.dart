// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

part of eqpg;

Future<db.SubjectRow> _createSubject(Session s, SubjectResource body) =>
    subjectHelper.insert(s, {'descriptor_id': body.descriptor.id});
