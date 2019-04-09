source('R/RudolphUtils.R')

#' An S4 class to represent Elf.
#' 
#' @slot classPaths A list of character vectors of Java classpaths.
#' @slot destinationDirectory A character vector of an absolute path to the
#' directory where the generated and compiled files should be written to.
#' @slot grammarFile A character vector of an absolute path to a .g4 grammar
#' file.
#' @slot wunorse A Java object reference to an instance of
#' org.rudolph.elf.Wunorse.
Elf <- setClass(
	"Elf", 
	slots = list(
		classPaths           = "character",
		destinationDirectory = "character",
		wunorse              = "jobjRef"
	),
	contains = "RudolphUtils"
)

#' initialize
#'
#' Sets the working directory, initializes the JVM and Rudolph Java instance.
#' @param destinationDirectory A character vector of an absolute path to the
#' directory where the generated and compiled files should be written to.
#' @param grammarFile A character vector of an absolute path to a .g4 grammar
#' file.
#' @keywords init, initialize
#' @examples
#' \dontrun{
#' elf <- Elf(
#' 	destinationDirectory = "/absolute/path/to/destination",
#' 	grammarFile          = "/absolute/path/to/grammar.g4"
#' )
#' }
setMethod(
	"initialize", 
	"Elf",
	function(
		.Object,
		destinationDirectory = character(0),
		grammarFile          = character(0)
	) {
		.Object@destinationDirectory = destinationDirectory
		.Object@grammarFile          = grammarFile

		validateFile(.Object)
		
		initializeJVM(.Object, workingDirectory = destinationDirectory)

		# add RudolphElf.jar to CLASSPATH
		.Object@classPaths <- c(
			destinationDirectory,
			system.file("inst/java", "RudolphElf.jar", package = "rudolph")
		)
		.jaddClassPath(.Object@classPaths)
		
		# wunorse is our light wrapper around antlr
		# it prevents antlr from crashing on import
		.Object@wunorse <- .jnew("org.rudolph.elf.Wunorse")
		
		return(.Object)
	}
)

#' generateAndCompile
#'
#' Generates and compiles parser/lexer Java files using ANTLR and \code{javac}.
#' 
#' @return Not meaningful.
#' @examples
#' \dontrun{
#' generateAndCompile(elf)
#' }
setGeneric(name = "generateAndCompile", def = function(self) {
	standardGeneric("generateAndCompile")
})
setMethod(
	"generateAndCompile",
	"Elf",
	function(self) {
		generate(self)
		compile(self)
	}
)

#' generate
#'
#' Generates parser/lexer Java files using ANTLR.
#' 
#' @return Not meaningful.
#' @examples
#' \dontrun{
#' generate(elf)
#' }
setGeneric(name = "generate", def = function(self) {
	standardGeneric("generate")
})
setMethod(
	"generate",
	"Elf",
	function(self) {
		.jcall(
			self@wunorse,
			"V", "main",
			.jarray(c(
				self@grammarFile,
				"-o", self@destinationDirectory
			))
		)
		
		print(paste(
			"Successfully created parser/lexer files in", 
			self@destinationDirectory,
			sep = " "
		))
	}
)

#' compile
#'
#' Compiles generated parser/lexer Java files using \code{javac}.
#' 
#' @return Not meaningful.
#' @examples
#' \dontrun{
#' compile(elf)
#' }
setGeneric(name = "compile", def = function(self) {
	standardGeneric("compile")
})
setMethod(
	"compile",
	"Elf",
	function(self) {
		grammarFileWildMatch = paste(
			parseGrammarNameFromFile(self), "*.java",
			sep = ""
		)
		sourceFiles = paste(
			self@destinationDirectory, grammarFileWildMatch,
			sep = "/"
		)
		classPathArg = paste(
			"'", paste(self@classPaths, collapse = ":"), "'",
			sep = ""
		)
		
		system(paste("javac", "-cp", classPathArg, sourceFiles, sep = " "))
		
		print("Parser/lexer compilation complete")
	}
)
