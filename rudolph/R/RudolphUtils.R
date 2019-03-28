options(java.parameters = c('-Xmx500M'))
library('rJava')
# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))

RudolphUtils <- setClass(
    "RudolphUtils", 
    slots = list(
        grammarFile="character",
        rootPackageDir="character",
        antlrFilePath="character",
        jarClassPath="character"
    )
)
#' getRootPackageDir
#' 
#' returns the string root directory of the rudolph package
setGeneric(name="getRootPackageDir", def=function(self) {
    standardGeneric("getRootPackageDir")
})
setMethod(
    "getRootPackageDir",
    "RudolphUtils",
    function(self) {
        basePath = system.file(package="rudolph")
        BASE_PATH_DIR = '/inst/'
        endLength = nchar(basePath)
        # system.file root includes inst/. we are going to remove that directory
        # so that we get /rudolph as the base path
        return(substr(basePath, 0, endLength-(nchar(BASE_PATH_DIR)-1)))
    }
)
#' getAntlrFilePath
#'
#' get the antlerFilePath parameter to the absolute path of where antlr generates 
# the lexer/parser/tokens
setGeneric(name="getAntlrFilePath", def=function(self) {
    standardGeneric("getAntlrFilePath")
})
setMethod(
    "getAntlrFilePath",
    "RudolphUtils",
    function(self) {
        return(paste(getwd(), 'inst/', sep='/'))
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
        absPath = paste(self@rootPackageDir, self@grammarFile, sep='/')
        if (!file_test("-f", absPath)) {
            stop(paste("could not find file: ", absPath, sep=''))
        }
    }
)