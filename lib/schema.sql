-- Copyright (c) 2017, Herman Bergwerf. All rights reserved.
-- Use of this source code is governed by an AGPL-3.0-style license
-- that can be found in the LICENSE file.

--------------------------------------------------------------------------------
-- Naming conventions:
-- + Do not use reserved keywords (SQL standard)
-- + Foreign key field names have a '_id' suffix
-- + Do not use abbreviations unless very common or required
--------------------------------------------------------------------------------

CREATE EXTENSION pgcrypto;

--------------------------------------------------------------------------------
-- Descriptors and translations
--------------------------------------------------------------------------------

-- Descriptor
-- Should NOT contain separate records for abbreviations or acronyms.
CREATE TABLE descriptor (
  id  serial  PRIMARY KEY
);

-- Subject
-- A descriptor should be approved to be a subject. Subjects are used for
-- categories and for secundary function grouping.
CREATE TABLE subject (
  id             serial   PRIMARY KEY,
  descriptor_id  integer  NOT NULL UNIQUE REFERENCES descriptor(id)
);

-- Locale
CREATE TABLE locale (
  id    serial  PRIMARY KEY,
  code  text    NOT NULL UNIQUE
    CHECK (code ~ '^[a-z]{2}(_([a-zA-Z]{2}){1,2})?_[A-Z]{2}$') -- Match validate ISO locale code format.
);

-- Translation of a descriptor
CREATE TABLE translation (
  id             serial   PRIMARY KEY,
  descriptor_id  integer  NOT NULL REFERENCES descriptor(id),
  locale_id      integer  NOT NULL REFERENCES locale(id),
  content        text     NOT NULL
    CHECK (content ~ E'^(?:[^\\s]+ )*[^\\s]+$'), -- Check for repeated spaces in the regex.
  
  -- Translations should have a unique meaning. If there are translations that
  -- can mean different things, the translation should be further specified.
  -- (as in Wikipedia page titles)
  UNIQUE (locale_id, content)
);

--------------------------------------------------------------------------------
-- Categories and expression storage
--------------------------------------------------------------------------------

-- Category
-- The referenced subject can not already be used by any function subject tag.
-- Currently a category must be tied to a subject. This in order to prevent
-- unclarity about the category contents.
CREATE TABLE category (
  id          serial     PRIMARY KEY,
  subject_id  integer    NOT NULL UNIQUE REFERENCES subject(id),
  parents     integer[]  NOT NULL
);

-- Function
-- Soft constraint: non-generic function with >0 arguments must have a name.
CREATE TABLE function (
  id              serial    PRIMARY KEY,
  category_id     integer   NOT NULL REFERENCES category(id),
  descriptor_id   integer   UNIQUE REFERENCES descriptor(id),
  generic         boolean   NOT NULL CHECK (NOT generic OR argument_count < 2),
  argument_count  smallint  NOT NULL CHECK (argument_count >= 0),
  latex_template  text      NOT NULL CHECK (NOT latex_template = '')
);
CREATE INDEX function_category_id_index ON function(category_id);

-- Function subject tag
-- The referenced subject can not already be used by a category.
CREATE TABLE function_subject_tag (
  id           serial   PRIMARY KEY,
  function_id  integer  NOT NULL REFERENCES function(id),
  subject_id   integer  NOT NULL REFERENCES subject(id)
);

CREATE TYPE keyword_type AS ENUM (
  -- [a-z]+ form of an English translation of the function name descriptor
  -- No upper caps allowed! If the original name contains spaces, dashes or
  -- other complex symbols, you should consider to NOT create a 'word' keyword.
  'word',
  
  -- Short form of the function name descriptor
  'acronym',
  'abbreviation',
  
  -- Related to the function LaTeX template
  -- ([a-z]+ form of the function symbol)
  'symbol'
);

-- Keywords ([a-z]+ sequences that identify the function)
-- TODO: more general keywords (vector, circle, algebra)
CREATE TABLE keyword (
  id     serial        PRIMARY KEY,
  value  text          NOT NULL CHECK (value ~ '^[a-z]+$'),
  type   keyword_type  NOT NULL,

  -- Equal values with different types are allowed.
  UNIQUE (value, type)
);

-- Function keyword join
CREATE TABLE function_keyword (
  id           serial   PRIMARY KEY,
  function_id  integer  NOT NULL REFERENCES function(id),
  keyword_id   integer  NOT NULL REFERENCES keyword(id),

  -- Do not repeat keywords.
  UNIQUE (function_id, keyword_id)
);

-- Operator evaluation (relevant for printing parentheses)
CREATE TYPE operator_associativity AS ENUM ('ltr', 'rtl');

-- Operator properties
CREATE TABLE operator (
  id                serial                  PRIMARY KEY,
  function_id       integer                 NOT NULL UNIQUE REFERENCES function(id),
  precedence_level  smallint                NOT NULL CHECK (precedence_level > 0),
  associativity     operator_associativity  NOT NULL
);

