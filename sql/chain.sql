WITH RECURSIVE
chain(from_state1, from_state2, sequence, step) AS (
-- start from initial state pair (1, 2) -> ('the', 'quick'), sequence as text and step 1
SELECT
	? AS from_state1,
	? AS from_state2,
	--lol you can use printf in sqlite?
	((
	SELECT
		name
	from
		states
	WHERE
		id = ?) || ' ' || (
	SELECT
		name
	from
		states
	WHERE
		id = ?)) AS sequence,
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
	-- append the chosen next state to the sequence string using the probability view
    sequence || ' ' || (
	SELECT
		name
	FROM
		states
	WHERE
		id = (
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
                       )),
	step + 1
FROM
	chain
WHERE
	-- CONFIGME
	-- should match step size below, max length of chain
	step < ?
)
SELECT
	sequence
FROM
	chain
WHERE
	-- CONFIGME
	step = ?;