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
#' rudolph <- Rudolph(grammarFile="inst/Chat.g4", rootNode='chat')
#' ast <- getAST(rudolph, 'hi my name is')
#' rudolph <- .jnew('org.rudolph.rudolph.Rudolph', c('Chat', 'chat'))
Rudolph <- setClass(
	"Rudolph",
	slots = list(
		grammarName="character",
		grammarFile="character",
		rootNode="character",
		antlrFilePath="character",
		jarClassPath="character",
		rudolph="jobjRef"
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
#' chat <- Rudolph(grammarFile="inst/Chat.g4")
setMethod(
	"initialize",
	"Rudolph",
	function(.Object, grammarFile=character(0), rootNode=character(0)) {
		.Object <- callNextMethod()

		.Object@rootPackageDir = getRootPackageDir(.Object)
		.Object@grammarFile = paste(.Object@rootPackageDir, grammarFile, sep="/")
		.Object@rootNode = rootNode

		validateFileInput(.Object)
		
		# importing rudolph antlr wrapper
		.Object@jarClassPath <- system.file(
			"inst",
			"Rudolph.jar",
			package="rudolph"
		)
		.jaddClassPath(c(paste(.Object@rootPackageDir, "inst", sep="/"), .Object@jarClassPath))

		grammarName = parseGrammarNameFromFile(.Object)
		browser()

		.Object@rudolph <- .jnew(
			'org.rudolph.rudolph.Rudolph',
			c(grammarName, .Object@rootNode)
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
		grammar_json = .jcall(self@rudolph, 'S', 'getGrammar')
		return(parse_json(grammar_json))
	}
)