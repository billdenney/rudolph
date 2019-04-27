context("utils")

test_that("can parse grammar name from file ", {
	expect_equal(parseGrammarNameFromFile("inst/TestGrammar.g4"), "TestGrammar")
})

test_that("errors when grammar rule not found", {
	expect_error(
		searchForGrammarRule(
			"../../inst/TestGrammar.g4",
			"nonExistentRule"
		),
		"not found in grammar:"
	)
})
