from FileError import *

# Define a set of constants for various instruction types

NO_COMMAND = 0
A_COMMAND = 1
C_COMMAND = 2
L_COMMAND = 3


class Parser(object):

    def __init__(self, fileName):
        """
        Costructor Parser(fileName)
        Open 'source' and get ready to parse it.
        'source' may be a file name or a string list
        """

        self.sourceFileName = fileName

        try:
            self.file = open(fileName, 'r')
        except:
            FatalError('Could not open source file "' + fileName + '"')

        if self.IsEmpty():
            SystemExit()
        else:
            print('File is not empty', fileName)
            self.file.close()

        self.lineNumber = 0
        self.rawline = ''
        self.line = ''
        self.textLines = ()



    def IsEmpty(self):
        self.rawline = self.file.readline()
        if len(self.rawline) == 0:
            self.file.close()
            self.file = None
            self.commandType = NO_COMMAND
            return True
        else:
            self.file.close()
            return False


    def CommandType(self):
        """
        Returns the type of the current command:
        A_COMMAND for @Xxx where Xxx is either a symbol or a decimal number
        C_COMMAND for dest=comp;jump
        L_COMMAND (actually, pseudocommand) for (Xxx) where Xxx is a symbol
        NO_COMMAND a blank line or comment
        """
        return self.commandType

    def Symbol(self):
        return self.symbol

    def loadCompletFile(self):
        try:
            self.file = open(self.sourceFileName, 'r')

            self.textLines = self.file.readlines()

            print('The class of textLines is: ' , self.textLines.__class__ , "and contains" , self.textLines.__len__(), "lines \n")

        except:
            FatalError('Could not open source file:' + self.sourceFileName)

    def _parse(self, aLine):
        self.commandType = None
        self.symbol = None
        self.comp = None
        self.jump = None
        self.keywordId = None

        self.rawline = aLine
        self.rawline = self.rawline.rstrip()
        self.rawline = self.rawline.lstrip()

        if self.rawline.find('//') == 0:
            self.line = ''
        else:
            self.line = self.rawline
        self._parseCommandType()


        if self.commandType == A_COMMAND:
            self._parseAddress()
        elif self.commandType == L_COMMAND:
            self._parseSymbol()
        elif self.commandType == C_COMMAND:
            self._parseCommand()
        else:
            self._parseNoCommand()

    def _parseCommandType(self):
        if len(self.line) == 0:
            self.commandType = NO_COMMAND
        elif self.line[0] == '@':
            self.commandType = A_COMMAND
        elif self.line[0] == '(':
            self.commandType = L_COMMAND
        else:
            self.commandType = C_COMMAND

    def _parseAddress(self):
        if self.commandType == A_COMMAND:
            if self.line[0] == '@':
                self.line = self.line[1:].strip()
                print('Parsed Address = ', self.line, '\n\n')
        else:
            print('Parsed Address is illformed = ', self.line, '\n\n')

    def _parseSymbol(self):
        if self.commandType == L_COMMAND:
            if self.line[-1] == ')':
                self.line = self.line[:-1]
                self.symbol = self.line[1:].strip()
                print('Parsed Symbol = ', self.symbol, '\n\n')
        else:
            print('Parsed Symbol is illformed = ', self.line, '\n\n')

    def _parseCommand(self):
        self._parseDest()
        self._parseComp()
        self._parseJump()

    def _parseDest(self):
        if self.commandType == C_COMMAND:
            i = self.line.find('=')
            if i == -1:
                self.dest = ''
            else:
                self.dest = self.line[:i].strip()
                print('DESTINATION:' , self.dest)


    def _parseComp(self):
        if self.commandType == C_COMMAND:
            i = self.line.find('=')
            if i == -1:
                self.comp = ''
            else:
                self.comp = self.line[i+1:].strip()
                print('COMPUTATION:', self.comp)

    def _parseJump(self):
        if self.commandType == C_COMMAND:
            i = self.line.find(';')
            if i == -1:
                self.jump = ''
            else:
                self.jump = self.line[i+1:].strip()
                print('JUMP INSTRUCTION:', self.jump)

    def _parseNoCommand(self):
        if len(self.rawline) == 0:
            print('COMMENT LINE is EMPTY. \n\n')
        else:
            print('COMMENT LINE: ' , self.rawline, "\n\n")
