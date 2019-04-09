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
#' Sets the working directory and initializes the JVM.
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

#' validateFile
#'
#' Checks to see if the file extension for given file is .g4 and that the file
#' exists.
setGeneric(name="validateFile", def=function(self) {
	standardGeneric("validateFile")
})
setMethod(
	"validateFile",
	"RudolphUtils",
	function(self) {
		# Validate file extension
		fileExtension = substr(
			self@grammarFile, 
			nchar(self@grammarFile) - 2,
			nchar(self@grammarFile)
		)
		if (fileExtension != '.g4') {
			stop("ANTLR grammar files must have a .g4 extension.")
		}
		
		# Validate file existence
		fileFound = FALSE
		absPath = paste(self@rootPackageDir, self@grammarFile, sep='/')
		
		if (file_test("-f", self@grammarFile)) {
			fileFound = TRUE
		}
		else if (file_test("-f", absPath)) {
			fileFound = TRUE
		}
		
		if (!fileFound) {
			stop(paste("File not found:", self@grammarFile, sep=" "))
		}
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
				match + attr(match, "match.length") - 4
			)
		)
	}
)
