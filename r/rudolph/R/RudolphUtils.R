options(java.parameters = c('-Xmx500M'))
library('rJava')

RudolphUtils <- setClass(
	"RudolphUtils", 
	slots = list(
		grammarFile="character",
		rootPackageDir="character"
	)
)
#' initializeJVM
#' 
#' initializes the JVM
setGeneric(name="initializeJVM", def=function(self, workingDirectory) {
	standardGeneric("initializeJVM")
})
setMethod(
	"initializeJVM",
	"RudolphUtils",
	function(self, workingDirectory) {
		setwd(workingDirectory)
		# Initialize the JVM
		.jpackage("rudolph", lib.loc=find.package("rudolph"))
		return(self)
	}
)

#' validateFileInput
#'
#' Checks to see if the file extension for inputted grammar is '.g4'
#' and that the file path supplied exists 
setGeneric(name="validateFileInput", def=function(self) {
	standardGeneric("validateFileInput")
})
setMethod(
	"validateFileInput",
	"RudolphUtils",
	function(self) {
		validateG4Extension(self)
		validateFileExists(self)
	}
)
#' parseGrammarNameFromFile
#'
#' from a filepath, parse out the name of the grammar /inst/Chat.g4 would return Chat
setGeneric(name="parseGrammarNameFromFile", def=function(self) {
	standardGeneric("parseGrammarNameFromFile")
})
setMethod(
	"parseGrammarNameFromFile",
	"RudolphUtils",
	function(self) {
		match = regexpr("([A-Za-z0-9]*)\\.g4", self@grammarFile, perl=TRUE)
		return (
			substr(
				self@grammarFile, 
				match, 
				match+attr(match,"match.length")-4
			)
		)
	}
)

#' validateG4Extension
#'
#' Checks to see if the file extension for parameter grammarFile is '.g4'
setGeneric(name="validateG4Extension", def=function(self) {
	standardGeneric("validateG4Extension")
})
setMethod(
	"validateG4Extension",
	"RudolphUtils",
	function(self) {
		fileExtension = substr(
			self@grammarFile, 
			nchar(self@grammarFile) - 2,
			nchar(self@grammarFile)
		)
		if (fileExtension != '.g4') {
			stop(paste(
				"antlr grammar files must have a .g4 extension. You supplied a '", 
				fileExtension,
				"'"
			)
			)
		}
	}
)

#' validateFileExists
#'
#' Checks to see if the file path listed in the parameter grammarFile exists
setGeneric(name="validateFileExists", def=function(self) {
	standardGeneric("validateFileExists")
})
setMethod(
	"validateFileExists",
	"RudolphUtils",
	function(self) {
		fileFound = FALSE
		absPath = paste(self@rootPackageDir, self@grammarFile, sep='/')

		if (file_test("-f", self@grammarFile)) {
			fileFound = TRUE
		}
		else if (file_test("-f", absPath)) {
			fileFound = TRUE
		}

		if (!fileFound) {
			stop(paste("could not find file: ", self@grammarFile, sep=''))
		}
	}
)
