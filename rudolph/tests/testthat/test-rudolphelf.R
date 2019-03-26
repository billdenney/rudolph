context("rudolph elf")
test_that("initialization works", {
    RudolphElf(grammarFile="inst/Chat.g4")
    expect_true(file.exists("inst/ChatParser.java"))
    expect_true(file.exists("inst/ChatLexer.java"))
    #tear down 
    unlink("inst/", recursive=TRUE)
    
})
test_that("errors if grammar file doesn't exist", {
    expect_error(RudolphElf(grammarFile="nonexistant.g4"))
})