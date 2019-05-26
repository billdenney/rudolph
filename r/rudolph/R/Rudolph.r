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
#' 	name  = "grammar rule name",
#' 	value = list(
#' 		list(
#' 			name  = "grammar rule name 1",
#' 			value = "grammar rule matched text 1"
#' 		),
#' 		list(
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

#' An S4 class to represent an instance of Rudolph.
#'
#' @slot grammarFiles A vector of absolute paths for .g4 grammar files.
#' @slot rootNode A character vector of the root node of the grammar.
#' @slot rudolph A Java object reference to an instance of
#' org.rudolph.rudolph.Rudolph.
#' @slot sourceDirectory A character vector of an absolute path to the directory
#' the containing the compiled grammar files.
#' @slot lexerName A character vector of the lexer file name. If a parserName is
#' not seperately supplied, it is assumed that the parserName is the same as the
#' lexer name.
#' @slot parserName A character vector of the parser file name. not required.
#'
#' @export Rudolph
Rudolph <- setClass(
	"Rudolph",
	slots = list(
		grammarFiles    = "character",
		grammarMap      = "list",
		rootNode        = "character",
		rudolph         = "jobjRef",
		sourceDirectory = "character",
		lexerName       = "character",
		parserName      = "character"
	)
)

#' initialize
#'
#' Sets the working directory, initializes the JVM and Rudolph Java instance.
#' @param grammarFiles list of file paths to .g4 grammar file. Must be an
#' absolute path.
#' @param rootNode Root node of the grammar, informs ANTLR where the grammar
#' rules begin.
#' @param sourceDirectory Path to source files. Source files are compiled Java
#' classes generated by ANTLR (or Elf). Must be an absolute path.
#' @param lexerName A character vector of the lexer file name. If a parserName is
#' not seperately supplied, it is assumed that the parserName is the same as the
#' lexer name.
#' @param parserName A character vector of the parser file name. not required.
#' @keywords init, initialize
#' @examples
#' \dontrun{
#' rudolph <- Rudolph(
#' 	grammarFiles     = c("/absolute/path/to/grammar.g4"),
#' 	rootNode        = "grammarroot",
#' 	sourceDirectory = "/absolute/path/to/source",
#' 	lexerName       = "grammar"
#' )
#' }
#'
#' @export
#' @importFrom rJava .jaddClassPath .jnew
#' @include Utils.R
setMethod(
	"initialize",
	"Rudolph",
	function(
		.Object,
		grammarFiles    = c(),
		rootNode        = character(0),
		sourceDirectory = character(0),
		lexerName       = character(0),
		parserName      = character(0)
	) {
		.Object@grammarFiles = normalizePath(grammarFiles, mustWork = TRUE)

		# Validate grammar file
		validateFile(.Object@grammarFiles)

		# Create map of grammar file
		.Object@grammarMap = parseGrammarMap(
			.Object@grammarFiles
		)

		# Initialize the JVM
		initializeJVM()

		# Add source directory and Rudolph.jar to Java classpath
		rJava::.jaddClassPath(c(
			normalizePath(sourceDirectory, mustWork = TRUE),
			system.file("java", "Rudolph.jar", package = "rudolph")
		))

		# Create Rudolph Java instance
		.Object@rudolph <- rJava::.jnew(
			'org.rudolph.rudolph.Rudolph',
			c(rootNode, lexerName, parserName)
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
#'
#' @export
#' @importFrom readr read_file
#' @importFrom rJava .jcall
#' @importFrom jsonlite parse_json
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
			input <- readr::read_file(file)
		}
		else {
			input <- text
		}

		return(
			jsonlite::parse_json(
				rJava::.jcall(self@rudolph, returnSig = "S", "process", input)
			)
		)
	}
)

