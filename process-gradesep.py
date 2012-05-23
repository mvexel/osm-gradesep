import csv
import os
import subprocess
import glob
import sys
import time
import re
import shutil

t0 = time.time()

infiledir = '/osm/planet/us/states-and-counties-2010-hardcut/us/' # directory that has the inp
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
	shapename = 'candidate_%s' % (state[0])
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
	queries = glob.glob(sqldir + '*.sql')
	queries.sort()
	for queryfile in queries:
		m.write('evaluating %s for procesing...' % queryfile)
		if re.match('\d\d', os.path.basename(queryfile)) is None:
			m.write('%s is not the right filename format' % queryfile)
			continue # scripts need to start with two digits.
		elif re.match('00', os.path.basename(queryfile)) is not None and t > 0:
			m.write('%s already executed, files starting with 00 only get executed once.' % queryfile)
			continue # scripts that begin with '00' get executed only once.
		m.write("running %s..." % (queryfile))
		cmd = 'psql -d %s -U %s -v schema=%s -f %s' % (dbname, dbuser, schema, queryfile)
		p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
		m.write(p.communicate()[0])
	t+=1 #debug
	m.write('outputting shapefile %s' % (shapename))
	cmd = '%s -f "ESRI Shapefile" -overwrite -nln %s %s PG:"dbname=%s user=%s password=%s" candidates' % (ogr2ogr, shapename, outdir, dbname, dbuser, dbpassword)
	p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
	m.write(p.communicate()[0])
	m.write('outputting offending nodes to %s' % (csvname))
	cmd = 'psql -d %s -U %s -v schema=%s -c "COPY (SELECT explode_array(osmnodes) as osmnodeid, gradesep, closenbi FROM intersections INNER JOIN candidates ON intersections.otherway_osmid = candidates.id ORDER BY gradesep) TO \'%s\' WITH CSV HEADER"' % (dbname, dbuser, schema, os.path.join(outdir, csvname))
	p = subprocess.Popen(cmd, shell=True, stderr = subprocess.STDOUT, stdout=subprocess.PIPE)
	m.write(p.communicate()[0])
	m.write('done with %s!' % (state[2]))
m.write('concatenating csv files...')
csvout = open(os.path.join(outdir,'badnodes.csv','wb'))
for csvfile in glob.iglob(os.path.join(outdir, '*.csv')):
	shutil.copyfileobj(open(csvfile, 'rb'), csvout)
csvout.close()	
sys.__stdout__.write('done in %f.0 seconds %s\n' % (t1-t0, file))
