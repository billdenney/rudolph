package org.rudolph.elf;

import org.antlr.v4.Tool;
import org.antlr.v4.tool.ErrorType;
import java.io.IOException;

public class Wunorse extends org.antlr.v4.Tool {
    public static void main(String[] args) {
        Tool antlr = new Tool(args);
        if ( args.length == 0 ) { antlr.help(); antlr.exit(0); }

        try {
            antlr.processGrammarsOnCommandLine();
        }
        finally {
            if ( antlr.log ) {
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
            antlr.exit(1);
        }
        return;
    }
//    protected void handleArgs() {
//        super.handleArgs();
//
//        return_dont_exit = true;
//    }
}
