'HAMEG Germany
DECLARE SUB Remote ()
DECLARE SUB SetLocal ()
DECLARE SUB ReadReturnCode ()
DECLARE SUB SaveWaveForm (WaveForm AS STRING)
DIM WaveForm AS STRING
DIM InString AS STRING
DIM OutString AS STRING
CONST Start = 24, Length = 2000

ON ERROR GOTO TransferError

CLS
PRINT "Read..."
Remote

OutString = "RDWFM1:" + MKI$(Start) + MKI$(Length)'command = "read waveform channel 1"
PRINT #1, OutString                               'send command
InString = INPUT$(11 + Length, #1)                '11 byte command + Length * byte
WaveForm = MID$(InString, 12)                     'cut command

SetLocal
SaveWaveForm WaveForm                             'save in a file
END

TransferError:
IF ERR = 64 THEN
          PRINT "Port not present !"
          END                                     'exit
END IF
PRINT #1, "RM0"                                   'Remote off
CLOSE
SELECT CASE ERR
          CASE 24
                    PRINT "Timeout on port !"
          CASE 55, 25
                    PRINT "Port already open !"
          CASE 57
                    PRINT "Device error !"
          CASE 69
                    PRINT "Buffer overflow !"
          CASE 100
                    PRINT "Bad answer scope !"
          CASE IS > 100
          CASE ELSE
                    PRINT "ERROR: ", ERR
END SELECT
BEEP
END

SUB ReadReturnCode
DIM ReturnCode AS STRING
        
        ReturnCode = MID$(INPUT$(3, #1), 1, 1)
        SELECT CASE ReturnCode           'select returncode
        CASE "0"
        CASE "1"
                PRINT "Answer scope: Syntax error !"
                ERROR 101
        CASE "2"
                PRINT "Answer scope: Data error !"
                ERROR 102
        CASE "3"
                PRINT "Answer scope: Buffer overflow !"
                ERROR 103
        CASE "4"
                PRINT "Answer scope: Bad data set !"
                ERROR 104
        CASE "5"
                PRINT "Answer scope: Adjust error !"
                ERROR 105
        CASE "6"
                PRINT "Answer scope: Timing error !"
                ERROR 106
        CASE ELSE
                PRINT "Answer scope unknown !"
                PRINT "Answer: ", ReturnCode
                ERROR 107
        END SELECT
END SUB

SUB Remote
          OPEN "COM2:9600,n,8,2,cs1000,ds100,cd100,tb2100,rb2100" FOR RANDOM AS 1
          PRINT #1, " "
          ReadReturnCode                                    'SUB
END SUB

SUB SaveWaveForm (WaveForm AS STRING)
     CLS
     BEEP
     INPUT "Filename without extension: ", FileName$
     FileName$ = FileName$ + ".wfm"
     OPEN FileName$ FOR OUTPUT AS 1
     FOR i = 1 TO LEN(WaveForm) STEP 1        'save byte to file "FileName"
          PRINT #1, ASC(MID$(WaveForm, i))
     NEXT i
     CLOSE #1
END SUB

SUB SetLocal
          PRINT #1, "rm0"     'Remote off
          ReadReturnCode
          CLOSE               'close port
END SUB

