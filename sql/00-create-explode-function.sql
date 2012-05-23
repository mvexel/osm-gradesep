CREATE OR REPLACE FUNCTION explode_array(in_array anyarray) RETURNS SETOF anyelement AS
$$
    SELECT ($1)[s] FROM generate_series(1,array_upper($1, 1)) AS s;
$$
LANGUAGE sql IMMUTABLE;
