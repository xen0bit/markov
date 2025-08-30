CREATE TABLE IF NOT EXISTS "states" (
	"id"	INTEGER,
	"name"	TEXT UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE transitions (
  from_state1 INTEGER,
  from_state2 INTEGER,
  to_state INTEGER,
  count INTEGER DEFAULT 1,
  PRIMARY KEY (from_state1,
from_state2,
to_state),
  FOREIGN KEY (from_state1) REFERENCES states(id),
  FOREIGN KEY (from_state2) REFERENCES states(id),
  FOREIGN KEY (to_state) REFERENCES states(id)
);

/**
CREATE INDEX IF NOT EXISTS idx_state_id ON states (id);
CREATE INDEX IF NOT EXISTS idx_state_name ON states (name);
CREATE INDEX IF NOT EXISTS idx_transitions ON transitions (from_state1, from_state2, to_state);
**/
