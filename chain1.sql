WITH probs AS (
  SELECT
    to_state,
    probability,
    SUM(probability) OVER (
      PARTITION BY from_state1
      ORDER BY probability DESC, to_state
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumu
  FROM transition_probabilities
  WHERE from_state1 = 14
)
SELECT to_state
FROM probs
WHERE cumu >= (
  SELECT RANDOM() / 9223372036854775807.0
)
ORDER BY cumu
LIMIT 1;