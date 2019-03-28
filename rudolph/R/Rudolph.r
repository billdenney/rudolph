options(java.parameters = c('-Xmx500M'))
library('rJava')
# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))

#' Rudolph
#'
#' Rudolph is the api that allows users to work with an antlr abstract syntax 
#' tree in R.
#' @param grammarFile 
#' @param rootNode 
#' @keywords init, initialize
#' @export
#' @examples
#' chat <- RudolphElf(grammarFile="inst/Chat.g4")
#' rudolph <- .jnew('org.rudolph.rudolph.Rudolph', c('Chat', 'chat'))
RudolphElf <- setClass(
    "RudolphElf", 
    slots = list(
        grammarName="character",
        rootNode="character",
        antlrFilePath="character",
        jarClassPath="character"
    )
)

#' Initialization Function
#'
#' Sets the antlr grammar file. Initializes the the java environment.
#' @param grammarFile .g4 grammar file path. The file path is relative to the current working
#' directory of the user.
#' @keywords init, initialize
#' @export
#' @examples
#' chat <- RudolphElf(grammarFile="inst/Chat.g4")
setMethod(
    "initialize", 
    "RudolphElf",
    function(.Object, grammarFile=character(0)) {
        .Object <- callNextMethod()
        .Object@grammarFile = grammarFile
        .Object@rootPackageDir = getRootPackageDir(.Object)
        .Object@antlrFilePath = getAntlrFilePath(.Object)
        
        validateFileInput(.Object)
        
        # importing wnorse anltr wrapper
        .Object@jarClassPath <- system.file(
            "inst", 
            "RudolphElf.jar", 
            package="rudolph"
        )
        .jaddClassPath(.Object@jarClassPath)
        
        # wunorse is our light wrapper around antlr
        # it prevents antlr from crashing on import
        wunorse <- .jnew('org.rudolph.elf.Wunorse')
        
        print('start parser/lexer generation')
        .jcall(wunorse, 'V', 'main', .jarray(c(.Object@grammarFile)))
        print(paste(
            'successfully created parser/lexer files in ', 
            .Object@antlrFilePath,
            sep=""
        ))
        return(.Object)
    }
)