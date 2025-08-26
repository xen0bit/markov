INSERT
	INTO
	transitions (from_state1,
	from_state2,
	to_state,
	count)
VALUES ((
SELECT
	id
FROM
	states
WHERE
	name = ?
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = ?
LIMIT 1),
(
SELECT
	id
FROM
	states
WHERE
	name = ?
LIMIT 1),
1)
ON
CONFLICT(from_state1, from_state2, to_state)
DO
UPDATE
SET
	count = count + 1;
