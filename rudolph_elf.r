options(java.parameters = c('-Xmx500M'))

library('rJava')

# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))
# .jaddClassPath('/usr/local/lib/antlr-4.7.2-complete.jar')
project_dir <- dirname(sys.frame(1)$ofile)
jar_class_path <- paste(project_dir, 'RudolphElf.jar', sep='/')
.jaddClassPath(jar_class_path)

# Create new instance of antlr tool
# antlr <- .jnew('org.antlr.v4.Tool')
wunorse <- .jnew('org.rudolph.elf.Wunorse')

# Working directory
wd <- project_dir

# Call antlr on grammar file
grammar_path <- paste(wd, 'Chat.g4', sep='/')

# Generate java files for parser and lexer
print('start parser/lexer generation')
.jcall(wunorse, 'V', 'main', .jarray(c(grammar_path)))
print('done parser/lexer generation')

# Compile java files for parser and lexer
print('start parser/lexer compilation')
pl_path <- paste(wd, 'Chat*.java', sep='/')
jar_class_path_arg <- paste('"', jar_class_path, '"', sep='')
system(paste('javac', '-cp', jar_class_path_arg, pl_path, sep=' '))
print('done parser/lexer compilation')
