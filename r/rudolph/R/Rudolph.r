source('R/RudolphUtils.R')

library('jsonlite')

#' Rudolph
#'
#' Rudolph is the api that allows users to work with an antlr abstract syntax
#' tree in R.
#' @param grammarFile
#' @param rootNode
#' @keywords init, initialize
#' @export
#' @examples
#' rudolph <- Rudolph(
#' 	grammarFile     = "/absolute/path/to/grammar.g4",
#' 	rootNode        = "grammarroot",
#' 	sourceDirectory = "/absolute/path"
#' )
#' ast <- getAST(rudolph, "hi my name is")
Rudolph <- setClass(
	"Rudolph",
	slots = list(
		grammarFile     = "character",
		rootNode        = "character",
		rudolph         = "jobjRef",
		sourceDirectory = "character"
	),
	contains='RudolphUtils'
)

#' Initialization Function
#'
#' Sets the antlr grammar file. Initializes the the java environment.
#' @param grammarFile .g4 grammar file path. The file path is relative to the current working
#' directory of the user.
#' @keywords init, initialize
#' @export
#' @examples
#' rudolph <- Rudolph(
#' 	grammarFile     = "/absolute/path/to/grammar.g4",
#' 	rootNode        = "grammarroot",
#' 	sourceDirectory = "/absolute/path"
#' )
setMethod(
	"initialize",
	"Rudolph",
	function(
		.Object,
		grammarFile     = character(0),
		rootNode        = character(0),
		sourceDirectory = character(0)
	) {
		# initialize the java virtual machine
		initializeJVM(.Object, workingDirectory = sourceDirectory)
		
		# add Rudolph.jar to CLASSPATH
		.jaddClassPath(c(
			sourceDirectory,
			system.file("inst/java", "Rudolph.jar", package = "rudolph")
		))
		
		# check if grammar file exists
		.Object@grammarFile = grammarFile
		validateFileInput(.Object)
		
		grammarName = parseGrammarNameFromFile(.Object)

		.Object@rudolph <- .jnew(
			'org.rudolph.rudolph.Rudolph',
			c(grammarName, rootNode)
		)

		return(.Object)
	}
)

#' getAST
#'
#' creates an abstract syntax tree (AST) from a grammar. The AST returned is a
#' nested list
setGeneric(name="getAST", def=function(self, inputText) {
	standardGeneric("getAST")
})
setMethod(
	"getAST",
	"Rudolph",
	function(self, inputText) {
		ast_json = .jcall(self@rudolph, 'S', 'process', inputText)
		return(parse_json(ast_json))
	}
)

#' getGrammar
#'
#' returns the rules of provided grammar. The grammar is returned in
#' list format
setGeneric(name="getGrammar", def=function(self) {
	standardGeneric("getGrammar")
})
setMethod(
	"getGrammar",
	"Rudolph",
	function(self) {
		return()
	}
)
