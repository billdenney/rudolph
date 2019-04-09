package org.rudolph.elf;

import org.antlr.v4.Tool;
import org.antlr.v4.tool.ErrorType;
import java.io.IOException;

public class Wunorse extends org.antlr.v4.Tool {
	public static void main(String[] args) {
		Tool antlr = new Tool(args);

		if (args.length == 0) {
			antlr.help();
			System.err.println("ANTLR Error: Missing arguments");
			return;
		}

		try {
			antlr.processGrammarsOnCommandLine();
		}
		finally {
			if (antlr.log) {
				try {
					String logname = antlr.logMgr.save();
					System.out.println("wrote "+logname);
				}
				catch (IOException ioe) {
					antlr.errMgr.toolError(ErrorType.INTERNAL_ERROR, ioe);
				}
			}
		}

		if (antlr.errMgr.getNumErrors() > 0) {
			System.err.println("ANTLR Error: Internal Error");
			return;
		}

		return;
	}
}
