parser: Parser.java Scanner.java Node.java
	javac -classpath "" *.java

Parser.java: parse.y
	bin/yacc.exe -Jsemantic=Node parse.y

Scanner.java: m4.jflex
	bin/jflex scan.jflex

clean:
	rm *.class Parser.java Scanner.java
