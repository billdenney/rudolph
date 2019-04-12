# Rudolph
*Just because Rudolph's ANTLRs R stubby doesn't mean he can't shine the way*

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

## Generating Abstract Syntax Trees

```
library('rudolph')

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

rudolph <- Rudolph(
	grammarFile 	= grammarFilePath,
	rootNode 		= "root",
	sourceDirectory = getwd()
)
ast <- getAST(rudolph, "")
print(ast)
```

## Performing Grammar Rule Lookups

```
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
	sourceDirectory = getwd()
)
print(
	grammarLookup(rudolph, "root")
)

---
output: [1] "line+ EOF"

```

## Lookup in Raw Grammar File

```
library('rudolph')

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)

searchForGrammarRule(grammarFilePath, "emoticon")
```

## Only Generating Compiled Parser and Lexer ANTLR Files

```
library('rudolph')

grammarFilePath = system.file(
	"inst",
	"TestGrammar.g4",
	package = "rudolph"
)
elf <- Elf(
	# where to save the generated compiled parser/lexter files
	destinationDirectory = getwd(),
	grammarFile          = grammarFilePath
)
generate(elf)
compile(elf)

---
output:
> generate(elf)
[1] "Successfully created parser/lexer files in ~/YOUR/DIRECTORY"

> compile(elf)
[1] "Parser/lexer compilation complete"
```

Enjoy!