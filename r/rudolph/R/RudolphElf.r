source('R/RudolphUtils.R')

#' RudolphElf
#'
#' RudolphElf is the workhorse of this antlr adapter package for R. RudolphElf
#' expects a .g4 grammar file and then generates the neccesary parser, lexer, and token files
#' antlr needs to run. It acts in the same way as the antlr4 command line tool: 
#' `antlr4 <grammar-file-g4>`. The antlr files are created in the user's current
#' working directory in the file `inst/`
#' @param grammarFile 
#' @keywords init, initialize
#' @export
#' @examples
#' chat <- RudolphElf(grammarFile="/absolute/path/to/Chat.g4")
RudolphElf <- setClass(
	"RudolphElf", 
	slots = list(
		classPaths           = "character",
		destinationDirectory = "character"
	),
	contains = "RudolphUtils"
)

#' Initialization Function
#'
#' Sets the antlr grammar file. Initializes the the java environment.
#' @param grammarFile .g4 grammar file path. The file path is relative to the current working
#' directory of the user.
#' @keywords init, initialize
#' @export
#' @examples
#' chat <- RudolphElf(grammarFile="/absolute/path/to/Chat.g4")
setMethod(
	"initialize", 
	"RudolphElf",
	function(
		.Object,
		destinationDirectory = character(0),
		grammarFile          = character(0)
	) {
		.Object@destinationDirectory = destinationDirectory
		.Object@grammarFile          = grammarFile

		validateFileInput(.Object)
		
		initializeJVM(.Object, workingDirectory = destinationDirectory)

		# add RudolphElf.jar to CLASSPATH
		.Object@classPaths <- c(
			destinationDirectory,
			system.file("inst/java", "RudolphElf.jar", package = "rudolph")
		)
		.jaddClassPath(.Object@classPaths)
		
		# wunorse is our light wrapper around antlr
		# it prevents antlr from crashing on import
		wunorse <- .jnew("org.rudolph.elf.Wunorse")
		
		.jcall(
			wunorse,
			"V",
			"main",
			.jarray(c(
				.Object@grammarFile,
				"-o", destinationDirectory
			))
		)
		
		print(paste(
			"successfully created parser/lexer files in", 
			destinationDirectory,
			sep = " "
		))
		
		return(.Object)
	}
)

#' compile
#'
#' compiles antlr java files
setGeneric(name = "compile", def = function(self) {
	standardGeneric("compile")
})
setMethod(
	"compile",
	"RudolphElf",
	function(self) {
		grammarName          = parseGrammarNameFromFile(self)
		grammarFileWildMatch = paste(grammarName, "*.java", sep = "")
		sourceFiles          = paste(self@destinationDirectory, grammarFileWildMatch, sep = "/")
		classPathArg         = paste("'", paste(self@classPaths, collapse = ":"), "'", sep = "")

		system(paste("javac", "-cp", classPathArg, sourceFiles, sep = " "))

		print("done parser/lexer compilation")
	}
)