#' validateAST
#'
#' Validates an AST in a basic way. Checks if AST only contains defined grammar
#' rules in the instance grammar file. Does not check for grammar rule
#' relationships.
#'
#' @return A logical vector. TRUE if the supplied AST only contains grammar
#' rules defined in the grammar file, FALSE otherwise.
#' \dontrun{
#' validateAST(rudolph, ast)
#' }
#'
#' @export
setGeneric(name = "validateAST", def = function(self, ast) {
	standardGeneric("validateAST")
})
setMethod(
	"validateAST",
	"Rudolph",
	function(self, ast) {
		if (missing(ast)) {
			stop("Must specify ast.")
		}

		if (
			is.null(self@grammarMap[[names(ast)[1]]])
			&& is.null(ast[["text"]])
		) {
			return(FALSE)
		}

		if (!is.atomic(ast[[names(ast)[1]]])) {
			for (node in ast[[names(ast)[1]]]) {
				if (!validateAST(self, node)) {
					return(FALSE)
				}
			}
		}

		return(TRUE)
	}
)

#' prettyPrint
#'
#' Takes an abstract syntax tree (AST) and naively composes a character vector
#' from the contents. Optionally outputs generated character vector to a named
#' file.
#'
#' @param ast A nested list representing an AST.
#' @param file Character vector containing file name
#' @return A character vector representating composed data from the AST, or NULL
#' if \code{file} is specified.
#' \dontrun{
#' prettyPrint(rudolph, ast, file = "output.txt")
#' }
#'
#' @export
#' @importFrom readr write_file
setGeneric(name = "prettyPrint", def = function(self, ast, file) {
	standardGeneric("prettyPrint")
})
setMethod(
	"prettyPrint",
	"Rudolph",
	function(self, ast, file) {
		if (missing(ast)) {
			stop("Must specify ast.")
		}

		output <- character(0)
		if (!is.null(ast[["text"]]) && is.atomic(ast[["text"]])) {
			if (!grepl("<EOF>", ast[["text"]])) {
				output <- ast[["text"]]
			}
		}
		else {
			for (node in ast[[names(ast)[1]]]) {
				output <- paste0(output, prettyPrint(self, node))
			}
		}

		if (missing(file)) {
			return(output)
		}
		else {
			readr::write_file(output, file)
			return(NULL)
		}
	}
)

#' grammarLookup
#'
#' Performs a lookup in the grammar file supplied at initialization. For a given
#' rule, returns the definition.
#'
#' @param ruleName Character vector containing name of grammar rule.
#' @return A character vector representating a grammar definition (lexer or
#' parser).
#' \dontrun{
#' grammarLookup(rudolph, "emoticon")
#' }
#'
#' @export
setGeneric(name = "grammarLookup", def = function(self, ruleName) {
	standardGeneric("grammarLookup")
})
setMethod(
	"grammarLookup",
	"Rudolph",
	function(self, ruleName) {
		definition = self@grammarMap[[ruleName]]

		if (is.null(definition)) {
			message = paste(
				ruleName,
				"not found in grammar:",
				paste(self@grammarFiles, collapse = ", ")
			)
			stop(message)
		}
		else {
			return(definition)
		}
	}
)

#' getGrammarMap
#'
#' Returns a named list parsed from the grammar file supplied at initialization.
#'
#' @return A named list. Rule names are the keys and the values are the
#' definitions.
#' \dontrun{
#' getGrammarMap(rudolph)
#' }
#'
#' @export
setGeneric(name = "getGrammarMap", def = function(self) {
	standardGeneric("getGrammarMap")
})
setMethod(
	"getGrammarMap",
	"Rudolph",
	function(self) {
		return(self@grammarMap)
	}
)

#' printGrammarMap
#'
#' Prints a named list parsed from the grammar file supplied at initialization.
#'
#' \dontrun{
#' printGrammarMap(rudolph)
#' }
#'
#' @export
#' @importFrom stringr str_pad
setGeneric(name = "printGrammarMap", def = function(self) {
	standardGeneric("printGrammarMap")
})
setMethod(
	"printGrammarMap",
	"Rudolph",
	function(self) {
		maxName <- max(nchar(names(self@grammarMap)))

		for (name in names(self@grammarMap)) {
			cat(
				sprintf(
					"%s : %s",
					stringr::str_pad(name, maxName, side = "right"),
					self@grammarMap[[name]]
				),
				sep = "\n"
			)
		}

		invisible(self@grammarMap)
	}
)
