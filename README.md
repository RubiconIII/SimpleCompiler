THIS IS A SIMPLE COMPILER BY:
Curtis P. Hohl - 11/2/2017.

The language to be compiler is very simple.  It allows variable declarations (INT FLOAT STRING), 
simple addition and subtraction, standard operators (== != <= >= >  <), and PRINT.  Detailed syntax can be seen in scan.jflex.

This program uses byaccj and jflex. The output is in MIPS Assembly language and can be run with lib/Mars4_5.jar

To use the program, run the Makefile, which will generate .java and .class files.
Then run in a UNIX terminal the command: java Parser (inputFileNameHere).txt
I've included a sample input file: m4-input.txt

Happy compiling!
