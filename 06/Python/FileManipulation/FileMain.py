
import sys
import os

from FileParser import *
from FileError import *


def tryOneLine(fileName):

    parser = Parser(fileName)

    parser.loadCompletFile()

    for aLine in parser.textLines:
        print("The line being parsed is:", aLine)
        parser._parse(aLine)





def Usage():
    print('usage: FileMain sourceFile.asm')
    # We may temporarily suspend this exit statement, so that we can continue to process the choosen file.
    # sys.exit(-1)

def Main():
    global CHOOSENFILENAME, outputFile

    CHOOSENFILENAME = 'Pong.asm'

    if len(sys.argv) != 2:
        Usage()


    sourceFileName = sys.path[0] + os.path.sep + CHOOSENFILENAME

    tryOneLine(sourceFileName)

    outfileName = os.path.splitext(sourceFileName)[0] + os.path.extsep + 'hack'

    try:
        outFile = open(outfileName, 'w')
        print('\nOutput to this file:', outfileName)
    except:
        FatalError('Could not open output file "' + outfileName + '"')

if __name__ == '__main__':
    Main()