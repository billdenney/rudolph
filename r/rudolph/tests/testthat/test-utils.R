context("utils")
test_that("can parse grammar name from file ", {
	expect_equal(parseGrammarNameFromFile("inst/TestGrammar.g4"), "TestGrammar")
})
