context("rudolph")
test_that("get ast from text input", {
    inputText = 'john SAYS: hello @michael this will not work\n'
    rudolph <- Rudolph(grammarFile="inst/Chat.g4", rootNode='chat')
    expect_true(getAST(rudolph, inputText))
})