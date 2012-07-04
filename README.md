osm-gradesep
============

analysis of grade separations in OpenStreetMap using PostGIS

This is a set of SQL queries that singles out potential grade separation issues as well as illegal intersections between OpenStreetMap motorways and other ways. The scripts can be run by themselves on an OSM PostGIS database that was built using the osmosis snapshot schema and the linestring extension.

There's also a python script that will automate the process for a directory of state_XX.osm.pbf files, where XX is the state FIPS code. 

## setup
Be sure to have python 2.6+ , PostgreSQL 9.1+, PostGIS 2.0+, osmium and osm-history-splitter installed. The scripts are tested with the versions mentioned and is likely but not guaranteed to work with higher versions. 
Osmium and osm-history-splitter are only necessary if you want to run the analysis on a set of state files. 
The instructions that follow are only for the automated run process. If you already have a PostGIS database with OSM data (osmosis schema + linestring extension required!), you can just run the SQL scripts in succession. You will need to pull the results from the `candidates` table yourself after that.
1. Modify the `split-planet.py` to point to your source planet, and change other configuration options as necessary. Refer to the osm-history-splitter documentation for more information.
1. Run `split-planet.py`. This will take a few hours on a reasonably fast machine.
1. Set up a PostGIS database with Osmosis schema and linestring extension. There is a `setupdb.sh` shell script. It's a pretty dumb script but it should help. This will also import the NBI viaducts data that is used in the analysis. If you don't use the script, be sure to have your OSM data loaded into a PostGIS database with osmosis schema + linestring extension, and load the NBI data into the same schema yourself. 
1. Modify `process-gradesep.py` to suit your env. Notably the `infiledir`, `outdir` and `osmosis` variables.
1. Run `process-gradesep.py`. It generates very little screen output. Rather, it generates a verbose log file in `outdir` that you can monitor.

The final output of the SQL scripts is a table 'candidates' that contains the geometry of the ways that are considered intersection trouble candidates. The table contains all the fields from the original ways table as well as additional fields :
* angle - the angle at which the way intersects the motorway (largest if more than one)
* intersects - number of intersections between this way and motorway features
* touches - number of touches between this way and motorway features
* gradesep -  whether the way was flagged as a grade separation issue
* closenbi - whether the intersections have an NBI point nearby
* sharednodecnt - the number of nodes shared between the intersecting way and the motorway. Note that these are not necessarily real shared nodes, the check being done is whether there is an OSM node on the location of the intersection. This node may be part of only one of the ways, or even none of them. An additional check in the way_nodes table or the nodes field of both ways is necessary to determine that.

If you run the `process-gradesep.py` script, you will get a separate shapefile for each state, and a list of suspicious nodes as a text file as well.
