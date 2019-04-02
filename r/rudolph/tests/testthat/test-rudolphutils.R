context("rudolph utils")
test_that("can parse grammar name from file ", {
	util <- RudolphUtils(grammarFile="inst/Chat.g4")
	expect_equal(parseGrammarNameFromFile(util), 'Chat')
})