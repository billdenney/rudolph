package org.rudolph.rudolph;

import org.antlr.v4.runtime.ConsoleErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

public class RConsoleErrorListener extends ConsoleErrorListener {
	public static final RConsoleErrorListener INSTANCE = new RConsoleErrorListener();

	public RConsoleErrorListener() {
	}

	public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
		System.err.println("ANTLR warning: line " + line + ":" + charPositionInLine + " " + msg + "\n\tException: " + e);
	}
}
