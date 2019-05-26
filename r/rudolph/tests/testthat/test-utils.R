context("utils")

base <- system.file("tests", "testthat", package = "rudolph")

# test_that("can parse grammar name from file ", {
# 	expect_equal(
# 		parseGrammarNameFromFile(c(file.path(base, "TestGrammar.g4"))),
# 			"TestGrammar"
# 	)
# })
#
# test_that("getGrammarMap returns a map of the grammar", {
# 	grammarMap = parseGrammarMap(c(file.path(base, "TestGrammar.g4")))
# 	returnType = typeof(grammarMap)
#
# 	expect_equal(returnType, "list")
# 	expect_equal(length(grammarMap), 24)
# })
#
# test_that("getGrammarMap works with seperate parser and lexer grammers", {
# 	grammarMap = parseGrammarMap(
# 		c(
# 			file.path(base, "UsefulLexer.g4"),
# 			file.path(base, "UsefulParser.g4")
# 		)
# 	)
# 	returnType = typeof(grammarMap)
#
# 	expect_equal(returnType, "list")
# 	expect_equal(length(grammarMap), 2)
# })

test_that("validateGeneratedParserLexerFiles does not error", {
	with_mock(
		list.files = function(directory) {
			return(
				c(
					"myLexerNameBaseListener.java",
					"myParserName.java",
					"myLexerName.token",
					"myLexerNameListener.java"
				)
			)
		},
		expect_error(
			validateGeneratedParserLexerFiles(
				'/fake/directory',
				'myParserName',
				'myLexerName'
			),
			NA
		)
	)
})
