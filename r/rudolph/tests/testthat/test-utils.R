context("utils")

test_that("can parse grammar name from file ", {
	expect_equal(parseGrammarNameFromFile("inst/TestGrammar.g4"), "TestGrammar")
})

test_that("getGrammarMap returns a map of the grammar", {
	grammarMap = parseGrammarMap("../../inst/TestGrammar.g4")
	returnType = typeof(grammarMap)

	expect_equal(returnType, "list")
	expect_equal(length(grammarMap), 24)
})
