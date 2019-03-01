options(java.parameters = c('-Xmx500M'))

library('rJava')

# Set working directory so JVM is started in the correct directory
project_dir <- dirname(sys.frame(1)$ofile)
setwd(project_dir)

# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))
jar_class_path <- paste(project_dir, 'Rudolph.jar', sep='/')
.jaddClassPath(c(project_dir, jar_class_path))

# Create new instance of antlr tool
rudolph <- .jnew('org.rudolph.rudolph.Rudolph', c('Chat', 'chat'))

input_text <- 'john SAYS: hello @michael this will not work\n'
print(.jcall(rudolph, 'S', 'process', input_text))
