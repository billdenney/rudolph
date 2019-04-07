context("rudolph elf")

test_that("initialization works", {
	elf <- RudolphElf(
		destinationDirectory = system.file("inst", package = "rudolph"),
		grammarFile          = system.file("inst", "Chat.g4", package = "rudolph")
	)

	#check if antlr compile files exist
	expect_true(file.exists(paste(elf@destinationDirectory, "ChatParser.java", sep = "/")))
	expect_true(file.exists(paste(elf@destinationDirectory, "ChatLexer.java", sep = "/")))

	#tear down
	unlink("inst/", recursive = TRUE)
})

test_that("errors if grammar file doesn't exist", {
	expect_error(RudolphElf(grammarFile="nonexistant.g4"), 'could not find file: *')
})

test_that("errors if grammar file is not g4", {
	expect_error(RudolphElf(grammarFile="inst/Rudolph.jar"),'antlr grammar files must have a .g4 extension*')
})

test_that("does compile work", {
	elf <- RudolphElf(
		destinationDirectory = system.file("inst", package = "rudolph"),
		grammarFile          = system.file("inst", "Chat.g4", package = "rudolph")
	)
	compile(elf)

	#check if antlr compile files exist
	expect_true(file.exists(paste(elf@destinationDirectory, "ChatParser.class", sep = "/")))
	expect_true(file.exists(paste(elf@destinationDirectory, "ChatLexer.class", sep = "/")))

	#tear down
	unlink("inst/", recursive = TRUE)
})
