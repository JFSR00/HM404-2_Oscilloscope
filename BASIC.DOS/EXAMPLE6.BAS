'HAMEG Germany
DECLARE SUB PlotOnScreen (WaveForm AS STRING)
DECLARE FUNCTION ReadWaveChannel1$ (Start AS INTEGER, Length AS INTEGER)
DECLARE SUB Remote ()
DECLARE SUB SetLocal ()
DECLARE SUB ReadReturnCode ()
DIM WaveForm AS STRING
CONST Start = 24, Length = 2000                   ' start & length waveform

ON ERROR GOTO TransferError

CLS
Remote
WaveForm = ReadWaveChannel1$(Start, Length)
SetLocal
PlotOnScreen (WaveForm)
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

SUB PlotOnScreen (WaveForm AS STRING)
DIM X1, X2, Y1, Y2 AS INTEGER
DIM FactorX, FactorY AS INTEGER
     SCREEN 12                                   'VGA
     LINE (0, 0)-(0, 464), 1
     LINE (0, 0)-(5, 15), 1
     LINE (0, 464)-(5, 449), 1
     LINE (0, 240)-(640, 240), 1
     LINE (640, 240)-(625, 235), 1
     LINE (640, 240)-(625, 245), 1
     FactorX = 640 / LEN(WaveForm)
     FactorY = 480 / 254
     X2 = 0
     Y2 = 240
     FOR i = 1 TO LEN(WaveForm) STEP 1
          X1 = X2
          Y1 = Y2
          X2 = i * FactorX
          Y2 = ASC(MID$(WaveForm, i)) * FactorY
          Y2 = 480 - Y2
          LINE (X1, Y1)-(X2, Y2), 2
     NEXT i

END SUB

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

FUNCTION ReadWaveChannel1$ (Start AS INTEGER, Length AS INTEGER)
DIM InString AS STRING
DIM OutString AS STRING
          PRINT "Read waveform channel 1 ..."
          OutString = "RDWFM1:" + MKI$(Start) + MKI$(Length)'command = "read waveform channel 1"
          PRINT #1, OutString                               'send command
          InString = INPUT$(11 + Length, #1)                '11 byte command + Length * byte
          ReadWaveChannel1$ = MID$(InString, 12)             'cut command
END FUNCTION

SUB Remote
          OPEN "COM2:9600,n,8,2,cs1000,ds100,cd100,tb2100,rb2100" FOR RANDOM AS 1
          PRINT #1, " "
          ReadReturnCode                                    'SUB
END SUB

SUB SetLocal
          PRINT #1, "rm0"     'Remote off
          ReadReturnCode
          CLOSE               'close port
END SUB

