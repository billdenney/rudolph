options(java.parameters = c('-Xmx500M'))

#' initializeJVM
#'
#' Sets the working directory and initializes the JVM.
#' @importFrom rJava .jpackage
initializeJVM <- function() {
	# Initialize the JVM
	rJava::.jpackage("rudolph", lib.loc = find.package("rudolph"))

	javaVersion <- .jcall(
		"java/lang/System",
		"S",
		"getProperty",
		"java.version"
	)

	if (grepl("^12", javaVersion)) {
		stop(
			paste(
				"Java 12 currently not supported due to broken JNI support.",
				"Use stable Java 8 - Java 11."
			)
		)
	}
}

#' validateFile
#'
#' Checks to see if the file extension for given file is .g4 and that the file
#' exists.
validateFile <- function(grammarFiles) {
	for (grammarFile in grammarFiles) {
		# Validate file extension
		fileExtension = substr(
			grammarFile,
			nchar(grammarFile) - 2,
			nchar(grammarFile)
		)
		if (fileExtension != '.g4') {
			stop("ANTLR grammar files must have a .g4 extension.")
		}
	}
}

# validate only one parser and one lexer supplied

validateGeneratedParserLexerFiles <- function(destinationDirectory, lexerName, parserName) {
	fileNames = list.files(destinationDirectory)
	fileRegex = "(.+?)(?=\\.|Base|Listener|Lexer|Parser)"
	lexerName  = getCaptureGroup("(.+?)(parser|lexer|$)", tolower(lexerName), 1)
	parserName = getCaptureGroup("(.+?)(parser|lexer|$)", tolower(parserName), 1)

	for (fileName in fileNames) {
		name = getCaptureGroup(fileRegex, fileName, 1)

		if (is.null(name)) {
			warning(paste('Unknown parser/lexer file type found:', fileName))
		}
		else if (tolower(name) == parserName) {
			next
		}
		else if (tolower(name) == lexerName) {
			next
		}
		else {
			stop(
				paste0(
					"'",
					name,
					"'",
					" does not match either the parser name, '",
					parserName,
					"' or the lexer name, '",
					lexerName,
					"'"
				)
			)
		}

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

getErrorInfo <- function(object) {
	errorMap <- list(
		file  = "Generated grammar files could not be located",
		javac = "Please ensure JDK is installed and included in your PATH",
		none  = "Unknown errors"
	)

	type <- "none"

	if (grepl("file not found", object[1])) {
		type <- "file"
	}
	# Check if javac was not found. Different shells produce different error
	# messages.
	# Windows CMD produces:
	#  "'javac' is not recognized as an internal or external command,
	#  operable program or batch file."
	# MacOS/Linux (bash) produces:
	#  "javac: command not found"
	else if (grepl("(?:is not recognized|command not found)", object[1])) {
		type <- "javac"
	}

	return(errorMap[type])
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
		return(value[group_number])
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

ignoreANTLRFragment <- function(line) {
	line          = trim(line)
	fragmentRegex = "^fragment\\s+(.*:)"
	rule          = getCaptureGroup(fragmentRegex, line, 1)

	# if the "fragment" keyword is not used on the line, return the line
	if (is.null(rule)) {
		return(line)
	}

	return(trim(rule))
}
# for a given grammar entry, parses out the rule
parseRuleName <- function(line) {
	line      = ignoreANTLRFragment(line)
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
	terminatorRegex = ";|}(?!')"
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

# create a map from a grammar file. grammar files can also be split
# between two different files, one for the parser and one for the lexer.
# The splitfile argument is optional and will parse, either a parser or a
# lexer grammar
parseGrammarMap <- function(grammars) {
	lines      = c()
	grammarMap = list()

	# handles multiline comments /**/ by setting a flag at the opening
	# comment tag (/*) and skipping every line in the file that is between
	# until the closing tag (*/)
	multiLineCommentFlag = FALSE
	definition           = NULL

	for (grammar in grammars) {
		filePointer = file(grammar, "r")
		line        = readLines(filePointer, n = 1)

		# loops through the grammar file trying to find a specified rule
		# returns the rule's definition
		while (length(line) > 0) {

			line = readLines(filePointer, n = 1)
			line = trim(line)

			# if hits end of file,
			# break from while loop
			if (identical(line, character(0))) {
				close(filePointer)
				break
			}

			line = stripInlineComments(line)

			if (isMultiLineComment(line)) {
				multiLineCommentFlag = !multiLineCommentFlag
				next
			}

			if (multiLineCommentFlag | isWhitespace(line)) {
				next
			}

			# only process a line once you have reached the ANTLR terminator ";"
			if (hasTerminator(line)) {
				if (length(lines) > 0) {

					# append
					lines = c(lines, line)
					line = paste(lines, collapse = " ")
				}

				ruleName = parseRuleName(line)

				# if line does not contain a rule, skip
				if (is.null(ruleName)) {

					# reset lines
					lines = c()
					next
				}

				definition             = parseDefinition(line)
				grammarMap[[ruleName]] = definition

				# reset lines
				lines = c()
			}
			else {
				# append
				lines = c(lines, trim(line))
				next
			}
		}
	}

	return(grammarMap)
}
