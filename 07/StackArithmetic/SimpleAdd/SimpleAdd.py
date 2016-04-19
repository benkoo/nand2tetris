#!/Users/bkoo/anaconda/bin/python3.5

# 2016 Ben Koo
"""
SimpleAdd.py -- a program for Chapter 7 of Nand2Tetris

"""

import sys
import os
import tkinter
import cProfile
import unittest

from SimpleAddError import *


def Usage():
    print('usage: SimpleAdd sourceFile')
    sys.exit(-1)


def Main():
    global outFile, inFile

    try:
        if len(sys.argv) != 2:
            Usage()

        sourceName = sys.argv[1]
        outName = os.path.splitext(sourceName)[0] + os.path.extsep + 'asm'

        try:
            inFile = open(sourceName,'r')
        except:
            FatalError('Could not open input file"' + sourceName + '"')

        #Read the file content
        fileContent = inFile.read()

        # Close the file.
        inFile.close()

        # Print the data that was read into
        # memory.
        print(fileContent)

        try:
            outFile = open(outName, 'w')
        except:
            FatalError('Could not open output file "' + outName + '"')

        outFile.write(fileContent)


    except SystemExit as e:
        sys.exit(e)


if __name__ == '__main__':
    Main()
