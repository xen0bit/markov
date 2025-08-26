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
