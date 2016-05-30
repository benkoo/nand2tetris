
import sys
import os

from FileParser import *
from FileError import *
from FileSymbols import *
from FileCode import *


def firstPass(fileName):
    global symbolTable, address

    symbolTable = Symbols()
    address = 0

    parser = Parser(fileName)

    parser.loadCompletFile()

    for aLine in parser.textLines:
        print("The line being parsed is:", aLine)
        parser._parse(aLine)
        commandType = parser.CommandType()

        if commandType == NO_COMMAND:
            pass
        elif commandType in (A_COMMAND, C_COMMAND):
            address += 1
        elif commandType == L_COMMAND:
            symbol = parser.Symbol()
            if symbolTable.Contains(symbol):
                Error('The symbol ' + symbol + 'has been defined',
                      parser.LineNo(), parser.Line())
            elif not symbolTable.AddEntry(symbol, address):
                Error('Invalid symbol name ' + symbol,
                      parser.LineNo(), parser.Line())

def secondPass(fileName):
    global ramAddress

    coder = Code()
    parser = Parser(fileName)
    parser.loadCompletFile()

    for aLine in parser.textLines:
        parser._parse(aLine)
        commandType = parser.CommandType()

        if commandType == NO_COMMAND:
            pass

        elif commandType == A_COMMAND:
            symbol = parser.symbol
            try:
                value = int(symbol)
            except:
                if symbolTable.Contains(symbol):
                    value = symbolTable.GetAddress(symbol)
                elif symbolTable.AddEntry(symbol, ramAddress):
                    value = ramAddress
                    ramAddress += 1
                else:
                    Error('Invalid symbol name ' + symbol,
                          parser.LineNo(), parser.Line())
                    value = 0x7FFF
            code = value & 0x7FFF
            print(Int2Bin(code) + '\n')
            address += 1


        elif commandType == C_COMMAND:
            dest = coder.Dest(parser.Dest())

            if dest == None:
                Error('unknown destination field: ' + parser.Dest(),
                      parser.LineNo(), parser.Line())
                dest = '???'
            comp = coder.Comp(parser.Comp())
            if comp == None:
                Error('unknown computation field: ' + parser.Comp(),
                      parser.LineNo(), parser.Line())
                comp = '???????'

            jump = coder.Jump(parser.Jump())

            if jump == None:
                Error('unknown jump field: ' + parser.Jump(),
                      parser.LineNo(), parser.Line())
                jump = '???'

            bin = ('111' + comp + dest + jump)
            print(bin + '\n')
            address += 1


        elif commandType == L_COMMAND:
            pass


def Int2Bin(i):
    bin = ''
    while i:
        if i & 1:
            bin = '1' + bin
        else:
            bin = '0' + bin
        i //= 2
    bin = '0' * 16 + bin
    return bin[-16:]


def Usage():
    print('usage: FileMain sourceFile.asm')
    # We may temporarily suspend this exit statement, so that we can continue to process the choosen file.
    # sys.exit(-1)

def Main():
    global CHOOSENFILENAME, outputFile

    CHOOSENFILENAME = 'Add.asm'

    if len(sys.argv) != 2:
        Usage()


    sourceFileName = sys.path[0] + os.path.sep + CHOOSENFILENAME

    firstPass(sourceFileName)

    for entry in symbolTable.symbolDict.items():
        print(entry)

    secondPass(sourceFileName)

    outfileName = os.path.splitext(sourceFileName)[0] + os.path.extsep + 'hack'

    try:
        outFile = open(outfileName, 'w')
        print('\nOutput to this file:', outfileName)
    except:
        FatalError('Could not open output file "' + outfileName + '"')

if __name__ == '__main__':
    Main()