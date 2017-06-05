module gen::naturallanguage::MessageRefinement

import gen::naturallanguage::Types;
import gen::naturallanguage::PosTagger;
import gen::naturallanguage::AuxilaryFunctions;

import IO;
import String;
import List;

// The module Message Refinement improves readiblity and fluency of the lexicalized messages. Several modification are implemented to refine the future output text: 
// - remove camelcase from identifiers and separate the words
// - add an indefinite article before fields, parameters and specName that are nouns (with help of a pos-tagger)
// - add a definite article before other nouns (with help of a pos-tagger)
// - add adhoc text to improve understandability
// - replace function call with the body of the function
// - correct some mistakes of the pos-tagger
// Input: ADT with lexicalized messages (strings) as leafs
// Output: ADT with refined lexicalized messages (strings) as leafs

// MessageRefinement() visits the ADT with lexicalized messages and modifies the messages
LexSpecification refineMessages(LexSpecification specs, bool debug) {
	// Visit the subADT's with messages and manipulate specific parts
	&T visitSubADT(&T subADT, str typeOf) {
		return visit(subADT) {
			
			// refine phrases
			// a fqvn (FullyQualifiedVarName) is explicitly related to an event
			case varname(str s) => varname(refineStrings(s, typeOf, debug))
			case fqvn(str s) => fqvn(refineStrings(s, typeOf, debug) + " of the processed event")
			case this(str s) => this(refineStrings(s, typeOf, debug))
			case fqn(str s) => fqn(refineStrings(s, typeOf, debug))
			case tn(str s) => tn(refineStrings(s, typeOf, debug))
			
			// Add conjunctions and punctuation marks between elements of a set
			case exprset(s1, eset, s2) => exprset(s1, listSommation(eset),s2) 
			case paramset(s1, par, s2) => paramset(s1, listSommation(par), s2) 
			case varnameset(s1, var, s2) => varnameset(s1, listSommation(var), s2) 
			
			// Make type in "set of <type>" plural
			case settipe(s1, simple(s2)) => settipe(s1, simple(s2 + "s"))
	 	}
	 }
	
	// Divide the ADT in subADT's to visit each subADT separetly; extra type information is added
	specs1 = top-down visit(specs) {
		case extsp(specName, annotation, fields, events, ev, functions) => extsp(visitSubADT(specName, "specName"), visitSubADT(annotation, "annotation"), visitSubADT(fields, "fields"), visitSubADT(events, "events"), ev, visitSubADT(functions, "functions"))
		case extev(eventName, parameters, stateFrom, preconditions, syncExpression, postconditions, stateTo) => extev(visitSubADT(eventName, "eventName"), visitSubADT(parameters,"parameters"), visitSubADT(stateFrom, "stateFrom"), visitSubADT(preconditions, "preconditions"), visitSubADT(syncExpression, "syncExpression"), visitSubADT(postconditions, "postcondition"), visitSubADT(stateTo, "stateTo"))
	}
	 	
 	specs2 = visit(specs1) {
 		// Replace a function call with the body of the function
		case func(varname(v),_,_) => getFunctionBody(v, specs1.functions) 	
 		
 		// Change '(the) date of now' in '(the) current date'
 		case fieldAcc(varname(x),_,literal(dtime(now(_)))) => fieldAcc(varname("the current date"))  
 		
 		// Remove articles from events (the pos-tagger identifies some eventnames (e.g. book) as a noun. To correct this articles before eventnames are removed)
 		case via(varnameset([varname(v)])) => via(varnameset([varname(removeArticle(v))]))
 		case extev([fqvn(varname(v))], x1, x2, x3, x4, x5, x6) => extev([fqvn(varname(removeArticle(v)))], x1, x2, x3, x4, x5, x6)
 	}
 	
  	return specs2;
}

// Call the functions that refine a string by 1) adding articles to nouns and 2) remove camelcase and 3) add markdown to identifier
str refineStrings(str s, str typeOf, bool debug) {
		
	str article = isNoun(s, debug) ? addArticle(s, typeOf) : "";
	
	str decapWord = removeFirstCapital(s);
	
	// remove camelcase of strings
	str splittedWord = /[A-Z]*[a-z]+[A-Z][a-zA-Z]*/ := decapWord ? removeCamelCase(decapWord) : decapWord;
	
	return article + "*" + splittedWord + "*";
}

// Add an article before a word. The article type depends on the ADT type of the word and the first letter of the word.
str addArticle(str s, typeOf) {
	
	// List of types that is given an indefinite article
	list[str] indefiniteList = ["specName", "fields", "parameters"];
	
	// Add an indefinite article to a word
	str indefinite(str s) {
		if(rexpMatch(s, "^[aeiouAEIOU].*")) return "an "; else  return "a ";
	}
	
	// Add a definite article to a word
	str definite(str s) {
		return "the ";
	}

	return (typeOf in indefiniteList ?  indefinite(s) :  definite(s));	
}
