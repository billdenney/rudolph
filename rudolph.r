options(java.parameters = c('-Xmx500M'))

library('rJava')

# Set working directory so JVM is started in the correct directory
project_dir <- dirname(sys.frame(1)$ofile)

# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))
jar_class_path <- paste(project_dir, 'Rudolph.jar', sep='/')
.jaddClassPath(c(project_dir, jar_class_path))

# Create new instance of antlr tool
rudolph <- .jnew('org.rudolph.rudolph.Rudolph', c('Chat', 'chat'))

# Input text
input_text <- 'john SAYS: hello @michael this will not work\n'

# Output JSON
ast_json <- .jcall(rudolph, 'S', 'process', input_text)

print(ast_json)

library('jsonlite')

ast_r <- parse_json(ast_json)

print(ast_r)

# output_name <-
#   list(
#     rule="name",
#     value="john"
#   )
# output_command <-
#   list(
#     rule="command",
#     value="SAYS"
#   )
# 
# # nested AST example in R 
# output <-
#   list(
#     rule="chat",
#     value=list(
#       rule="line",
#       value=list(output_name, output_command)
#     )
#   )
# 
# # print("Hi Eric!")
# output_function <-
#   list(
#     rule="function",
#     value=list(
#       list(
#         rule="function_name",
#         value="print"
#       ),
#       list(
#         rule="function_arg",
#         value='"Hi Eric!"'
#       )
#     )
#   )
# sprintf("%s(%s)", function_name, function_arg)
# sprintf("%s[%s];", function_name, function_arg)
