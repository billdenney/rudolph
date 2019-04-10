context("rudolph")

# test_that("get ast from text input", {
# 	expectedOutput <- list(
# 		rudolph = list(
# 			attributes = list("antlrs", "red nose")
# 		)
# 	)
# 	with_mock(
# 		.jnew = function(a, b) return(new("jobjRef")),
# 		{
# 			rudolph <- Rudolph(
# 				grammarFile     = system.file("inst", "Chat.g4", package = "rudolph"),
# 				rootNode        = "santa",
# 				sourceDirectory = getwd()
# 			)
# 			with_mock(
# 				.jcall = function(c, d, e, f) return('{"rudolph": {"attributes": ["antlrs", "red nose"]}}'),
# 				expect_equal(getAST(rudolph, ""), expectedOutput)
# 			)
# 		}
# 	)
# })

test_that("grammar lookup", {
    rudolph <- Rudolph(
        				grammarFile     = system.file(
        				    "inst",
        				    "Chat.g4", 
        				    package = "rudolph"
        				),
        				rootNode        = "chat",
        				sourceDirectory = getwd()
        			)
    definition <- grammarLookup(rudolph, 'name')
    expect_equal( defintion, 'WORD WHITESPACE')
})
