# Rudolph
> *Rudolph's ANTLRs R stubby, but it doesn't mean he can't shine the way*

## Overview

Rudolph generates abstract syntax trees (ASTs) in R from compiled ANTLR
grammars.

The Rudolph package is a light wrapper around a simple implementation of the
ANTLR Java library. This package allows users to generate compiled ANTLR parsers
and lexers and process a character vector into an AST using the compiled files.

For more details on ANTLR, see <https://github.com/antlr/antlr4>.

This package provides 2 S4 classes: Elf and Rudolph. Elf is a helper class
responsible for generating and compiling parser and lexer files given a .g4
grammar file. Rudolph is the main class responsible for generating the AST given
a character vector and the compiled parser and lexer files.

The most common use of Rudolph is to supply a grammar file and input text.
Please find working examples for the three most common use cases of Rudolph.
Each example uses the TestGrammar.g4 file available in the package.

## Usage

### Generating Abstract Syntax Trees

```r
library('rudolph')

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
ast <- getAST(rudolph, "john SAYS: hello @michael will this work\n")
print(ast)
```

### Performing Grammar Rule Lookups

```r
library('rudolph')

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
print(
	grammarLookup(rudolph, "root")
)
```

Output:
```
[1] "line+ EOF"
```

## Lookup in Raw Grammar File

```r
library('rudolph')

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

grammarLookup(grammarFilePath, "emoticon")
```

## Only Generating Compiled Parser and Lexer ANTLR Files

```r
library('rudolph')

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

Enjoy! 🦌
