options(java.parameters = c('-Xmx500M'))

library('rJava')
# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))

RudolphElf <- setClass("RudolphElf", slots=list(grammarFile="character"))

#' Initialization Function
#'
#' Set the antlr grammar file
#' @param grammarFile .g4 grammar file
#' @keywords cats
#' @export
#' @examples
#' chat <- new('RudolphElf', grammarFile='Chat.g4')
#' show(chat)
setMethod("show",
          "RudolphElf",
          function(object) {
              cat(object@grammarFile, "\n")
          }
)