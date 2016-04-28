"""
hvmCodeWriter.py -- Code Writer class for Hack VM translator
"""

import os
from hvmCommands import *

debug = True

class CodeWriter(object):
    
    def __init__(self, outputName):
        """
        Open 'outputName' and gets ready to write it.
        """
        self.file = open(outputName, 'w')
        self.fileName = self.SetFileName(outputName)

        # used to generate unique labels
        self.labelNumber = 0


    def Close(self):
        """
        Write a jmp $ and close the output file.
        """
        label = self._UniqueLabel()
        self._WriteCode('(%s), @%s, 0;JMP' % (label, label))
        self.file.close()


    def SetFileName(self, fileName):
        """
        Sets the current file name to 'fileName'.
        Restarts the local label counter.

        Strips the path and extension.  The resulting name must be a
        legal Hack Assembler identifier.
        """
        self.fileName = os.path.basename(fileName)
        self.fileName = os.path.splitext(self.fileName)[0]


    def _UniqueLabel(self):
        self.labelNumber += 1
        return '_' + str(self.labelNumber)


    def _Static(self, n):
        return self.fileName + '.' + str(n)    


    def _WriteCode(self, code):
        code = code.replace(',', '\n').replace(' ', '')
        self.file.write(code + '\n')


    def WriteArithmetic(self, command):
        """
        Write Hack code for 'command' (str).
        """
        if (debug):
            self.file.write('    // %s\n' % command)
        if command == T_ADD:
            self._WritePopD()  # side effect: A = SP
            self._WriteCode('A=A-1, M=M+D')
        elif command == T_SUB:
            self._WritePopD()  # side effect: A = SP
            self._WriteCode('A=A-1, M=M-D')
        elif command == T_AND:
            self._WritePopD()  # side effect: A = SP
            self._WriteCode('A=A-1, M=M&D')
        elif command == T_OR:
            self._WritePopD()  # side effect: A = SP
            self._WriteCode('A=A-1, M=M|D')
        elif command == T_NEG:
            self._WriteCode('@SP, A=M-1, M=-M')
        elif command == T_NEG:
            self._WriteCode('@SP, A=M-1, M=!M')
        elif command == T_EQ:
            self._WriteCompare('JEQ')
        elif command == T_GT:
            self._WriteCompare('JGT')
        elif command == T_LT:
            self._WriteCompare('JLT')
        else:
            raise(ValueError, 'Bad arithmetic command')

        
    def _WritePushD(self):
        self._WriteCode('@SP, A=M, M=D, @SP, M=M+1')


    def _WritePopD(self):
        self._WriteCode('@SP, AM=M-1, D=M')


    def _WriteCompare(self, jmp):
        label1 = self._UniqueLabel();
        label2 = self._UniqueLabel();
        self._WriteCode('@SP, A=M-1, A=A-1, D=M, A=A+1, D=D-M')
        self._WriteCode('@%s, D;%s' % (label1, jmp))
        self._WriteCode('@%s, D=0;JMP' % (label2))
        self._WriteCode('(%s), D=-1, (%s)' % (label1, label2))
        self._WriteCode('@SP, AM=M-1, A=A-1, M=D')


    def WritePushPop(self, commandType, segment, index):
        """
        Write Hack code for 'commandType' (C_PUSH or C_POP).
        'segment' (string) is the segment name.
        'index' (int) is the offset in the segment.
        """
        if commandType == C_PUSH:
            if (debug):
                self.file.write('    // push %s %d\n' % (segment, int(index)))
            if segment == T_CONSTANT:
                self._WriteCode('@%d, D=A' % (int(index)))
                self._WritePushD()
            elif segment == T_STATIC:
                self._WriteCode('@%s.%d, D=M' % (self.fileName, int(index)))
                self._WritePushD()
            elif segment == T_POINTER:
                self._WriteCode('@%d, D=M' % (3 + int(index)))
                self._WritePushD()
            elif segment == T_TEMP:
                self._WriteCode('@%d, D=M' % (5 + int(index)))
                self._WritePushD()
            else:
                self._WriteGetPtrD(segment, index)
                self._WriteCode('A=D, D=M')
                self._WritePushD()
        elif commandType == C_POP:
            if (debug):
                self.file.write('    // pop %s %d\n' % (segment, int(index)))
            if segment == T_STATIC:
                self._WritePopD()
                self._WriteCode('@%s.%d, M=D' % (self.fileName, int(index)))
            elif segment == T_POINTER:
                self._WritePopD()
                self._WriteCode('@%d, M=D' % (3 + int(index)))
            elif segment == T_TEMP:
                self._WritePopD()
                self._WriteCode('@%d, M=D' % (5 + int(index)))
            else:
                self._WriteGetPtrD(segment, index)
                self._WriteCode('@R15, M=D')
                self._WritePopD()
                self._WriteCode('@R15, A=M, M=D')
        else:
            raise(ValueError, 'Bad push/pop command')


    def _WriteGetPtrD(self, segment, index):
        if segment == T_CONSTANT:
            raise(ValueError, 'constant segment is virtual')
        elif segment == T_STATIC:
            raise(ValueError, 'static segment is not indexed')
        elif segment == T_POINTER:
            raise(ValueError, 'pointer segment is not dynamic')
        elif segment == T_TEMP:
            raise(ValueError, 'temp segment is not dynamic')
        
        if segment == T_ARGUMENT:
            pointer = 'ARG'
        elif segment == T_LOCAL:
            pointer = 'LCL'
        elif segment == T_THIS:
            pointer = 'THIS'
        elif segment == T_THAT:
            pointer = 'THAT'
        else:
            raise(ValueError, 'unknown segment name')

        self._WriteCode('@%s, D=M, @%d, D=D+A' % (pointer, int(index)))
            


        

