// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

part of eqpg.dbutils;

// PLEASE DO NOT EDIT THIS FILE, THIS CODE IS AUTO-GENERATED.

final descriptorHelper = new TableHelper<db.DescriptorRow>(
    'descriptor',
    db.DescriptorRow.mapFormat,
    db.DescriptorRow.map,
    (result, record) => result.descriptorTable[record.id] = record);
final subjectHelper = new TableHelper<db.SubjectRow>(
    'subject',
    db.SubjectRow.mapFormat,
    db.SubjectRow.map,
    (result, record) => result.subjectTable[record.id] = record);
final localeHelper = new TableHelper<db.LocaleRow>(
    'locale',
    db.LocaleRow.mapFormat,
    db.LocaleRow.map,
    (result, record) => result.localeTable[record.id] = record);
final translationHelper = new TableHelper<db.TranslationRow>(
    'translation',
    db.TranslationRow.mapFormat,
    db.TranslationRow.map,
    (result, record) => result.translationTable[record.id] = record);
final categoryHelper = new TableHelper<db.CategoryRow>(
    'category',
    db.CategoryRow.mapFormat,
    db.CategoryRow.map,
    (result, record) => result.categoryTable[record.id] = record);
final functionHelper = new TableHelper<db.FunctionRow>(
    'function',
    db.FunctionRow.mapFormat,
    db.FunctionRow.map,
    (result, record) => result.functionTable[record.id] = record);
final functionSubjectTagHelper = new TableHelper<db.FunctionSubjectTagRow>(
    'function_subject_tag',
    db.FunctionSubjectTagRow.mapFormat,
    db.FunctionSubjectTagRow.map,
    (result, record) => result.functionSubjectTagTable[record.id] = record);
final operatorHelper = new TableHelper<db.OperatorRow>(
    'operator',
    db.OperatorRow.mapFormat,
    db.OperatorRow.map,
    (result, record) => result.operatorTable[record.id] = record);
final functionLaTeXTemplateHelper =
    new TableHelper<db.FunctionLaTeXTemplateRow>(
        'function_latex_template',
        db.FunctionLaTeXTemplateRow.mapFormat,
        db.FunctionLaTeXTemplateRow.map,
        (result, record) =>
            result.functionLaTeXTemplateTable[record.id] = record);
final expressionHelper = new TableHelper<db.ExpressionRow>(
    'expression',
    db.ExpressionRow.mapFormat,
    db.ExpressionRow.map,
    (result, record) => result.expressionTable[record.id] = record);
final expressionLineageHelper = new TableHelper<db.ExpressionLineageRow>(
    'expression_lineage',
    db.ExpressionLineageRow.mapFormat,
    db.ExpressionLineageRow.map,
    (result, record) => result.expressionLineageTable[record.id] = record);
final lineageExpressionHelper = new TableHelper<db.LineageExpressionRow>(
    'lineage_expression',
    db.LineageExpressionRow.mapFormat,
    db.LineageExpressionRow.map,
    (result, record) => result.lineageExpressionTable[record.id] = record);
final ruleHelper = new TableHelper<db.RuleRow>('rule', db.RuleRow.mapFormat,
    db.RuleRow.map, (result, record) => result.ruleTable[record.id] = record);
final definitionHelper = new TableHelper<db.DefinitionRow>(
    'definition',
    db.DefinitionRow.mapFormat,
    db.DefinitionRow.map,
    (result, record) => result.definitionTable[record.id] = record);
