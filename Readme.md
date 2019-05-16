# Rudolph
> *Rudolph's ANTLRs R stubby, but it doesn't mean he can't light the way*

## Overview

Rudolph generates abstract syntax trees (ASTs) in R from compiled ANTLR
grammars.

The Rudolph package is a light wrapper around a simple implementation of the
ANTLR Java library. This package allows users to generate compiled ANTLR parsers
and lexers and process a file or character vector into an AST using the compiled
files. The AST is generated in the form of a nested R list and can be modified.
After modifications are complete, users can utilize a naive compose function to
turn the AST back into a character vector or file.

For more details on ANTLR, see <https://github.com/antlr/antlr4>.

This package provides 2 S4 classes: Elf and Rudolph. Elf is a helper class
responsible for generating and compiling parser and lexer files given a .g4
grammar file. Rudolph is the main class responsible for generating the AST and
composing the AST back to text.

The most common use of Rudolph is to supply a grammar file and input text using
precompiled ANTLR files. Below are working examples of Rudolph using
TestGrammar.g4 file available in the package (destination and source directories
aside).

The source code of the implementation of ANTLR library is included in
`r/rudolph/java` directory in accordance with [CRAN guidelines](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Non_002dR-scripts-in-packages). To recompile and
use with Rudolph, copy the resulting `.jar` file into `r/rudolph/inst/java` and
reload Rudolph.

## Requirements
* Java Development Kit 8+ (Java 12 currently not supported)
    * `java` and `javac` are both required
    * Ensure `JAVA_HOME` environment variable is set appropriately
    * Ensure `PATH` contains location(s) of `java` and `javac`
* R version 3.5+

## Installation
Rudolph is available on CRAN:
```r
install.packages("rudolph")
```

## Usage

### Generating Compiled Parser and Lexer ANTLR Files

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)
elf <- Elf(
	# where to save the generated compiled parser/lexer files
	destinationDirectory = "/SOME/DIRECTORY",
	grammarFile          = grammarFilePath
)
generateAndCompile(elf)
```

Output:
```
[1] "Successfully created parser/lexer files in /SOME/DIRECTORY"
[1] "Parser/lexer compilation complete"
```

### Generating Abstract Syntax Trees

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile     = grammarFilePath,
	rootNode        = "root",
	sourceDirectory = "/SOME/DIRECTORY"
)

ast <- getAST(rudolph, "santa SAYS: @rudolph with your nose so bright\n")

print(ast)
```

### Composing Text from AST

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile     = grammarFilePath,
	rootNode        = "root",
	# location of the compiled parser/lexer files
	sourceDirectory = "/SOME/DIRECTORY"
)

ast <- getAST(rudolph, "santa SAYS: @rudolph with your nose so bright\n")

# Modify the AST here

prettyPrint(rudolph, ast)
```

Output:
```
[1] "santa SAYS: @rudolph with your nose so bright\n"
```

### Validate AST

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile     = grammarFilePath,
	rootNode        = "root",
	# location of the compiled parser/lexer files
	sourceDirectory = "/SOME/DIRECTORY"
)

ast <- getAST(rudolph, "santa SAYS: @rudolph with your nose so bright\n")

# Modify the AST here

validateAST(rudolph, ast)
```

Output:
```
[1] TRUE
```

### Performing Grammar Rule Lookups

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile     = grammarFilePath,
	rootNode        = "root",
	# location of the compiled parser/lexer files
	sourceDirectory = "/SOME/DIRECTORY"
)

print(grammarLookup(rudolph, "root"))
```

Output:
```
[1] "line+ EOF"
```

### Lookup in Raw Grammar File

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

grammarLookup(grammarFilePath, "emoticon")
```

### Print grammar map

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile     = grammarFilePath,
	rootNode        = "root",
	# location of the compiled parser/lexer files
	sourceDirectory = "/SOME/DIRECTORY"
)

printGrammarMap(rudolph)
```

Output:
```
root       : line+ EOF
line       : name command message NEWLINE
message    : (emoticon | link | color | mention | WORD | WHITESPACE)+
name       : WORD WHITESPACE
command    : (SAYS | SHOUTS) ':' WHITESPACE
emoticon   : ':' '-'? ')' | ':' '-'? '('
link       : TEXT TEXT
color      : '/' WORD '/' message '/'
mention    : '@' WORD
a          : ('A'|'a')
s          : ('S'|'s')
y          : ('Y'|'y')
h          : ('H'|'h')
o          : ('O'|'o')
u          : ('U'|'u')
t          : ('T'|'t')
lowercase  : [a-z]
uppercase  : [A-Z]
says       : S A Y S
shouts     : S H O U T S
text       : ('['|'(') .*? (']'|')')
word       : (LOWERCASE | UPPERCASE | '_')+
whitespace : (' ' | '\t')+
newline    : ('\r'? '\n' | '\r')+
```

## Troubleshooting
### rJava fails to load
This is likely an issue with the `JAVA_HOME` and `PATH` environment variables.

In Windows environments, see [this reference](https://support.microsoft.com/en-us/help/3103813/qa-when-i-try-to-load-the-rjava-package-using-the-library-command-i-ge) for more troubleshooting steps.

In Unix-like environments, try running `sudo R CMD javareconf` if `JAVA_HOME`
and `PATH` are configured correctly.

Enjoy! 🦌
