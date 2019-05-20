context("utils")

base <- system.file("tests", "testthat", package = "rudolph")

test_that("can parse grammar name from file ", {
	expect_equal(
		parseGrammarNameFromFile(file.path(base, "TestGrammar.g4")),
			"TestGrammar"
	)
})

test_that("getGrammarMap returns a map of the grammar", {
	grammarMap = parseGrammarMap(file.path(base, "TestGrammar.g4"))
	returnType = typeof(grammarMap)

	expect_equal(returnType, "list")
	expect_equal(length(grammarMap), 24)
})
