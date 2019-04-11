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
	match = regexpr("(\\w+)\\.g4", grammarFile, perl = TRUE)

	return (
		substr(
			grammarFile, 
			match, 
			match + attr(match, "match.length") - 4
		)
	)
}

# returns string w/o leading or trailing whitespace
trim <- function(x) { gsub("^\\s+|\\s+$", "", x) }

# remove inline comments from every line
stripInlineComments <- function(line) {
    inlineCommentRegex = "\\s*[\\/]{2}.*$"
    match = regexpr(
            inlineCommentRegex,
            line, 
            perl = TRUE
    )
    matchStart = match[1]
    
    if (matchStart == -1) {
        return(line)
    }
    
    # need to seperately handle the case where the inline comment starts the
    # line. substr(line, 1, 1) still returns the first character. Must 
    # explicitly return whitespace
    else if (matchStart == 1) {
        return("")
    }
    else {
        return(
            
            # strip from the start of the comment to the end of the line
            substr(
                line,
                1, # R index starts at 1
                matchStart
            )
        )
    }
}

# returns the specified capture group for a given regex pattern and
# input string. Returns NULL if match not found
getCaptureGroup <- function(r, s, group_number) {
    matches = regmatches(
        s,
        gregexpr(r, s, perl = TRUE)
    )
    if (length(matches) == 0) {
        return(NULL)
    }
    value = gsub(
        r, 
        paste("\\", group_number, sep = ""), 
        matches[[1]],
        perl = TRUE
    )
    if (identical(value, character(0))) {
        return(NULL)
    }
    else {
        return(value)
    }
}

# If the supplied grammar entry matches the supplied rule name
# returns the rule defintion. If the grammar entry is not for 
# the specified rule name, returns NULL
getDefinition <- function(ruleName, line) {
    ruleName = tolower(trim(ruleName))
    currentRule = parseRuleName(line)
    
    # could not find match
    if (is.null(currentRule)) {
        return(NULL)
    }
    
    if (ruleName == currentRule) {
        return(parseDefinition(line))
    }
    else {
        return(NULL)
    }
    
}

# for a given grammar entry, parses out the definition 
parseDefinition <- function(line) {
    defintionRegex = ":(.*);"
    definition =  getCaptureGroup(defintionRegex, line, 1)
    if (is.null(definition)) {
        return(NULL)
    }
    else {
        return(trim(definition))
    }
}

# for a given grammar entry, parses out the rule
parseRuleName <- function(line) {
    ruleRegex = "^([\\w]+)\\s*:"
    rule = getCaptureGroup(ruleRegex, line, 1)
    if (is.null(rule)) {
        return(NULL)
    }
    else {
        return(tolower(trim(rule)))
    }
}

# detects whether the ANTLR line is terminated. 
hasTerminator <- function(line) {
    terminatorRegex = ";(?!')"
    terminator =  getCaptureGroup(terminatorRegex, line, 1)
    if (is.null(terminator)) {
        return(FALSE)
    }
    else {
        return(TRUE)
    }
    
}

# detects whether the string is the beginning or end of a ANTLR comment
isMultiLineComment <- function(line) {
    commentRegex = '(\\/\\*|\\*\\/)'
    comment =  getCaptureGroup(commentRegex, line, 1)
    if (is.null(comment)) {
        return(FALSE)
    }
    else {
        return(TRUE)
    }
    
}

# detects whether the string is entirely whitespace
isWhitespace <- function(line) {
    whitespaceRegex = "^(\\s*)$"
    whitespace =  getCaptureGroup(whitespaceRegex, line, 1)
    if (identical(line, character(0))) {
        return(TRUE)
    }
    else if (!is.null(whitespace) | (line == "")) {
        return(TRUE)
    }
    else {
        return(FALSE)
    }
}