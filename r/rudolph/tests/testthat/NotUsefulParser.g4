parser grammar NotUsefulParser;

@header{
package org.useful.parser;
}

options{
    tokenVocab=UsefulLexer;
}

usefulRule:USEFUL_TOKEN*;