-- Expression node
-- Note: expression references have not been implemented yet to reduce
-- complexity. The main objective is to make expressions indexable. This could
-- potentially also be achieved by writing a custom index in C.
CREATE TABLE expression (
  id            serial   PRIMARY KEY,
  data          bytea    NOT NULL UNIQUE,
  hash          bytea    NOT NULL UNIQUE,

  -- All function IDs in this expression for fast indexing and searching.
  -- TODO: remove this?
  functions  integer[]             NOT NULL
);
CREATE INDEX expression_functions_index on expression USING GIN (functions);

--------------------------------------------------------------------------------
-- Rules and definitions
--------------------------------------------------------------------------------

-- Rule (equation of two expression)
CREATE TABLE rule (
  id                   serial   PRIMARY KEY,
  category_id          integer  NOT NULL REFERENCES category(id),
  left_expression_id   integer  NOT NULL REFERENCES expression(id),
  right_expression_id  integer  NOT NULL REFERENCES expression(id),

  UNIQUE (left_expression_id, right_expression_id)
);

-- A rule definition.
CREATE TABLE definition (
  id       serial   PRIMARY KEY,
  rule_id  integer  NOT NULL UNIQUE REFERENCES rule(id)

  -- TODO:
  -- + Definition title
  -- + Theoretical definition (mathematical property of functions)
  -- + Empirical definition (physics)
);

--------------------------------------------------------------------------------
-- Expression lineages
--------------------------------------------------------------------------------

-- Expression lineage
CREATE TABLE expression_lineage (
  id  serial  PRIMARY KEY
);

-- Lineage expression
CREATE TABLE lineage_expression (
  id                     serial    PRIMARY KEY,
  lineage_id             integer   NOT NULL REFERENCES expression_lineage(id),
  category_id            integer   NOT NULL REFERENCES category(id),
  rule_id                integer   NOT NULL REFERENCES rule(id),
  expression_id          integer   NOT NULL REFERENCES expression(id),
  sequence               integer   NOT NULL CHECK (sequence > 0),
  substitution_position  smallint  NOT NULL CHECK (substitution_position >= 0),

  UNIQUE (lineage_id, sequence)
);

--------------------------------------------------------------------------------
-- Equation lineage
--------------------------------------------------------------------------------

-- Equation lineage
CREATE TYPE equation_initialization AS ENUM ('rule', 'arbitrary');
CREATE TABLE equation_lineage (
  id       serial                   PRIMARY KEY,
  type     equation_initialization  NOT NULL,
  rule_id  integer                  REFERENCES rule(id)
);

CREATE TABLE equation_envelope (
  id           serial   PRIMARY KEY,
  template_id  integer  NOT NULL REFERENCES expression(id),
  envelope_id  integer  NOT NULL REFERENCES expression(id)
);

-- Equation lineage expression lineage pairs
CREATE TABLE lineage_equation (
  id           serial   PRIMARY KEY,
  lineage_id   integer  NOT NULL REFERENCES equation_lineage(id),
  left_id      integer  NOT NULL REFERENCES expression_lineage(id),
  right_id     integer  NOT NULL REFERENCES expression_lineage(id),
  envelope_id  integer  REFERENCES equation_envelope(id),
  sequence     integer  NOT NULL CHECK (sequence > 0),

  UNIQUE (lineage_id, sequence)
);

--------------------------------------------------------------------------------
-- Equation page
--------------------------------------------------------------------------------

CREATE TABLE page (
  id             serial   PRIMARY KEY,
  descriptor_id  integer  NOT NULL UNIQUE REFERENCES descriptor(id)
);

CREATE TABLE page_definition (
  id             serial   PRIMARY KEY,
  page_id        integer  NOT NULL REFERENCES page(id),
  definition_id  integer  NOT NULL REFERENCES definition(id),
  sequence       integer  NOT NULL CHECK (sequence > 0)
);

CREATE TABLE page_equation_lineage (
  id          serial   PRIMARY KEY,
  page_id     integer  NOT NULL REFERENCES page(id),
  lineage_id  integer  NOT NULL REFERENCES equation_lineage(id),
  sequence    integer  NOT NULL CHECK (sequence > 0)
);

CREATE TABLE page_illustration (
  id        serial   PRIMARY KEY,
  page_id   integer  NOT NULL REFERENCES page(id),
  sequence  integer  NOT NULL CHECK (sequence > 0),
  data      jsonb
);

--------------------------------------------------------------------------------
-- Create user and restrict access.
--------------------------------------------------------------------------------

REVOKE CONNECT ON DATABASE eqdb FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;

CREATE USER eqpg WITH ENCRYPTED PASSWORD '$password' CONNECTION LIMIT 100;
GRANT CONNECT ON DATABASE eqdb TO eqpg;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO eqpg;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to eqpg;
