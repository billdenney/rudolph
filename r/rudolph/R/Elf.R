# Source the utils file
source('R/Utils.R')

#' An S4 class to represent Elf.
#'
#' @slot classPaths A list of character vectors of Java classpaths.
#' @slot destinationDirectory A character vector of an absolute path to the
#' directory where the generated and compiled files should be written to.
#' @slot grammarFiles A vector of absolute paths for .g4 grammar files.
#' file
#' @slot wunorse A Java object reference to an instance of
#' org.rudolph.elf.Wunorse.
#'
#' @export Elf
Elf <- setClass(
	"Elf",
	slots = list(
		classPaths           = "character",
		destinationDirectory = "character",
		grammarFiles         = "vector",
		wunorse              = "jobjRef"
	)
)

#' initialize
#'
#' Sets the working directory, initializes the JVM and Rudolph Java instance.
#' @param destinationDirectory A character vector of an absolute path to the
#' directory where the generated and compiled files should be written to.
#' @param grammarFiles A vector of absolute paths for .g4 grammar files.
#' @keywords init, initialize
#' @examples
#' \dontrun{
#' elf <- Elf(
#' 	destinationDirectory = "/absolute/path/to/destination",
#' 	grammarFiles         = c("/absolute/path/to/grammar.g4")
#' )
#' }
#'
#' @export
#' @importFrom rJava .jaddClassPath .jnew
#' @include Utils.R
setMethod(
	"initialize",
	"Elf",
	function(
		.Object,
		destinationDirectory = character(0),
		grammarFiles         = c()
	) {
		.Object@destinationDirectory = normalizePath(
			destinationDirectory,
			mustWork = TRUE
		)
		.Object@grammarFiles = normalizePath(
			grammarFiles,
			mustWork = TRUE
		)

		# Validate grammar file
		validateFile(.Object@grammarFiles)

		# Initialize the JVM
		initializeJVM()

		# Add destination directory and RudolphElf.jar to Java classpath
		.Object@classPaths <- c(
			.Object@destinationDirectory,
			system.file("java", "RudolphElf.jar", package = "rudolph")
		)
		rJava::.jaddClassPath(.Object@classPaths)

		.Object@wunorse <- rJava::.jnew("org.rudolph.elf.Wunorse")

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
#'
#' @export
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
#'
#' @export
#' @importFrom rJava .jcall .jarray
setGeneric(name = "generate", def = function(self) {
	standardGeneric("generate")
})
setMethod(
	"generate",
	"Elf",
	function(self) {
		rJava::.jcall(self@wunorse, "V", "main", rJava::.jarray(c(
			paste(self@grammarFiles, collapse = " "),
			"-o", self@destinationDirectory
		)))

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
#'
#' @export
setGeneric(name = "compile", def = function(self) {
	standardGeneric("compile")
})
setMethod(
	"compile",
	"Elf",
	function(self) {
		grammarFileWildMatch = paste0(
			parseGrammarNameFromFile(self@grammarFile), "*.java"
		)

		sourceFiles = file.path(
			self@destinationDirectory,
			grammarFileWildMatch
		)

		classPathArg = paste0(
			'"', paste0(self@classPaths, collapse = .Platform$path.sep), '"'
		)

		# system2 warning messages are not very useful
		result <- suppressWarnings(
			system2(
				"javac",
				args   = c("-cp", classPathArg, sourceFiles),
				stderr = TRUE,
				stdout = TRUE
			)
		)

		if (!identical(result, character(0)) && attr(result, "status") != 0) {
			stop(
				paste(
					getErrorInfo(result),
					paste(result, collapse = "\n"),
					sep = "\n"
				)
			)
		}

		print("Parser/lexer compilation complete")
	}
)
