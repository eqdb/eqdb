// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

part of eqdb;

Future<db.DefinitionRow> createDefinition(
    Session s, DefinitionResource body) async {
  // Insert rule.
  final rule = await createRule(s, body.rule);

  // Insert definition.
  return await s.insert(db.definition, VALUES({'rule_id': rule.id}));
}

Future<List<db.DefinitionRow>> listDefinitions(Session s) async {
  final definitions = await s.select(db.definition);
  await listRules(s, definitions.map((row) => row.ruleId));
  return definitions;
}
