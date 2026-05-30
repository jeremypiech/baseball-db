# Novelty

This analysis determines when a baseball game becomes a novelty, i.e., reaches
a sequence that has never previously occurred.

Retrosheet events are simplified for these comparisons:
    - Hits do not take into account hit location.
    - Most outs take into account which position fielded the ball and which baserunner was out.
        - An exception to this is fielder's choice plays — it's simply split into out and no out.
    - Reached on error plays are classified by the erroring player, e.g., a 1B who misplays
      a grounder and a 1B who drops the ball are both "E3".
