package org.rudolph.rudolph;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNodeImpl;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class Rudolph {
	private static final Gson PRETTY_PRINT_GSON = new GsonBuilder().disableHtmlEscaping().setPrettyPrinting().create();
	private static final Gson GSON = new GsonBuilder().disableHtmlEscaping().create();

	private static Lexer lexer;
	private static Parser parser;
	private static Class<? extends Parser> parserClass;
	private static Vocabulary vocabulary;

	private String grammarName;
	private String startRuleName;

	private Rudolph(String[] args) {
		grammarName   = args[0];
		startRuleName = args[1];

		try {
			initialize();
		}
		catch (Exception exception) {
			System.err.println("Could not create new parser/lexer instance: " + exception);
		}
	}

	private String initialize() throws Exception {
		System.out.println(System.getProperty("user.dir"));

		String lexerName = grammarName + "Lexer";
		ClassLoader cl = Thread.currentThread().getContextClassLoader();
		Class<? extends Lexer> lexerClass = null;
		try {
			lexerClass = cl.loadClass(lexerName).asSubclass(Lexer.class);
		}
		catch (java.lang.ClassNotFoundException cnfe) {
			// might be pure lexer grammar; no Lexer suffix then
			lexerName = grammarName;
			try {
				lexerClass = cl.loadClass(lexerName).asSubclass(Lexer.class);
			}
			catch (ClassNotFoundException cnfe2) {
				System.err.println("Can't load " + lexerName + " as lexer or parser");
				return "ERROR";
			}
		}

		Constructor<? extends Lexer> lexerConstructor = lexerClass.getConstructor(CharStream.class);
		lexer = lexerConstructor.newInstance((CharStream)null);

		String parserName = grammarName + "Parser";
		parserClass = cl.loadClass(parserName).asSubclass(Parser.class);
		Constructor<? extends Parser> parserConstructor = parserClass.getConstructor(TokenStream.class);
		parser = parserConstructor.newInstance((TokenStream)null);

		vocabulary = parser.getVocabulary();

		return "";
	}

	/**
	 * Processes string input and returns an abstract syntax tree.
	 * <p>
	 * Uses Parser and Lexer classes generated via ANTLR to process the given string
	 * into an abstract syntax tree.
	 *
	 * @exception Exception if the Parser class does not have the given start rule
	 * @param textInput the string to be processed
	 * @return String of abstract syntax tree in JSON or "ERROR"
	 */
	public String process(String textInput) throws Exception {
		CharStream charStream = CharStreams.fromString(textInput);
		return process(charStream);
	}

	private String process(CharStream input) throws IllegalAccessException, InvocationTargetException {
		lexer.setInputStream(input);
		CommonTokenStream tokens = new CommonTokenStream(lexer);

		tokens.fill();

		parser.setBuildParseTree(true);
		parser.setTokenStream(tokens);

		try {
			Method startRule = parserClass.getMethod(startRuleName);
			ParserRuleContext tree = (ParserRuleContext)startRule.invoke(parser, (Object[])null);
			return toJson(tree);
		}
		catch (NoSuchMethodException nsme) {
			System.err.println("No method for rule " + startRuleName + " or it has arguments");
		}
		return "ERROR";
	}

	private static String toJson(ParseTree tree) {
		return toJson(tree, false);
	}

	private static String toJson(ParseTree tree, boolean prettyPrint) {
		return prettyPrint ? PRETTY_PRINT_GSON.toJson(toMap(tree)) : GSON.toJson(toMap(tree));
	}

	private static Map<String, Object> toMap(ParseTree tree) {
		Map<String, Object> map = new LinkedHashMap<>();
		traverse(tree, map);
		return map;
	}

	private static void traverse(ParseTree tree, Map<String, Object> map) {
		if (tree instanceof TerminalNodeImpl) {
			Token token = ((TerminalNodeImpl) tree).getSymbol();

			map.put("type", "lexer");
			map.put("name", vocabulary.getDisplayName(token.getType()));
			map.put("value", token.getText());
		}
		else {
			List<Map<String, Object>> children = new ArrayList<>();
			String name = tree.getClass().getSimpleName().replaceAll("Context$", "");

			map.put("type", "parser");
			map.put("name", Character.toLowerCase(name.charAt(0)) + name.substring(1));
			map.put("value", children);

			for (int i = 0; i < tree.getChildCount(); i++) {
				Map<String, Object> nested = new LinkedHashMap<>();
				children.add(nested);
				traverse(tree.getChild(i), nested);
			}
		}
	}
}
