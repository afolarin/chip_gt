#!/usr/bin/env python
import sys
import os

# Import the Python DAX library

#os.sys.path.insert(0, "/usr/lib64/pegasus/python")
os.sys.path.insert(0, "/home/pipeline/pegasus_4.1/lib/pegasus/python")
from Pegasus.DAX3 import *


# The name of the DAX file is the first argument
if len(sys.argv) != 2:
	sys.stderr.write("Usage: %s DAXFILE\n" % (sys.argv[0]))
	sys.exit(1)
daxfile = sys.argv[1]


# Create a abstract dag
print "Creating ADAG..."
simplewf = ADAG("simplewf")


# Add a count job
print "Adding count job..."
count = Job(name="count")
#ntimes=100
a1 = File("aa1")
#b1 = File("out.1")
count.addArguments("100",a1)
#count.uses(a1, link=Link.INPUT)
count.uses(a1, link=Link.OUTPUT, transfer=False, register=False)
simplewf.addJob(count)


# Add sort job
print "Adding sort job..."
sort = Job(name="sort")
c1 = File("output.fin")
sort.addArguments(a1,c1)
sort.uses(a1, link=Link.INPUT)
sort.uses(c1, link=Link.OUTPUT, transfer=True, register=False)
simplewf.addJob(sort)



# Add control-flow dependencies
print "Adding control flow dependencies..."
simplewf.addDependency(Dependency(parent=count, child=sort))


# Write the DAX to stdout
print "Writing %s" % daxfile
f = open(daxfile, "w")
simplewf.writeXML(f)
f.close()

