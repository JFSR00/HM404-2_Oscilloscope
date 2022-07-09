'HAMEG Germany
DECLARE SUB ReadReturnCode ()
DIM DDF(14) AS STRING * 1
DIM InString AS STRING
DIM OutString AS STRING
DIM i AS INTEGER

ON ERROR GOTO TransferError

CLS
OPEN "COM2:9600,n,8,2,cs1000,ds100,cd100" FOR RANDOM AS 1
PRINT #1, " "
ReadReturnCode                                  'SUB
PRINT #1, "DDF?"                                'command
IF INPUT$(4, #1) <> "DDF:" THEN ERROR 100       'OK?
FOR i = 1 TO 14
        DDF(i) = INPUT$(1, #1)                  'read DDF
NEXT i
DDF(1) = CHR$(128 + 16 + 3)                     'CH1 = GND + ON + 10mV
DDF(2) = CHR$(64 + 16 + 10)                     'CH2 = AC + ON + 2V
DDF(3) = CHR$(1)                                'Trigger = CH2
DDF(4) = CHR$(2)                                'TBA = 200ns
DDF(6) = CHR$(0)                                'TBA only
DDF(7) = CHR$(128 + 32 + 1)                     'Trigger = \ + PP + DC
OutString = "DDF="
FOR i = 1 TO 14
        OutString = OutString + DDF(i)
NEXT i
PRINT #1, OutString                             'write command and DDF
ReadReturnCode
PRINT #1, "rm0"                                 'Remote off
ReadReturnCode
CLOSE
PRINT "OK"
END

TransferError:
IF ERR = 64 THEN
          PRINT "Port not present !"
          END
END IF
PRINT #1, "rm0"                                 'Remote off
CLOSE
SELECT CASE ERR
          CASE 24
                    PRINT "Timeout on port !"
          CASE 55
                    PRINT "Port already open !"
          CASE 57, 25
                    PRINT "Device error !"
          CASE 100
                    PRINT "Bad answer scope !"
          CASE IS > 100
          CASE ELSE
                    PRINT "Error unknown !"
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

