context("elf")

base <- system.file("inst", package = "rudolph")

test_that("initialization works", {
	expect_error(
		Elf(
			destinationDirectory = base,
			grammarFile          = paste(
				base, "Chat.g4",
				sep = "/"
			)
		),
		NA
	)
})

test_that("errors if grammar file doesn't exist", {
	expect_error(
		Elf(grammarFile = "nonexistant.g4"),
		"File not found: +"
	)
})

test_that("errors if grammar file is not g4", {
	expect_error(
		Elf(grammarFile = "inst/Rudolph.jar"),
		"ANTLR grammar files must have a .g4 extension"
	)
})

test_that("does compile work", {
	elf <- Elf(
		destinationDirectory = base,
		grammarFile          = paste(
			base, "Chat.g4",
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
				elf@destinationDirectory, "ChatParser.class",
				sep = "/"
			)
		)
	)
	expect_true(
		file.exists(
			paste(
				elf@destinationDirectory, "ChatLexer.class",
				sep = "/"
			)
		)
	)

	# Tear down
	file.rename(
		paste(base, "Chat.g4", sep = "/"),
		paste(base, "donotdelete", sep = "/")
	)
	file.remove(
		dir(
			path    = base,
			pattern = "Chat*"
		)
	)
	file.rename(
		paste(base, "donotdelete", sep = "/"),
		paste(base, "Chat.g4", sep = "/")
	)
})
