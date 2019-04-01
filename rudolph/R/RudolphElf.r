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
#' chat <- RudolphElf(grammarFile="inst/Chat.g4")
RudolphElf <- setClass(
    "RudolphElf", 
    slots=list(),
    contains="RudolphUtils"
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
            "Rudolph.jar", 
            package="rudolph"
        )
        .jaddClassPath(c(.Object@rootPackageDir, .Object@jarClassPath))
        
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

#' compile
#'
#' compiles antlr java files
setGeneric(name="compile", def=function(self) {
    standardGeneric("compile")
})
setMethod(
    "compile",
    "RudolphElf",
    function(self) {
        grammarName = parseGrammarNameFromFile(self)
        print('start parser/lexer compilation')
        grammarFileWildMatch = paste(grammarName, '*.java', sep='')
        pl_path = paste(self@antlrFilePath, grammarFileWildMatch, sep='/')
        jar_class_path_arg = paste('"', self@jarClassPath, '"', sep='')
        system(paste('javac', '-cp', jar_class_path_arg, pl_path, sep=' '))
        print('done parser/lexer compilation')
    }
)
