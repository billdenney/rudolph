options(java.parameters = c('-Xmx500M'))
library('rJava')

#' initializeJVM
#' 
#' Sets the working directory and initializes the JVM.
initializeJVM <- function(workingDirectory) {
	# Set the working directory so the jars work properly
	setwd(workingDirectory)

	# Initialize the JVM
	.jpackage("rudolph", lib.loc=find.package("rudolph"))
}

#' validateFile
#'
#' Checks to see if the file extension for given file is .g4 and that the file
#' exists.
validateFile <- function(grammarFile) {
	# Validate file extension
	fileExtension = substr(
		grammarFile, 
		nchar(grammarFile) - 2,
		nchar(grammarFile)
	)
	if (fileExtension != '.g4') {
		stop("ANTLR grammar files must have a .g4 extension.")
	}
		
	# Validate file existence
	fileFound = FALSE
	if (file_test("-f", grammarFile)) {
		fileFound = TRUE
	}
		
	if (!fileFound) {
		stop(paste("File not found:", grammarFile, sep=" "))
	}
}

#' parseGrammarNameFromFile
#'
#' Given a file path, parse out the name of the grammar.
parseGrammarNameFromFile <- function(grammarFile) {
	match = regexpr("([A-Za-z0-9]*)\\.g4", grammarFile, perl = TRUE)

	return (
		substr(
			grammarFile, 
			match, 
			match + attr(match, "match.length") - 4
		)
	)
}
