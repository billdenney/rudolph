options(java.parameters = c('-Xmx500M'))
library('rJava')
# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))

RudolphElf <- setClass(
    "RudolphElf", 
    slots = list(
        grammarFile="character"
        )
    )

#' Initialization Function
#'
#' Set the antlr grammar file
#' @param grammarFile .g4 grammar file
#' @keywords cats
#' @export
#' @examples
#' chat <- new('RudolphElf', grammarFile='Chat.g4')
#' show(chat)
setMethod(
    "initialize", 
    "RudolphElf",
    function(.Object, grammarFile=character(0)) {
        .Object <- callNextMethod()
        .Object@grammarFile=grammarFile
        # check_if_file_exists(.Object)
        
        # importing wnorse anltr wrapper
        jar_class_path <- system.file(
            "inst", 
            "RudolphElf.jar", 
            package="rudolph"
        )
        .jaddClassPath(jar_class_path)
        wunorse <- .jnew('org.rudolph.elf.Wunorse')

        print('start parser/lexer generation')
        .jcall(wunorse, 'V', 'main', .jarray(c(.Object@grammarFile)))
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
