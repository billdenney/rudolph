context("utils")

base <- system.file("tests", "testthat", package = "rudolph")

test_that("can parse grammar name from file ", {
	expect_equal(
		parseGrammarNameFromFile(c(file.path(base, "TestGrammar.g4"))),
			"TestGrammar"
	)
})

test_that("getGrammarMap returns a map of the grammar", {
	grammarMap = parseGrammarMap(c(file.path(base, "TestGrammar.g4")))
	returnType = typeof(grammarMap)

	expect_equal(returnType, "list")
	expect_equal(length(grammarMap), 24)
})

test_that("getGrammarMap works with seperate parser and lexer grammers", {
	grammarMap = parseGrammarMap(
		c(
			file.path(base, "TestGrammarLexer.g4"),
			file.path(base, "TestGrammarParser.g4")
		)
	)
	returnType = typeof(grammarMap)

	expect_equal(returnType, "list")
	expect_equal(length(grammarMap), 2)
})
