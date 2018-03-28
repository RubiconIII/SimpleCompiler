%{
import java.io.*;
import java.util.*;
import java.text.*;
%}

%token ID NUM ASSIGN PLUS MINUS BEGIN END PROGRAM INT FLOAT STRING REL_OP TEXT PRINT OPEN_PAREN CLOSE_PAREN
%start program

%%

program      : PROGRAM ID ';'
               prog_lines
               subprograms
               compound_stmt
               '.'	{assemblyText.add("li $v0, 10"); assemblyText.add("syscall"); printAssembly();}

prog_lines   : stmt_list            { $$ = $1; 

                                    pushScope(); 
                                    if (isDebug) {
                                        System.out.println("\n\n"); 
                                        printNode($$); 
									  }	
										
                                    }
             | {/* empty */}
             ;

stmt_list   :   stmt                 { $$ = $1; }
            |   stmt_list ';' stmt   { $$ = makeNode(";", $1, $3);  }
            ;

subprograms     :  subprograms compound_stmt     
                |  {/* empty */}
                ;

compound_stmt   :  BEGIN prog_lines compound_stmt END  { exitScope(); }
                |  {/* empty */}
                ;

stmt    :   type ID ASSIGN expr   { 
                                    Node id = $2;
                                    id.type = $1.token;
                                    Node node = makeNode($3.token, id, $4); 
                                    String type = postOrderIterative(node);
                                    node.type = type;
                                    $$ = node;

                                    /** MODIFY AS APPROPRIATE **/
                                    
                                    if ($4.operation.equals("NONE")) {
                                        // update assembly here
                                        if (type.equals("INT")) {
                                            $4.assembly = $4.assembly.replace("P1", $2.token);
											assemblyData.add($4.assembly);
											
											int intReg = getIntRegister();
                                            $4.assembly = "lw $t" + intReg + ", " + $2.token;
											setRegister($2.token, String.valueOf(intReg));
											assemblyText.add($4.assembly);
							
                                        } else if (type.equals("FLOAT")) {
                                            $4.assembly = $4.assembly.replace("P1", $2.token);
                                            $4.assembly = $4.assembly.replace(".word", ".float");
											assemblyData.add($4.assembly);
											
											int floatReg = getFloatRegister();
											$4.assembly = "l.s $f" + floatReg + ", " + $2.token;
											setRegister($2.token, String.valueOf(floatReg));
											assemblyText.add($4.assembly);
											
                                        } else if (type.equals("STRING")) {
                                            $4.assembly = $4.assembly.replace("P1", $2.token);
											assemblyData.add($4.assembly);
                                        }
                                    } else if ($4.operation.equals("ADD")) {
                                        if (type.equals("INT")) {
											int intReg = getIntRegister();
                                            $4.assembly = $4.assembly.replace("$OUT", "$t" + intReg);
											setRegister($2.token, String.valueOf(intReg));
                                            String varName1 = $4.assembly.split(",")[1];
											varName1 = varName1.trim();
                                            String findReg1 = getRegister(varName1);
                                            $4.assembly = $4.assembly.replace(varName1, "$t" + findReg1);

                                            String varName2 = $4.assembly.split(",")[2];
											varName2 = varName2.trim();
                                            String findReg2 = getRegister(varName2);
                                            $4.assembly = $4.assembly.replace(varName2, "$t" + findReg2);
											assemblyText.add($4.assembly);
                                        } else if (type.equals("FLOAT")) {
											int floatReg = getFloatRegister();
											$4.assembly = $4.assembly.replace("$OUT", "$f" + floatReg);
											setRegister($2.token, String.valueOf(floatReg));
											$4.assembly = $4.assembly.replace("add", "zzz");
                                            String varName1 = $4.assembly.split(",")[1];
											varName1 = varName1.trim();
                                            String findReg1 =  getRegister(varName1);
                                            $4.assembly = $4.assembly.replace(varName1, "$f" + findReg1);

                                            String varName2 = $4.assembly.split(",")[2];
											varName2 = varName2.trim();
                                            String findReg2 = getRegister(varName2);
                                            $4.assembly = $4.assembly.replace(varName2, "$f" + findReg2);
											$4.assembly = $4.assembly.replace("zzz", "add.s");
											assemblyText.add($4.assembly);
                                        }
                                    } else if ($4.operation.equals("SUB"))	{
										if (type.equals("INT")) {
											int intReg = getIntRegister();
                                            $4.assembly = $4.assembly.replace("$OUT", "$t" + intReg);
											setRegister($2.token, String.valueOf(intReg));
                                            String varName1 = $4.assembly.split(",")[1];
											varName1 = varName1.trim();
                                            String findReg1 = getRegister(varName1);
                                            $4.assembly = $4.assembly.replace(varName1, findReg1);

                                            String varName2 = $4.assembly.split(",")[2];
											varName2 = varName2.trim();
                                            String findReg2 = getRegister(varName2);
                                            $4.assembly = $4.assembly.replace(varName2, findReg2);
											assemblyText.add($4.assembly);
											
                                        } else if (type.equals("FLOAT")) {
											int floatReg = getFloatRegister();
											$4.assembly = $4.assembly.replace("$OUT", "$f" + floatReg);
											setRegister($2.token, String.valueOf(floatReg));
                                            String varName1 = $4.assembly.split(",")[1];
											varName1 = varName1.trim();
                                            String findReg1 = getRegister(varName1);
                                            $4.assembly = $4.assembly.replace(varName1, findReg1);

                                            String varName2 = $4.assembly.split(",")[2];
											varName2 = varName2.trim();
                                            String findReg2 = getRegister(varName2);
                                            $4.assembly = $4.assembly.replace(varName2, findReg2);
											assemblyText.add($4.assembly);
										}
									}										
                                    //print the assembly code
                                    //System.out.println($4.assembly);

                                    if(isDeclaredLocally($2) && !canRetrieveSymbol($2)) { 
                                        yyerror("Duplicate variable: "+$2);
                                    } else { 
                                        enterSymbol($2, $4);
                                        saveTypeSymbol($2);
                                    } 
                                  }
        |   ID ASSIGN expr        { /*** YOUR CODE HERE ***/
                                    $$ = makeNode($2.token, $1, $3);
                                    if (!isDeclaredLocally($1) && !canRetrieveSymbol($1)) { 
                                            yyerror($1.token + " is not declared!");
                                        }
                                    }
        | PRINT OPEN_PAREN expr CLOSE_PAREN     
                                    {
                                        Node id = $3;
										String type = lookUpType(id.token);
										if (type.equals("STRING")) {
											String value = curSymbolTable.get(id.token);
											//assemblyData.add(id.token + ": .asciiz " + value );
											
											assemblyText.add("li $v0, 4");
											assemblyText.add("la $a0, " + id.token);
											
										} else if (type.equals("INT")) {
											assemblyText.add("li $v0, 1");
											assemblyText.add("move $a0, $t" + getRegister(id.token)); 
											
										} else if (type.equals("FLOAT")) {
											assemblyText.add("li $v0, 2");
											assemblyText.add("mov.s $f12, $f" + getRegister(id.token));

										}
										assemblyText.add("syscall");
									}
                                    
        ;

