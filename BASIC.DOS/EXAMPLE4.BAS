'HAMEG Germany
DECLARE FUNCTION VoltPerDivCH2! ()                ' get Volt/Div channel 2
DECLARE SUB GetTriggerValue ()                    ' get A/D-Converter Value Triggerunit
DECLARE FUNCTION VoltPerDivCH1! ()                ' get Volt/Div channel 1
DECLARE SUB AutoSet ()                            ' run autoset scope
DECLARE SUB SetLocal ()                           ' remote off
DECLARE SUB Remote ()                             ' remote
DECLARE SUB SaveDDF ()                            ' save DDF on PC
DECLARE SUB SaveDDF1 ()                           ' save DDF1 on PC
DECLARE SUB RestoreDDF1 ()                        ' write DDF to scope
DECLARE SUB RestoreDDF ()                         ' write DDF1 to scope
DECLARE SUB ReadReturnCode ()
DIM SHARED DDF(14) AS STRING * 1
DIM SHARED DDF1(8) AS INTEGER
DIM SHARED TriggerValue(4) AS INTEGER
DIM SHARED i AS INTEGER
DIM SHARED InString AS STRING
DIM SHARED OutString AS STRING
DIM VoltPerDiv AS SINGLE
CONST UPeakPlus = 1, UPeakMinus = 2, Mean = 3

ON ERROR GOTO TransferError

CLS
Remote
SaveDDF
SaveDDF1
PRINT #1, "CH1=" + CHR$(20)                       ' CH1 = ON, 5mV
ReadReturnCode
PRINT #1, "CH2=" + CHR$(0)                        ' CH2 = OFF
ReadReturnCode
AutoSet
GetTriggerValue
VoltPerDiv = VoltPerDivCH1
PRINT "Channel 1"
PRINT " Up+ = "; TriggerValue(UPeakPlus) / 1000 * VoltPerDiv; "V" '1000/Div  
PRINT " Up- = "; TriggerValue(UPeakMinus) / 1000 * VoltPerDiv; "V"
PRINT
PRINT #1, "CH2=" + CHR$(20)                       ' CH2 = ON, 5mV
ReadReturnCode
PRINT #1, "CH1=" + CHR$(0)                        ' CH1 = OFF
ReadReturnCode
AutoSet
GetTriggerValue
VoltPerDiv = VoltPerDivCH2
PRINT "Channel 2"
PRINT " Upp+ = "; TriggerValue(UPeakPlus) / 1000 * VoltPerDiv; "V"
PRINT " Upp- = "; TriggerValue(UPeakMinus) / 1000 * VoltPerDiv; "V"
PRINT
RestoreDDF
RestoreDDF1
SetLocal
PRINT "OK"
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
          CASE 100
                    PRINT "Bad answer scope !"
          CASE IS > 100
          CASE ELSE
                    PRINT "ERROR: ", ERR
END SELECT
BEEP
END

SUB AutoSet
          PRINT #1, "AUTOSET"          'run autoset
          ReadReturnCode
END SUB

SUB GetTriggerValue
          PRINT #1, "TRGVAL?"
          IF INPUT$(7, #1) <> "TRGVAL:" THEN ERROR 100      'OK?
          FOR i = 1 TO 4
                    TriggerValue(i) = CVI(INPUT$(2, #1))    'convert to integer
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

SUB Remote
          OPEN "COM2:9600,n,8,2,cs1000,ds100,cd100" FOR RANDOM AS 1
          PRINT #1, " "
          ReadReturnCode                                    'SUB
END SUB

SUB RestoreDDF
          OutString = "DDF="
          FOR i = 1 TO 14
                    OutString = OutString + DDF(i)
          NEXT i
          PRINT #1, OutString                               'write DDF
          ReadReturnCode
END SUB

SUB RestoreDDF1
          OutString = "DDF1="
          FOR i = 1 TO 8
                    OutString = OutString + MKI$(DDF1(i)) 'convert to string
          NEXT i
          PRINT #1, OutString                             'write DDF1
          ReadReturnCode
END SUB

SUB SaveDDF
          PRINT #1, "DDF?"                                  'command
          IF INPUT$(4, #1) <> "DDF:" THEN ERROR 100         'OK?
          FOR i = 1 TO 14
                    DDF(i) = INPUT$(1, #1)                  'store DDF
          NEXT i
END SUB

SUB SaveDDF1
          PRINT #1, "DDF1?"
          IF INPUT$(5, #1) <> "DDF1:" THEN ERROR 100       'OK?
          FOR i = 1 TO 8
                    DDF1(i) = CVI(INPUT$(2, #1))           'convert to integer
          NEXT i
END SUB

SUB SetLocal
          PRINT #1, "rm0"     'Remote off
          ReadReturnCode
          CLOSE               'close port
END SUB

FUNCTION VoltPerDivCH1
DIM Volts(14) AS SINGLE
DIM Counter AS INTEGER
          Volts(1) = .001: Volts(2) = .002: Volts(3) = .005: Volts(4) = .01
          Volts(5) = .02: Volts(6) = .05: Volts(7) = .1: Volts(8) = .2
          Volts(9) = .5: Volts(10) = 1: Volts(11) = 2: Volts(12) = 5
          Volts(13) = 10: Volts(14) = 20
          PRINT #1, "ch1?"
          IF INPUT$(4, #1) <> "CH1:" THEN ERROR 100      'OK?
          Counter = ASC(INPUT$(1, #1)) AND 15
          VoltPerDivCH1 = Volts(Counter + 1)
END FUNCTION

FUNCTION VoltPerDivCH2
DIM Volts(14) AS SINGLE
DIM Counter AS INTEGER
          Volts(1) = .001: Volts(2) = .002: Volts(3) = .005: Volts(4) = .01
          Volts(5) = .02: Volts(6) = .05: Volts(7) = .1: Volts(8) = .2
          Volts(9) = .5: Volts(10) = 1: Volts(11) = 2: Volts(12) = 5
          Volts(13) = 10: Volts(14) = 20
          PRINT #1, "CH2?"
          IF INPUT$(4, #1) <> "CH2:" THEN ERROR 100      'OK?
          Counter = ASC(INPUT$(1, #1)) AND 15
          VoltPerDivCH2 = Volts(Counter + 1)
END FUNCTION

