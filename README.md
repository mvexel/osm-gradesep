osm-gradesep
============

analysis of grade separations in OpenStreetMap using PostGIS

This is a set of SQL queries that singles out potential grade separation 
issues as well as illegal intersections between OpenStreetMap motorways and 
other ways. The scripts can be run by themselves on an OSM PostGIS database 
that was built using the osmosis snapshot schema and the linestring extension.

There's also a python script that will automate the process for a directory of
state_XX.osm.pbf files, where XX is the state FIPS code. 

The output of the SQL file is a table 'candidates' that contains the geometry
of the ways that are considered intersection trouble candidates. The table
contains all the fields from the original ways table as well as additional
fields :
* angle - the angle at which the way intersects the motorway (largest if more than one)
* intersects - number of intersections between this way and motorway features
* touches - number of touches between this way and motorway features
* gradesep -  whether the way was flagged as a grade separation issue
* closenbi - whether the intersections have an NBI point nearby
