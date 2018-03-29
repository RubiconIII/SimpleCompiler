%%

%class Scanner
%unicode
%line
%column
%byaccj

%{
	/* store a reference to the parser object */
	private Parser yyparser;

	/* constructor taking an additional parser */
	public Scanner (java.io.Reader r, Parser yyparser) {
		this (r);	
		this.yyparser = yyparser;
	}

	/* return the current line number.*/
	public int getLine() {
		return yyline;
	}

	/* return the current column number.*/
	public int getColumn() {
		return yycolumn;
	}

%}

%%

("/*" (.*[\r\n])|.* "*/")	{ /* allow multi line comments */ }

("//" .*)	            { /* single line comment */ }


PROGRAM 				{ yyparser.yylval = new Node(yytext()); 
					      return Parser.PROGRAM;}
BEGIN   				{ yyparser.yylval = new Node(yytext()); 
			              return Parser.BEGIN; } 
END						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.END; }
INT						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.INT; }
FLOAT					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.FLOAT; }
STRING					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.STRING; }
PRINT					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.PRINT; }
"("						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.OPEN_PAREN; }
")"						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.CLOSE_PAREN; }

"=="					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }
"!="					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }
"<="					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }
">="					{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }
"<"						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }
">"						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.REL_OP; }

[a-zA-Z][a-zA-Z0-9]*	{ yyparser.yylval = new Node(yytext()); 
						  return Parser.ID; }
[0-9]+					{ yyparser.yylval = new Node(yytext(), "INT");
        				  return Parser.NUM; }
[0-9]+\.[0-9]+			{ yyparser.yylval = new Node(yytext(), "FLOAT");
        				  return Parser.NUM; }
\"[a-zA-Z0-9]*\"		{ yyparser.yylval = new Node(yytext(), "STRING");
        				  return Parser.TEXT; }
\=						{ yyparser.yylval = new Node(yytext());
						  return Parser.ASSIGN; }
\+						{ yyparser.yylval = new Node(yytext()); 
						  return Parser.PLUS; }
\-						{ yyparser.yylval = new Node(yytext());
						  return Parser.MINUS; }
\;						{ yyparser.yylval = new Node(yytext()); 
						  return (int) yycharat(0); }
\.					    { yyparser.yylval = new Node(yytext()); 
						  return (int) yycharat(0); }						  
[ \t\n\r]				{ }

