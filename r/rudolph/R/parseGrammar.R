# returns string w/o leading or trailing whitespace
trim = function(x) {gsub("^\\s+|\\s+$", "", x)}
get_capture_group = function(r, s, group_number){
    value = gsub(
        r, 
        paste("\\", group_number, sep=""), 
        regmatches(
            s,
            gregexpr(r, s, perl=TRUE)
        )[[1]],
        perl=TRUE
    )
    if (identical(value, character(0))) {
        return(NULL)
    }
    else {
        return(value)
    }
}
get_definition = function(ruleName, line){
    ruleName = tolower(trim(ruleName))
    # get the rule name of the current line
    rule_regex = "^([a-zA-Z0-9]+)\\s*:"
    current_rule = get_capture_group(rule_regex, line, 1)
    # could not find match
    if (is.null(current_rule)) {
        return(NULL)
    }
    
    if (ruleName == tolower(trim(current_rule))) {
        return(parse_definition(line))
    }
    else {
        return(NULL)
    }

}
parse_definition = function(line) {
    defintion_regex = ":(.*);"
    definition =  get_capture_group(defintion_regex, line, 1)
    # returns definition w/o leading or trailing whitespace
    return(trim(definition))
}
has_terminator = function(line) {
    terminator_regex = ";(?!')"
    terminator =  get_capture_group(terminator_regex, line, 1)
    if (is.null(terminator)) {
        return(FALSE)
    }
    else {
        return(TRUE)
    }
    
}
is_comment = function(line) {
    comment_regex = '(\\/\\*|\\*\\/)'
    comment =  get_capture_group(comment_regex, line, 1)
    if (is.null(comment)) {
        return(FALSE)
    }
    else {
        return(TRUE)
    }
    
}
isWhitespace = function(line) {
    whitespace_regex = '^(\\s*)$'
    whitespace =  get_capture_group(whitespace_regex, line, 1)
    if (!is.null(whitespace) | (line == "")) {
        return(TRUE)
    }
    else {
        return(FALSE)
    }
}
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
        
        if (!is.null(definition)) {
            close(con)
            return(definition)
        }
    }
    close(con)
    print(paste(ruleName, "not found in grammar:", filePath))
}
print(grammarLookup("~/Apps/antlr/r/rudolph/inst/Chat.g4", "chat"))