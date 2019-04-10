
# loops through the grammar file trying to find a specified rule
# returns the rule's definition
grammarLookup = function(filePath, ruleName) {
    lines = c()
    counter = 0
    comment_flag = FALSE
    definition = NULL
    
    con = file(filePath, "r")
    while ( length(line) > 0 ) {
        line = readLines(con, n = 1)
        
        if (is_comment(line)) {
            comment_flag = !comment_flag
            next
        }
        
        if (comment_flag | isWhitespace(line)) {
            next
        }
       
        if (has_terminator(line)) {
            if (length(lines) > 0) {
                counter = counter + 1
                lines[counter] = line
                line = paste(lines, collapse = ' ')
            }
            definition = get_definition(ruleName, line)
            lines = c()
            counter = 0
        }
        else {
            counter = counter + 1
            lines[counter] = trim(line)
            next
        }
        # return the definition when found
        if (!is.null(definition)) {
            close(con)
            return(definition)
        }
    }
    close(con)
    # if we reach the end of the grammar file without finding
    # the rule, throw an error
    stop(paste(ruleName, "not found in grammar:", filePath))
}