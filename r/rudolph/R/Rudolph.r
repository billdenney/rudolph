#' Rudolph: A package for generating abstract syntax trees (ASTs) from compiled
#' ANTLR grammar.
#'
#' The Rudolph package is a light wrapper around a simple implementation of the
#' ANTLR Java library. This package allows users to generate compiled ANTLR
#' parsers and lexers and process a character vector into an AST using the
#' compiled files.
#'
#' For more details on ANTLR, see \url{https://github.com/antlr/antlr4}.
#'
#' @section Classes:
#' This package provides 2 S4 classes: Elf and Rudolph. Elf is a helper class
#' responsible for generating and compiling parser and lexer files given a .g4
#' grammar file. Rudolph is the main class responsible for generating the AST
#' given a character vector and the compiled parser and lexer files.
#'
#' Most use cases will not require the use of Elf. However, if using both Elf
#' and Rudolph, both should be given the same grammar file. The generated
#' compiled files in the destination directory in Elf should also be the same
#' files contained in the source directory in Rudolph.
#'
#' Note that due to the relationship between JVMs and working directories, the
#' working directory will be set to the given directory in either constructor.
#'
#' @section Elf functions:
#' Elf     : Initialization function. Takes in a .g4 grammar file and a
#' destination directory.
#'
#' generate: Generates the parser and lexer Java files.
#'
#' compile : Compiles the parser and lexer Java files.
#'
#' @section Rudolph functions:
#' Rudolph      : Initialization function. Takes in a .g4 grammar file, a source
#' directory, and a root node of the grammar.
#'
#' getAST       : Given a character vector, returns an AST in nested list
#' format.
#'
#' grammarLookup: Given a grammar rule, returns the grammar rule definition.
#'
#' @section AST format:
#' The generated AST will be in the following format:
#' @examples
#' \dontrun{
#' ast <- list(
#' 	type  = "parser",
#' 	name  = "grammar rule name",
#' 	value = list(
#' 		list(
#' 			type  = "lexer",
#' 			name  = "grammar rule name 1",
#' 			value = "grammar rule matched text 1"
#' 		),
#' 		list(
#' 			type  = "lexer",
#' 			name  = "grammar rule name 2",
#' 			value = "grammar rule matched text 2"
#' 		),
#' 	)
#' )
#' }
#'
#' @docType package
#' @name Rudolph
NULL

library('jsonlite')
library('readr')

# Source the utils file
source('R/Utils.R')

#' An S4 class to represent an instance of Rudolph.
#'
#' @slot grammarFile A character vector of an absolute path to a .g4 grammar
#' file.
#' @slot rootNode A character vector of the root node of the grammar.
#' @slot rudolph A Java object reference to an instance of
#' org.rudolph.rudolph.Rudolph.
#' @slot sourceDirectory A character vector of an absolute path to the directory
#' the containing the compiled grammar files.
Rudolph <- setClass(
	"Rudolph",
	slots = list(
		grammarFile     = "character",
		rootNode        = "character",
		rudolph         = "jobjRef",
		sourceDirectory = "character"
	)
)

#' initialize
#'
#' Sets the working directory, initializes the JVM and Rudolph Java instance.
#' @param grammarFile File path to .g4 grammar file. Must be an absolute path.
#' @param rootNode Root node of the grammar, informs ANTLR where the grammar
#' rules begin.
#' @param sourceDirectory Path to source files. Source files are compiled Java
#' classes generated by ANTLR (or Elf). Must be an absolute path.
#' @keywords init, initialize
#' @examples
#' \dontrun{
#' rudolph <- Rudolph(
#' 	grammarFile     = "/absolute/path/to/grammar.g4",
#' 	rootNode        = "grammarroot",
#' 	sourceDirectory = "/absolute/path/to/source"
#' )
#' }
setMethod(
	"initialize",
	"Rudolph",
	function(
		.Object,
		grammarFile     = character(0),
		rootNode        = character(0),
		sourceDirectory = character(0)
	) {
		.Object@grammarFile = normalizePath(grammarFile, mustWork = TRUE)

		# Validate grammar file
		validateFile(.Object@grammarFile)

		# Initialize the JVM
		initializeJVM()

		# Add source directory and Rudolph.jar to Java classpath
		.jaddClassPath(c(
			normalizePath(sourceDirectory, mustWork = TRUE),
			system.file("inst/java", "Rudolph.jar", package = "rudolph")
		))

		# Parse out the grammar name
		grammarName = parseGrammarNameFromFile(.Object@grammarFile)

		# Create Rudolph Java instance
		.Object@rudolph <- .jnew(
			'org.rudolph.rudolph.Rudolph',
			c(grammarName, rootNode)
		)

		return(.Object)
	}
)

#' getAST
#'
#' Generates an abstract syntax tree (AST) from a grammar. The AST returned is a
#' nested list. Only one of \code{text} or \code{file} should be specified.
#'
#' @param text Character vector containing text to be parsed into an AST.
#' @param file Character vector containing file name, contents of which to be
#' parsed into an AST.
#' @return A nested list representing \code{text} or contents of \code{file}
#' parsed into an AST.
#' @examples
#' \dontrun{
#' ast <- getAST(rudolph, "text to be parsed")
#' }
setGeneric(name = "getAST", def = function(self, text, file) {
	standardGeneric("getAST")
})
setMethod(
	"getAST",
	"Rudolph",
	function(self, text, file) {
		if (missing(text) && missing(file)) {
			stop("Must specify text or file.")
		}
		else if (!(missing(text) || missing(file))) {
			stop("Either text or file should be specified, not both.")
		}
		else if (!missing(file)) {
			input <- read_file(file)
		}
		else {
			input <- text
		}

		return(
			parse_json(
				.jcall(self@rudolph, returnSig = "S", "process", input)
			)
		)
	}
)

#' grammarLookup
#'
#' Performs a lookup in the grammar file supplied at initialization. For a given
#' rule, returns the definition.
#' @param ruleName Character vector containing name of grammar rule.
#' @return A string representating a grammar definition (lexer or parser)
#' \dontrun{
#' grammarLookup(rudolph, "emoticon")
#' }
setGeneric(name = "grammarLookup", def = function(self, ruleName) {
	standardGeneric("grammarLookup")
})
setMethod(
	"grammarLookup",
	"Rudolph",
	function(self, ruleName) {
		searchForGrammarRule(self@grammarFile, ruleName)
	}
)
