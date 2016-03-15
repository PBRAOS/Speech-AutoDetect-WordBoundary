# getAllDuration
#
# Author: William Furr
# Date: 13 March 2011
#
# Converts textgrid samples to a CSV table suitable for importing to Excel or
# Matlab for analysis

import os

def getInputFiles(inputDir):
	'''
	Returns a list of all sound sample names in the given input directory
	without their extensions.
	'''
	retFiles = []
	
	# traverse the input directory
	for file in os.listdir(inputDir):
		prefix = os.path.splitext(file)[0].strip()
		ext = os.path.splitext(file)[1].strip()
		
		# match .wav files only
		if(ext == '.wav'):
			retFiles.append(prefix)
				
	return retFiles

def parseTextGrid(samples, sample_name):
	'''
	Returns a words structure with the word intervals xmin and xmax
	'''

	# parse text grid for words and intervals
	file = open(sample_name + '.TextGrid', 'r')
	lines = file.read().split('\n')
	file.close()
	for line in lines:
		line = line.strip()
		if line.startswith('xmin'):
			xmin = line.split(' ')[2].strip('" ')
		if line.startswith('xmax'):
			xmax = line.split(' ')[2].strip('" ')
		if line.startswith('text'):
			word = line.split(' ')[2].strip('" ')
			if word != "":
				duration = float(xmax) - float(xmin)
				samples.append({'sample_name':sample_name, 'word': word, \
				                'xmin': xmin, 'xmax': xmax, \
								'duration':str(duration)})

def writeDurationCSV(samples):
	'''
	Writes out the pitch values as a CSV file for a given sample.
	'''

	# write CSV file
	file = open('duration.csv', 'w')
	file.write('"Sample Name","Word","Duration","Xmin","Xmax"\n')
	for sample in samples:
		file.write('"' + sample['sample_name'] + '","' + sample['word'] + \
		           '","' + sample['duration'] + '","' + sample['xmin'] + \
				   '","' + sample['xmax'] + '"\n')
	file.close()

samples = []
for sample in getInputFiles('.'):
	parseTextGrid(samples, sample)
writeDurationCSV(samples)