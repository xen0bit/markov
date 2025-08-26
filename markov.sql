/**
 * Markov chain of order 2 in pure sqlite
 * Variables to configure are marked "CONFIGME"
 */

-- Clean slate
DROP TABLE IF EXISTS states;
DROP TABLE IF EXISTS transitions;
DROP VIEW IF EXISTS transition_probabilities;

-- Create tables
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

-- Insert states
INSERT
	OR IGNORE
INTO
	states (name)
VALUES
-- CONFIGME
('the'),
('quick'),
('brown'),
('fox'),
('jumps'),
('over'),
('the'),
('lazy'),
('dog');

-- Insert transitions
INSERT
	INTO
	transitions (from_state1,
	from_state2,
	to_state,
	count)
	--CONFIGME
/**
 * ((SELECT id FROM states WHERE name = 'the' LIMIT 1), (SELECT id FROM states WHERE name = 'quick' LIMIT 1), (SELECT id FROM states WHERE name = 'brown' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'quick' LIMIT 1), (SELECT id FROM states WHERE name = 'brown' LIMIT 1), (SELECT id FROM states WHERE name = 'fox' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'brown' LIMIT 1), (SELECT id FROM states WHERE name = 'fox' LIMIT 1), (SELECT id FROM states WHERE name = 'jumps' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'fox' LIMIT 1), (SELECT id FROM states WHERE name = 'jumps' LIMIT 1), (SELECT id FROM states WHERE name = 'over' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'jumps' LIMIT 1), (SELECT id FROM states WHERE name = 'over' LIMIT 1), (SELECT id FROM states WHERE name = 'the' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'over' LIMIT 1), (SELECT id FROM states WHERE name = 'the' LIMIT 1), (SELECT id FROM states WHERE name = 'lazy' LIMIT 1), 1), 
((SELECT id FROM states WHERE name = 'the' LIMIT 1), (SELECT id FROM states WHERE name = 'lazy' LIMIT 1), (SELECT id FROM states WHERE name = 'dog' LIMIT 1), 1),
 */
VALUES ((
SELECT
	id
FROM
	states
WHERE
	name = 'the'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'quick'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'brown'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'quick'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'brown'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'fox'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'brown'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'fox'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'jumps'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'fox'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'jumps'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'over'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'jumps'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'over'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'the'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'over'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'the'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'lazy'
LIMIT 1),
1), 
((
SELECT
	id
FROM
	states
WHERE
	name = 'the'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'lazy'
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = 'dog'
LIMIT 1),
1)
ON
CONFLICT(from_state1, from_state2, to_state)
DO
UPDATE
SET
	count = count + 1;

-- Create a probabilities view
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



WITH RECURSIVE
chain(from_state1, from_state2, sequence, step) AS (
-- start from initial state pair (1, 2) -> ('the', 'quick'), sequence as text and step 1
SELECT
	1 AS from_state1,
	2 AS from_state2,
	--lol you can use printf in sqlite?
	CAST(printf('%d,%d', 1, 2) AS TEXT) AS sequence,
	1 AS step
UNION ALL
-- recursive step here, pick next state based on transition_probabilities from last two states
SELECT
	from_state2,
	-- select a weighted random next state based on cumulative probability
    (
	SELECT
		to_state
	FROM
		(
		SELECT
			to_state,
			probability,
			SUM(probability) OVER (
		ORDER BY
			probability DESC,
			to_state) AS cumu
		FROM
			transition_probabilities
		WHERE
			from_state1 = chain.from_state1
			AND from_state2 = chain.from_state2
     )
	WHERE
		cumu >= (ABS(RANDOM()) / 9223372036854775807.0)
	ORDER BY
		cumu
	LIMIT 1
    ) AS from_state2,
	-- append the chosen next state to the sequence string
    sequence || ',' || (
	SELECT
		to_state
	FROM
		(
		SELECT
			to_state,
			probability,
			SUM(probability) OVER (
		ORDER BY
			probability DESC,
			to_state) AS cumu
		FROM
			transition_probabilities
		WHERE
			from_state1 = chain.from_state1
			AND from_state2 = chain.from_state2
                        )
	WHERE
		cumu >= (ABS(RANDOM()) / 9223372036854775807.0)
	ORDER BY
		cumu
	LIMIT 1
                       ),
	step + 1
FROM
	chain
WHERE
	-- CONFIGME
	-- should match step size below, max length of chain
	step < 8
)
SELECT
	sequence
FROM
	chain
WHERE
	-- CONFIGME
	step = 8;

