-- Ingeritance is from the Object Oriented dattabase 
-- For example, you can inherit a complete table object here in the example below 
CREATE TABLE cities (
  name       text,
  population real,
  elevation  int     -- (in ft)
);

CREATE TABLE capitals (
  state      char(2) UNIQUE NOT NULL
) INHERITS (cities);

