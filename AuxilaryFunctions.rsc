module gen::naturallanguage::AuxilaryFunctions

import lang::ExtendedSyntax;
import gen::scala::ScalaGenerator;
import gen::naturallanguage::Types;
import gen::naturallanguage::PosTagger;

import String;
import IO;
import List;

// AuxilaryFunctions contains all functions that are not necassarirly related to a certain component

// Remove the camel case from a string and split into words
str removeCamelCase(str s) {
	// capatalize string	
	str s1 = capitalize(s);
	
	// break string into separate words
	list[str] s2 = [ x | /<x:[A-Z][a-z]*>/ := s1];
	
	// map each word to its lowercase version
	list[str] s3 = [ toLowerCase(x) | x <- s2 ];
	
	// convert list of words to a string
	s4 = "";
	c = 0;
	for(i <- s3) {
		if(c != size(s3)-1) s4 += i + " ";
		else s4 += i;
		c += 1;
	}
	return s4;
}

// Determine whether a word is a noun. Debug mode can be used to skip the postagger; all nouns for tested specifications are already stored in a list.
bool isNoun(str word, bool debug) {
	if(debug) {
		list[str] nounsInSpecification = ["OnUsCreditTransfer","batchId","orderingAccount","beneficiaryAccount","requestedExecutionDate","actualExecutionDate","receivedTime","amount","rejectReasons","idd","book","counterBook","init","sepaCountryCodes","currency","date","countryCode","ExternalAccount","nextCorrectExecutionDate","deposit","receivedDate"];
		//list[str] nounsInSpecification = ["KwartaalLimiet","accountNumber","limit","isPositiveForADayWithinThreeMonths","balance","allowedLimitMin","allowedLimitMax","initialLimit","initialInterestRate","init","interest","waitingForApproval","amount"];
		//list[str] nounsInSpecification = ["Transaction","id","amount","start","book","uninit","Account","currency","deposit"];
		return word in nounsInSpecification;
	}

	// Call the postagger
	return (/[a-zA-Z]\_NN/ := tagString(word));
}

// Get the functionbody given the name of a function and return it as an expression
expression getFunctionBody(str functionName, list[functiondef] functions) {
	for(i <- functions) {
		if(functionName == i.f.v) return funcBody(i.s);
	}
	return funcBody(functions[0].s);
}


// delete whitespace characters from a string
str deleteWhitespace(str s) {
	str newString = "";
	for(i <- ["\n", "\t", "\r"]) {
		newString = replaceAll(s, i, "");
	}
	return newString; 
}

// Remove capital at the beginning of a string
str removeFirstCapital(str word) {
	if(/^<letter:[A-Z]><rest:.*$>/ := word){
     	return toLowerCase(letter) + rest;
   	} 
   	return word;
}

// Capitalize the first letter of a string	
str capitalize(str word) {
	if(/^<letter:[a-z]><rest:.*$>/ := word) {
 		return toUpperCase(letter) + rest;
	} 
	else if(/^<letter1:\*><letter2:[a-z]><rest:.*$>/ := word) {
		return "*" + toUpperCase(letter2) + rest;
	}
 	return word;
}

// Determine conjunction or puntuation mark between two elements of the list
	str listSummation(int c, int size, "commaAnd") {
		if(c <= size - 2) return ", ";
		else if(c == size - 1) return ", and ";
		else elem = return "";
	}	
	
// Determine Capitals are added at the start of a new line. between two elements of the list. The token depends on where we are in the list
	str listSummation(int c, int size, "commaOr") {
		if(c <= size - 2) return ", ";
		else if(c == size - 1) return ", or ";
		else elem = return "";
	}	
	
// Determine conjunction or puntuation mark between two elements of the list.
	str listSummation(int c, int size, "bullet") {
		if(c <= size - 2) return "\n";
		else if(c == size - 1) return "\n";
		else elem = return "";
	}	

// Place a space between two strings and no space after the last string
	str stringSummation(int count, int size) {
		if(count <= size - 1) return " ";
		else elem = return "";
	}
	
	
// Count number of strings in an element
int numberOfStrings(&T e) {
	int c = 0;
	for (/str st := e) {
		c += 1;
	}
	return c;
}
	
// Remove article from a string
str removeArticle(str s) {
	return visit(s) {
		case /^The |^the |^A |^a |^An |^an / => "" 	
	}
}

// Check whether a string exists; if yes, add a fullstop at the end of the string
str fullstop(list[&T ] l) {
	if(!isEmpty(l)) return ".";
	else return "None";
}
	
// Improve readibility: remove dubble spaces, remove whitespace before punctuation mark, and capatalize first word after fullstop.
str lastImprovements(str s) {
	return visit(s) {
		case /  / => " "
		case / ,/ => ","
		case / . <x:[a-zA-Z0-9_]>/ => ". " + capitalize(x)
	}
}
