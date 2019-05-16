context("rudolph")

base <- system.file("inst", package = "rudolph")

test_that("get ast from text input", {
	expectedOutput <- list(
		rudolph = list(
			attributes = list("antlrs", "red nose")
		)
	)
	with_mock(
		.jnew = function(a, b) return(new("jobjRef")),
		{
			rudolph <- Rudolph(
				grammarFile     = system.file(
					"inst", "TestGrammar.g4",
					package = "rudolph"
				),
				rootNode        = "santa",
				sourceDirectory = getwd()
			)

			expect_error(getAST(rudolph), "Must specify text or file")
			expect_error(
				getAST(
					rudolph,
					file = "doesnotexist.txt"
				),
				"'doesnotexist.txt' does not exist"
			)

			with_mock(
				.jcall = function(c, returnSig, e, f) {
					return(
						'{"rudolph": {"attributes": ["antlrs", "red nose"]}}'
					)
				},
				{
					expect_equal(getAST(rudolph, ""), expectedOutput)
					expect_equal(getAST(rudolph, text = ""), expectedOutput)
					expect_equal(
						getAST(
							rudolph,
							file = paste0(base, "/TestFile.txt")
						),
						expectedOutput
					)
				}
			)
		}
	)
})

test_that("pretty print AST", {
	rudolph <- Rudolph(
		grammarFile     = system.file(
			"inst", "TestGrammar.g4",
			package = "rudolph"
		),
		rootNode        = "root",
		sourceDirectory = getwd()
	)

	ast <- list(
		a = list(
			list(
				b = list(
					list(text = 1),
					list(text = 2)
				)
			),
			list(
				c = list(
					list(text = 3),
					list(
						d = list(
							list(text = 4)
						)
					)
				)
			),
			list(text = 5),
			list(text = "<EOF>")
		)
	)

	expectedOutput <- "12345"

	expect_error(prettyPrint(rudolph), "Must specify ast")
	expect_equal(prettyPrint(rudolph, ast), expectedOutput)
})

test_that("grammar lookup", {
	rudolph <- Rudolph(
		grammarFile		= system.file(
			"inst", "TestGrammar.g4",
			package = "rudolph"
		),
		rootNode		= "root",
		sourceDirectory = getwd()
	)

	definition <- grammarLookup(rudolph, "name")
	expect_equal(definition, "WORD WHITESPACE")

	definition <- grammarLookup(rudolph, "mention")
	expect_equal(definition, "'@' WORD")

	definition <- grammarLookup(rudolph, "emoticon")
	expect_equal(definition, "':' '-'? ')' | ':' '-'? '('")
})

test_that("grammar lookup rule not found", {
	rudolph <- Rudolph(
		grammarFile     = system.file(
			"inst", "TestGrammar.g4",
			package = "rudolph"
		),
		rootNode        = "root",
		sourceDirectory = getwd()
	)

	expect_error(
		grammarLookup(rudolph, "nonExistentRule"),
		"not found in grammar:"
	)
})
