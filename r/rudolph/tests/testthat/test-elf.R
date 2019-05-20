context("elf")

base <- system.file("tests", "testthat", package = "rudolph")

teardown <- function() {
	file.rename(
		file.path(base, "TestGrammar.g4"),
		file.path(base, "donotdelete")
	)
	file.remove(
		dir(
			path       = base,
			pattern    = "TestGrammar*",
			full.names = TRUE
		)
	)
	file.rename(
		file.path(base, "donotdelete"),
		file.path(base, "TestGrammar.g4")
	)
}

test_that("initialization works", {
	expect_error(
		Elf(
			destinationDirectory = base,
			grammarFile          = file.path(base, "TestGrammar.g4")
		),
		NA
	)
})

test_that("errors if grammar file is not g4", {
	expect_error(
		Elf(
			grammarFile = file.path(
				base,
				"TestFile.txt"
			)
		),
		"ANTLR grammar files must have a .g4 extension"
	)
})

test_that("errors if javac is not found", {
	elf <- Elf(
		destinationDirectory = dirname(dirname(base)),
		grammarFile          = file.path(base, "TestGrammar.g4")
	)

	expect_output(
		generate(elf),
		"Successfully created parser/lexer files in .+/rudolph"
	)

	systemErrors <- c(
		paste(
			"'javac' is not recognized as an internal or external command",
			"operable program or batch file.",
			sep = " "
		),
		"javac: command not found",
		"javac: file not found"
	)

	for (systemError in systemErrors) {
		with_mock(
			system2 = function(command, args, stderr, stdout) {
				attr(systemError, "status") <- 2
				return(systemError)
			},
			expect_error(compile(elf), "*")
		)
	}

	# Tear down
	teardown()
})

test_that("does compile work", {
	elf <- Elf(
		destinationDirectory = dirname(dirname(base)),
		grammarFile          = file.path(base, "TestGrammar.g4")
	)

	expect_output(
		generate(elf),
		"Successfully created parser/lexer files in .+/rudolph"
	)
	expect_output(
		compile(elf),
		"Parser/lexer compilation complete"
	)

	#check if antlr compile files exist
	expect_true(
		file.exists(
			paste(
				elf@destinationDirectory, "TestGrammarParser.class",
				sep = "/"
			)
		)
	)
	expect_true(
		file.exists(
			paste(
				elf@destinationDirectory, "TestGrammarLexer.class",
				sep = "/"
			)
		)
	)

	# Tear down
	teardown()
})
