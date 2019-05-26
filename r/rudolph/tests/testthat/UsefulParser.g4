parser grammar UsefulParser;

@header{
package org.useful.parser;
}

options{
    tokenVocab=UsefulLexer;
}

usefulRule:USEFUL_TOKEN*;