type    :    INT                    { $$ = $1; }
        |    STRING                 { $$ = $1; }
        |    FLOAT                  { $$ = $1; }
        ;

expr    :   expr PLUS expr          { Node node = makeNode("+", $1, $3); 
                                      node.operation = "ADD";
                                      node.assembly = "add $OUT, "  + $1.token + ", " + $3.token;
                                      $$ = node;
                                    }
        |   expr MINUS expr         { Node node = makeNode("-", $1, $3); 
                                      node.operation = "SUB";
                                      node.assembly = "sub $OUT, " + $1.token + ", " + $3.token;
                                      $$ = node;
                                    }
        |   ID                      {  
                                      $$ = $1;
                                        if (!isDeclaredLocally($1) && !canRetrieveSymbol($1)) { 
                                            yyerror($1.token + " is not declared!");
                                        }
                                    }
        |   NUM                     {
                                        Node node = $1;
                                        node.operation = "NONE";
                                        node.assembly = "P1: .word "+$1.token;
                                        $$ = node;
                                    }
        |   TEXT                    {
                                        Node node = $1;
                                        node.operation = "NONE";
                                        node.assembly = "P1: .asciiz "+$1.token;
                                        $$ = node;
                                    }
        ;

%%
	 
    int[] intRegisters = new int[8]; 
    int[] floatRegisters = new int[8];
	
	 // 0 means free
    // 1 means occupied
	public int getFloatRegister() {
		for (int i = 0; i<7; i++){
			if (floatRegisters[i] == 0){
				floatRegisters[i] = 1;
				return i;
			}
		}
		return 0;
	}	
	
	public void freeFloatRegister (int r) {
		floatRegisters[r] = 0;
		}

    public int getIntRegister() {
        for (int i = 0;i<7;i++) {
            if (intRegisters[i] == 0) {
                intRegisters[i] = 1; 
                return i;
            }
        }
        return 0;
    }
        
    public void freeIntRegister(int r) {
        intRegisters[r] = 0;
    }

    //maintain a table that maps IDENTIFIER to REGISTER USED.
	
	Map<String, String> registerTable = new HashMap<String, String>(); //key is id, value is reg used
	
	
    //implement appropriate methods to store the mapping 
    //and retrieve register for any given identifier from this table.
	
	public void setRegister(String id, String register) {
        registerTable.put(id, register);
    }
	
	public String getRegister(String id){
		String selectedValue = registerTable.get(id);
		return selectedValue;
		}
		

	

    //You will generate 2 sections of assembly: .data and .text
    //Store your assembly into appropriate section.
    //Choose any datastructure to store your assembly.
	
	List<String> assemblyData = new ArrayList<String>();
	List<String> assemblyText = new ArrayList<String>();
    
    public void printAssembly(){
		//call this at the end, to print out the final output
		System.out.println(".data");
        
		for (String printer : assemblyData){
		System.out.println(printer);
		}
		System.out.println(".text");
		
		for (String printer : assemblyText){
		System.out.println(printer);
		}
	}
		

    Stack<HashMap<String, String>> scopesStack = new Stack<HashMap<String, String>>();
	Stack<HashMap<String, String>> typesStack = new Stack<HashMap<String, String>>();
	
    HashMap<String, String> curSymbolTable = new HashMap<String, String>();
    HashMap<String, String> curTypeSymbolTable = new HashMap<String, String>();

    public void saveTypeSymbol(Node node) {
        curTypeSymbolTable.put(node.token, node.type);
    }

    public String postOrderIterative(Node root) {
        if( root == null ) {
            return "";
        }

        Stack<Node> s1 = new Stack<Node>();
        Stack<Node> s2 = new Stack<Node>();
     
        s1.push(root);
        Node node;
     
        while (!s1.isEmpty( )) {
            // Pop an item from s1 and push it to s2
            node = s1.pop();
            s2.push(node);
     
            // Push left and right children of removed item to s1
            if (node.left != null) {
                s1.push(node.left);        
            }
            if (node.right != null) {
                s1.push(node.right);     
            }
        }
     
        // Process all elements of second stack

        // Get the type of the variable at the top of stack
        String existingType = s2.peek().type;
        if (existingType == null) {
            existingType = lookUpType(s2.peek().token);
        }

        while (!s2.isEmpty()) {
            node = s2.pop();
            if (node.type == null && node.token.equals("=")) {
                //this should only happen when we are at the last entry of the stack
                //so we want to return the type "existingType"
                continue;
            }
            if (node.token.equals("+") || node.token.equals("-")) {
                node.type = existingType;
            }
            if (node.type == null) {
                //lookup type information from symbol table
                node.type = lookUpType(node.token);
            }
            if (!existingType.equals(node.type)) {
                yyerror("***TYPE MISMATCH*** "+node.type + " type found when expected: "+existingType + ", expr: "+printInOrder(root));
            }
        }
        return existingType;
    }

    public String printInOrder(Node root) {
        String out ="";
        if(root == null) {
            return out;
        }
        Stack<Node> stack = new Stack<Node>( );
        while( ! stack.isEmpty( ) || root != null ) {
            if( root != null ) {
            stack.push( root );
            root = root.left;
        } else {
            root = stack.pop( );
            out += root.token + " " ;
            root = root.right;
        }
        }
        return out;
    }


    public void pushScope() {
        scopesStack.push(curSymbolTable);
		typesStack.push(curTypeSymbolTable);
        curSymbolTable = new HashMap<String, String>();
		curTypeSymbolTable = new HashMap<String, String>();
    }

    public boolean canRetrieveSymbol(Node id) {
        Stack<HashMap<String,String>> tempStack = new Stack<HashMap<String,String>>();
        boolean isFound = false;
        while (!scopesStack.isEmpty()) {
            HashMap<String,String> tempSymTab = scopesStack.pop();
            tempStack.push(tempSymTab);
            if (tempSymTab.get(id.token) != null) {
                isFound = true;
                break;
            }
        }

        while (!tempStack.isEmpty()) {
            scopesStack.push(tempStack.pop());
        }
        
        return isFound;
    }

    private String lookUpType(String id) {
		//curTypeSymbolTable may not have been pushed into the stack yet, so check it first
		if (curTypeSymbolTable.get(id) != null) {
			return curTypeSymbolTable.get(id);
		}
		
        for(int i = typesStack.size() - 1; i >= 0; i--){
			HashMap<String,String> typeTable = typesStack.get(i);
			if (typeTable.get(id) != null) {
				return typeTable.get(id);
			}
        }
		return null;
    }

    public void exitScope(){
		typesStack.pop();
        scopesStack.pop();
    }

    
    public void enterSymbol(Node id, Node value) {
        curSymbolTable.put(id.token, value.token);
    }

    public boolean isDeclaredLocally(Node id) {
        if ((curSymbolTable).get(id.token) != null) {
            return true;
        }
        return false;
    }

    public void printSymbolTable() {
		for (HashMap<String,String> symTable : scopesStack) {
		    System.out.println("---printing symbol table---");
            for (Map.Entry<String, String> entry : symTable.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                System.out.println("K: " + key + " , V: " + value);
            }
		}
    }

    /* reference to the lexer object */
    private Scanner lexer;

    /* interface to the lexer */
    private int yylex() {
        int retVal = -1;
        try {
            retVal = lexer.yylex();
        } catch (IOException e) {
            System.err.println("IO Error:" + e);
        }
        return retVal;
    }
    
    /* error reporting */
    public void yyerror (String error) {
        System.err.println("Error : " + error + " at line " + lexer.getLine() + " column: " + lexer.getColumn());
        System.err.println("String rejected");
    }

    /* constructor taking in File Input */
    public Parser (Reader r) {
        lexer = new Scanner (r, this);
    }

    public static boolean isDebug = false;

    public static void main (String [] args) throws IOException {
        
        /*** DEBUG OPTION -d ***/

        int filePosition = 0;
        if (args[0].equals("-d")){
            isDebug = true;
            filePosition = 1;
        }

        Parser yyparser = new Parser(new FileReader(args[filePosition]));
        yyparser.yyparse();
    } 


    Node makeNode(String token, Node left, Node right) {
        Node newNode = new Node(token);
        newNode.left = left;
        newNode.right = right;
        return newNode;
    }

    void printTree(Node tree)
    {
        int i;

        if (tree.left!=null || tree.right!=null) {
            System.out.print("( ");
        }

        System.out.print(tree.token + " ");

        if (tree.left!=null) {
            printTree(tree.left);
        }
        if (tree.right!=null) {
            printTree(tree.right);
        }

        if (tree.left!=null || tree.right!=null) {
            System.out.print(")");
        }
    }


    public void printNode(Node root) {
        System.out.println("--------Structured View of Tree----------");
        int maxLevel = maxLevel(root);
        printNodeInternal(Collections.singletonList(root), 1, maxLevel);
    }

    private void printNodeInternal(List<Node> nodes, int level, int maxLevel) {
        if (nodes.isEmpty() || isAllElementsNull(nodes))
            return;

        int floor = maxLevel - level;
        int endgeLines = (int) Math.pow(2, (Math.max(floor - 1, 0)));
        int firstSpaces = (int) Math.pow(2, (floor)) - 1;
        int betweenSpaces = (int) Math.pow(2, (floor + 1)) - 1;

        printWhitespaces(firstSpaces);

        List<Node> newNodes = new ArrayList<Node>();
        for (Node node : nodes) {
            if (node != null) {
                System.out.print(node.token);
                newNodes.add(node.left);
                newNodes.add(node.right);
            } else {
                newNodes.add(null);
                newNodes.add(null);
                System.out.print(" ");
            }

            printWhitespaces(betweenSpaces);
        }
        System.out.println("");

        for (int i = 1; i <= endgeLines; i++) {
            for (int j = 0; j < nodes.size(); j++) {
                printWhitespaces(firstSpaces - i);
                if (nodes.get(j) == null) {
                    printWhitespaces(endgeLines + endgeLines + i + 1);
                    continue;
                }

                if (nodes.get(j).left != null)
                    System.out.print("/");
                else
                    printWhitespaces(1);

                printWhitespaces(i + i - 1);

                if (nodes.get(j).right != null)
                    System.out.print("\\");
                else
                    printWhitespaces(1);

                printWhitespaces(endgeLines + endgeLines - i);
            }

            System.out.println("");
        }

        printNodeInternal(newNodes, level + 1, maxLevel);
    }

    private void printWhitespaces(int count) {
        for (int i = 0; i < count; i++)
            System.out.print(" ");
    }

    private int maxLevel(Node node) {
        if (node == null)
            return 0;

        return Math.max(maxLevel(node.left), maxLevel(node.right)) + 1;
    }

    private boolean isAllElementsNull(List list) {
        for (Object object : list) {
            if (object != null)
                return false;
        }

        return true;
    }

