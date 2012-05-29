import csv
import os
import subprocess
import glob
import sys
import time

t0 = time.time()
t1 = None

infiledir = '/osm/planet/us/states-and-counties-2010-hardcut/us/' # directory that has the input files state_nn.osm.pbf
outdir = '/osm/out/gradesep/' # directory for the output shapefiles
sqldir = 'sql/' # directory containing the  
osmosis = '/osm/software/osmosis-latest/bin/osmosis' # path to osmosis command
schema = 'public' # schema name to use, requires 'SET search_path TO :schema;' in ~/.psqlrc
ogr2ogr = 'ogr2ogr' # path to ogr2ogr command
logfile = 'log.txt' # the log file will be written in the outdir
debug = False # if True, then only one run will be done, with State 01 = Alabama

dbname = 'vermont'
dbuser = 'osm'
dbpassword = 'osm'

class msg:
    def __init__(self, file=None):
        if file:
            try:
                sys.stdout = open(file,'w')
                sys.__stdout__.write('opened output file at %s\n' % (file))
                sys.__stdout__.flush()
            except IOError:
                print 'log file could not be created.'
        else:
            self.out = sys.stdout
            
    def write(self,what):
        if len(what) == 0:
            return
        t1 = time.time() - t0
        for line in what.split('\n'):
            if len(line)==0:
                continue
            print('%f\t%s' % (t1,line))
        sys.stdout.flush()
        
m = msg(os.path.join(outdir,logfile))
m.write('starting')
states = csv.reader(open('states.csv','rb'))
t=0 #debug
for state in states:
    if debug and t==1:
        sys.exit(0)
    datafilename = 'state_' + state[0] + '.osm.pbf'
    datafilepath = os.path.join(infiledir,datafilename)
    shapename = 'unconnectedlinknodes_%s' % (state[0])
    csvname = 'offending_nodes_%s.csv' % (state[0])
    m.write('processing %s...' % (state[2]))
    if not os.path.exists(datafilepath):
        m.write('no data')
        continue
    cmd = '%s --tp database=%s user=%s password=%s' % (osmosis, dbname, dbuser, dbpassword)
    m.write('truncating PostGIS tables...')
    p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE) 
    m.write(p.communicate()[0])
    cmd = '%s --rb %s --wp database=%s user=%s password=%s' % (osmosis, datafilepath, dbname, dbuser, dbpassword)
    m.write('importing %s into PostGIS...' % datafilepath)
    p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
    m.write(p.communicate()[0])
    queries = glob.glob(sqldir + '09*.sql')
    queries.sort()
    for queryfile in queries:
        m.write('evaluating %s for procesing...' % queryfile)
        m.write("running %s..." % (queryfile))
        cmd = 'psql -d %s -U %s -v schema=%s -f %s' % (dbname, dbuser, schema, queryfile)
        p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
        m.write(p.communicate()[0])
    m.write('outputting shapefile %s' % (shapename))
    cmd = '%s -f "ESRI Shapefile" -overwrite -nln %s %s PG:"dbname=%s user=%s password=%s" unconnectedlinknodes' % (ogr2ogr, shapename, outdir, dbname, dbuser, dbpassword)
    p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
    m.write(p.communicate()[0])
    if t==0:
        m.write('initializing aggregate shapefile...')
        cmd = '%s -overwrite %s %s.shp' % (ogr2ogr, os.path.join(outdir,'unconnectedlinknodes.shp'), os.path.join(outdir,shapename))
        p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
        m.write(p.communicate()[0])
    else:
        m.write('merging shapefiles...')
        cmd = '%s -f "ESRI Shapefile" -update -append %s %s.shp -nln unconnectedlinknodes' % (ogr2ogr, os.path.join(outdir, 'unconnectedlinknodes.shp'), os.path.join(outdir,shapename))
        p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
        m.write(p.communicate()[0])
    m.write('done with %s!' % (state[2]))
    t+=1 #debug
sys.__stdout__.write('done in %f.0 seconds %s\n' % (t1-t0, file))
