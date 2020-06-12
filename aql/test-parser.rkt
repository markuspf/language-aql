#lang aql/parse-only


FOR x IN OUTBOUND SHORTEST_PATH "v/1" TO "v/2" GRAPH "penis"
RETURN x
