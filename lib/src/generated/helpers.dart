// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

part of eqpg.dbutils;

// PLEASE DO NOT EDIT THIS FILE, THIS CODE IS AUTO-GENERATED.

final descriptorHelper = new TableHelper<db.DescriptorRow>(
    'descriptor',
    db.DescriptorRow.mapFormat,
    db.DescriptorRow.map,
    (result, record) => result.descriptor.add(record));
final subjectHelper = new TableHelper<db.SubjectRow>(
    'subject',
    db.SubjectRow.mapFormat,
    db.SubjectRow.map,
    (result, record) => result.subject.add(record));
final localeHelper = new TableHelper<db.LocaleRow>(
    'locale',
    db.LocaleRow.mapFormat,
    db.LocaleRow.map,
    (result, record) => result.locale.add(record));
final translationHelper = new TableHelper<db.TranslationRow>(
    'translation',
    db.TranslationRow.mapFormat,
    db.TranslationRow.map,
    (result, record) => result.translation.add(record));
final categoryHelper = new TableHelper<db.CategoryRow>(
    'category',
    db.CategoryRow.mapFormat,
    db.CategoryRow.map,
    (result, record) => result.category.add(record));
final functionHelper = new TableHelper<db.FunctionRow>(
    'function',
    db.FunctionRow.mapFormat,
    db.FunctionRow.map,
    (result, record) => result.function.add(record));
final functionSubjectTagHelper = new TableHelper<db.FunctionSubjectTagRow>(
    'function_subject_tag',
    db.FunctionSubjectTagRow.mapFormat,
    db.FunctionSubjectTagRow.map,
    (result, record) => result.functionSubjectTag.add(record));
final operatorHelper = new TableHelper<db.OperatorRow>(
    'operator',
    db.OperatorRow.mapFormat,
    db.OperatorRow.map,
    (result, record) => result.operator.add(record));
final expressionHelper = new TableHelper<db.ExpressionRow>(
    'expression',
    db.ExpressionRow.mapFormat,
    db.ExpressionRow.map,
    (result, record) => result.expression.add(record));
final functionReferenceHelper = new TableHelper<db.FunctionReferenceRow>(
    'function_reference',
    db.FunctionReferenceRow.mapFormat,
    db.FunctionReferenceRow.map,
    (result, record) => result.functionReference.add(record));
final integerReferenceHelper = new TableHelper<db.IntegerReferenceRow>(
    'integer_reference',
    db.IntegerReferenceRow.mapFormat,
    db.IntegerReferenceRow.map,
    (result, record) => result.integerReference.add(record));
final lineageHelper = new TableHelper<db.LineageRow>(
    'lineage',
    db.LineageRow.mapFormat,
    db.LineageRow.map,
    (result, record) => result.lineage.add(record));
final ruleHelper = new TableHelper<db.RuleRow>('rule', db.RuleRow.mapFormat,
    db.RuleRow.map, (result, record) => result.rule.add(record));
final definitionHelper = new TableHelper<db.DefinitionRow>(
    'definition',
    db.DefinitionRow.mapFormat,
    db.DefinitionRow.map,
    (result, record) => result.definition.add(record));
