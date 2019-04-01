# context("rudolph elf")
# test_that("initialization works", {
#     elf <- RudolphElf(grammarFile="inst/Chat.g4")
#     #check if root package dir is set correctly
#     expect_match(elf@rootPackageDir,'.*/rudolph')
# 
#     #check if antlr compile files exist
#     expect_true(file.exists("inst/ChatParser.java"))
#     expect_true(file.exists("inst/ChatLexer.java"))
# 
#     #tear down
#     unlink("inst/", recursive=TRUE)
# 
# })
# test_that("errors if grammar file doesn't exist", {
#     expect_error(RudolphElf(grammarFile="nonexistant.g4"), 'could not find file: *')
# })
# test_that("errors if grammar file is not g4", {
#     expect_error(RudolphElf(grammarFile="inst/Rudolph.jar"),'antlr grammar files must have a .g4 extension*')
# })
# test_that("does compile work", {
#     elf <- RudolphElf(grammarFile="inst/Chat.g4")
#     compile(elf)
#     #check if antlr compile files exist
#     expect_true(file.exists("inst/ChatParser.class"))
#     expect_true(file.exists("inst/ChatLexer.class"))
#     #tear down
#     unlink("inst/", recursive=TRUE)
# })
