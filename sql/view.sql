
--Useful for debugging without full index
/**
CREATE VIEW transition_probabilities AS
SELECT
	from_state1,
	from_state2,
	to_state,
	count * 1.0 /
    SUM(count) OVER (PARTITION BY from_state1,
	from_state2) AS probability
FROM
	transitions;


DROP VIEW transition_probabilities;
**/

DROP TABLE IF EXISTS transition_probabilities;
CREATE TABLE transition_probabilities AS
SELECT
	from_state1,
	from_state2,
	to_state,
	count * 1.0 /
    SUM(count) OVER (PARTITION BY from_state1,
	from_state2) AS probability
FROM
	transitions;

--Super fast
CREATE INDEX IF NOT EXISTS idx_transition_probabilities ON transition_probabilities (from_state1, from_state2, to_state);

