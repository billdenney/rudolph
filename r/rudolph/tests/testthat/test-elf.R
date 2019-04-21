context("elf")

base <- system.file("inst", package = "rudolph")

teardown <- function() {
	file.rename(
		paste(base, "TestGrammar.g4", sep = "/"),
		paste(base, "donotdelete", sep = "/")
	)
	file.remove(
		dir(
			path       = base,
			pattern    = "TestGrammar*",
			full.names = TRUE
		)
	)
	file.rename(
		paste(base, "donotdelete", sep = "/"),
		paste(base, "TestGrammar.g4", sep = "/")
	)
}

test_that("initialization works", {
	expect_error(
		Elf(
			destinationDirectory = base,
			grammarFile          = paste(
				base,
				"TestGrammar.g4",
				sep = "/"
			)
		),
		NA
	)
})

test_that("errors if grammar file is not g4", {
	expect_error(
		Elf(grammarFile = paste(base, "java/Rudolph.jar", sep = "/")),
		"ANTLR grammar files must have a .g4 extension"
	)
})

test_that("errors if javac is not found", {
	elf <- Elf(
		destinationDirectory = base,
		grammarFile          = paste(
			base, "TestGrammar.g4",
			sep = "/"
		)
	)

	expect_output(
		generate(elf),
		"Successfully created parser/lexer files in .+/rudolph/inst"
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
		destinationDirectory = base,
		grammarFile          = paste(
			base, "TestGrammar.g4",
			sep = "/"
		)
	)

	expect_output(
		generate(elf),
		"Successfully created parser/lexer files in .+/rudolph/inst"
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
