options(java.parameters = c('-Xmx500M'))

library('rJava')

# Initialize the JVM and add to CLASSPATH
.jinit(parameters = getOption('java.parameters'))
project_dir <- dirname(sys.frame(1)$ofile)
jar_class_path <- paste(project_dir, 'Rudolph.jar', sep='/')
.jaddClassPath(jar_class_path)

# Create new instance of antlr tool
rudolph <- .jnew('org.rudolph.rudolph.Rudolph', c('Hello', 'r'))

# can't find the Hello* classes...
print(.jcall(rudolph, 'S', 'process', 'hello santa'))
