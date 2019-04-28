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

## Requirements
+ Java Development Kit 8+
  + `java` and `javac` are both required
+ R version 3.5+

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
	grammarFile 	= grammarFilePath,
	rootNode 		= "root",
	sourceDirectory = "/SOME/DIRECTORY"
)

ast <- getAST(rudolph, "santa SAYS: @rudolph with your nose so bright\n")

print(ast)
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
	grammarFile 	= grammarFilePath,
	rootNode 		= "root",
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

### Composing Text from AST

```r
library("rudolph")

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile 	= grammarFilePath,
	rootNode 		= "root",
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

Enjoy! 🦌
