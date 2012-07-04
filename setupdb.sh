#!/bin/sh

if [ $# -ne 3 ]; then
    echo "Usage: setupdb.sh DBNAME DBUSER DBPASSWORD"
    exit
fi

DBNAME=$1
DBUSER=$2
DBPASSWORD=$3

OSMOSISPATH='/osm/software/osmosis-latest/'
OSMOSIS=${OSMOSISPATH}'bin/osmosis'

echo $OSMOSIS

createdb -U $DBUSER -O $DBUSER -E UTF8 $DBNAME
psql -U $DBUSER -d $DBNAME -c 'CREATE EXTENSION hstore'
psql -U $DBUSER -d $DBNAME -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql
psql -U $DBUSER -d $DBNAME -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
psql -U $DBUSER -d $DBNAME -f ${OSMOSISPATH}/script/pgsnapshot_schema_0.6.sql
psql -U $DBUSER -d $DBNAME -f ${OSMOSISPATH}/script/pgsnapshot_schema_0.6_linestring.sql
psql -U $DBUSER -d $DBNAME -f nbi/nbi_all_viaducts.sql
echo "Done."
