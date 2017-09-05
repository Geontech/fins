#===============================================================================
# Company:     Geon Technologies, LLC
# File:        Makefile
# Description: The simplest of Makefiles for running SimLanes examples
#
# Revision History:
# Date        Author             Revision
# ----------  -----------------  -----------------------------------------------
# 2017-08-10  Josh Schindehette  Initial Version
#
#===============================================================================

.PHONY: all octave matlab clean

all octave: clean
	octave gain_sim.m

matlab: clean
	matlab -nosplash -nodesktop -r "gain_sim;exit"

clean:
	rm -rf *.jou *.log *.txt *.mat
	rm -rf gain
