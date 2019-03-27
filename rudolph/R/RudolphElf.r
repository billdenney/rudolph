options(java.parameters = c('-Xmx500M'))
library('rJava')
# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))

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
    slots = list(
        grammarFile="character"
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
        .Object@grammarFile=grammarFile

        validate_file_input(.Object)
        
        # importing wnorse anltr wrapper
        jar_class_path <- system.file(
            "inst", 
            "RudolphElf.jar", 
            package="rudolph"
        )
        .jaddClassPath(jar_class_path)
        
        # wunorse is our light wrapper around antlr
        # it prevents antlr from crashing on import
        wunorse <- .jnew('org.rudolph.elf.Wunorse')

        print('start parser/lexer generation')
        .jcall(wunorse, 'V', 'main', .jarray(c(.Object@grammarFile)))
        # print(paste('successfully created parser/lexer files in ', getwd()))
        return(.Object)
    }
)
setGeneric(name="show", def=function(obj) {
    standardGeneric("show")
})
setMethod(
    "show",
          "RudolphElf",
          function(self) {
              cat('new alana \n')
              cat(self@grammarFile, "\n")
          }
)
setGeneric(name="validate_file_input", def=function(obj) {
    standardGeneric("validate_file_input")
})
setMethod(
    "validate_file_input",
    "RudolphElf",
    function(self) {
        validate_g4_extension(self)
        validate_file_exists(self)
    }
)
setGeneric(name="validate_g4_extension", def=function(obj) {
    standardGeneric("validate_g4_extension")
})
setMethod(
    "validate_g4_extension",
    "RudolphElf",
    function(self) {
        file_extension = substr(
            self@grammarFile, 
            nchar(self@grammarFile) - 2,
            nchar(self@grammarFile)
        )
        if (file_extension != '.g4') {
            stop(paste(
                "antlr grammar files must have a .g4 extension. You supplied a '", 
                file_extension,
                "'"
                )
            )
        }
    }
)
setGeneric(name="validate_file_exists", def=function(obj) {
    standardGeneric("validate_file_exists")
})
setMethod(
    "validate_file_exists",
    "RudolphElf",
    function(self) {
        base_path = system.file(package="rudolph")
        BASE_PATH_DIR = '/inst/'
        end_length = nchar(base_path)
        # system.file root includes inst/. we are going to remove that directory
        # so that we get /rudolph as the base path
        base_path = substr(base_path, 0, end_length-(nchar(BASE_PATH_DIR)-1))
        abs_path = paste(base_path, self@grammarFile, sep='/')
        if (!file_test("-f", abs_path)) {
            stop(paste("could not find file: ", abs_path, sep=''))
        }
    }
)
