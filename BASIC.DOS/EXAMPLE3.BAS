'HAMEG Germany
DECLARE SUB ReadReturnCode ()
DIM TBA AS STRING * 1
DIM Shots AS INTEGER
DIM InString AS STRING
DIM OutString AS STRING

ON ERROR GOTO TransferError

CLS
OPEN "COM2:9600,n,8,2,cs1000,ds100,cd100" FOR RANDOM AS 1
PRINT #1, " "
ReadReturnCode                                    'SUB
PRINT #1, "TBA?"
IF INPUT$(4, #1) <> "TBA:" THEN ERROR 100         'OK?
TBA = INPUT$(1, #1)                               'read TimbaseA-byte
PRINT #1, "TBA=" + CHR$(ASC(TBA) OR 32)           'set singlebit & send to scope
ReadReturnCode
PRINT #1, "RES"                                   'set reset
ReadReturnCode
PRINT "Press SPACE to exit."
PRINT
PRINT "Shots:0"
Shots = 0
DO
          PRINT #1, "TRGSTA?"
          IF MID$(INPUT$(8, #1), 8, 1) = "0" THEN 'Trigerstatus ?
                    PRINT #1, "RES"               'set reset
                    ReadReturnCode
                    Shots = Shots + 1
                    LOCATE 3, 7
                    PRINT Shots
          END IF
LOOP UNTIL INKEY$ = " "
PRINT #1, "TBA=" + TBA                            'send old byte
ReadReturnCode
PRINT #1, "rm0"                                   'Remote off
ReadReturnCode
CLOSE
PRINT "OK"
END



TransferError:
IF ERR = 64 THEN
          PRINT "Port not present !"
          END                                     'exit
END IF
PRINT #1, "rm0"                                   'Remote off
CLOSE
SELECT CASE ERR
          CASE 24
                    PRINT "Timeout on port !"
          CASE 55, 25
                    PRINT "Port already open !"
          CASE 57
                    PRINT "Device error !"
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

