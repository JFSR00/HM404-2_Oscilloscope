'HAMEG Germany
OPEN "COM2:9600,n,8,2,cs1000,ds0,cd0" FOR RANDOM AS 1
               '9600 baud, no parity, 8 data bit, 2 stop bit, CTS-Timeout=1s
PRINT #1, " "                          'space (CR in Basic) = Remote on
CLS
ReturnCode$ = INPUT$(3, #1)            'read returncode
PRINT #1, "id?"                        'command PC --> Scope
PRINT INPUT$(30, #1)                   'answer Scope --> PC
PRINT #1, "vers?"                      'command PC --> Scope
PRINT INPUT$(20, #1)                   'answer Scope --> PC
PRINT #1, "bell=1"                     'command PC --> Scope
ReturnCode$ = INPUT$(3, #1)            'read returncode
PRINT #1, "rm0"                        'send Remote off
ReturnCode$ = INPUT$(3, #1)            'read returncode
CLOSE                                  'close ComPort

