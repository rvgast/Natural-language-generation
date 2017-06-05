module gen::naturallanguage::Structuring

import gen::naturallanguage::Types;
import gen::naturallanguage::AuxilaryFunctions;

import List;
import IO;
import String;
// The module Structuring converts the refined messages into the output text. Stucture and layout are added or improved. Messages are stored as strings in an 
// ADT. The strings are extracted from the ADT and returned as a single string. Readibiliy is improved by adding structure to selected places of the output: 
// bullets, interpunction, newlines, capitals. 
// Input: ADT with refined lexicalized messages (strings) as leafs
// Output: String with structure

// structure() extracts the strings from the ADT and adds structure to it.
str structure(LexSpecification m) {
	
	// This function takes an ADT extEventType as input and calls for the extraction of all the string values for each subADT in extEventType. It returns the built string.
	str getEvents(list[LexEventType] e) {
		str events = "";
		
		for(i <- e) {
			events += "## <getStrings(i.eventName)>" +
			"\n**Parameters:** <getStrings(i.parameters, "commaAnd")><fullstop(i.parameters)>" +
			"\n\n**State before**: <getStrings(i.stateFrom, "commaOr")>" +
			"\n\n**Preconditions**: \n <getStrings(i.preconditions, "bullet")><fullstop(i.preconditions)>" +
			"\n\n**Synchronization**:\n <getStrings(i.syncExpression, "bullet")><fullstop(i.syncExpression)>" +
			"\n\n**Postconditions**:\n <getStrings(i.postconditions, "bullet")><fullstop(i.postconditions)>" +
			"\n\n**State after**: <getStrings(i.stateTo, "commaOr")> \n\n";
		}
		
		return events;
	}
	
	// The extracted string from the extspec ADT is returned. An auxilary function to extract the strings from the extEventType ADT is called.
	str output = "# <getStrings(m.specName)>" + 
			"\n<getStrings(m.annotation)>" + 
			"\n\n**Fields**: \n <getStrings(m.fields, "bullet")><fullstop(m.fields)>" +
			"\n\n**Events**: <getStrings(m.events, "commaAnd")><fullstop(m.events)>" +  
			"\n\n<getEvents(m.ev)>";
	
	// Some final improvements
	output2 = lastImprovements(output);
	
	return output2;
}
	
// getStrings() extract strings from the list of messages and add bullets, punctuation and newlines. getStrings() comes in four types. A list of messages is 
// either converted into a comma-separated list with conjuctions, or converted to a comma-separated list with disjunctions, or converted to a 
// bullet list, or a messages converted to a single element. For each element (an ADT), each string is extracted and concatenated to the newely 
// created string. listSummation() is called to determine how the strings should be connected to each other. Capitals are added at the start of a 
// new line.

str getStrings(list[&T] messages, "commaAnd") {
	str newString = "";
	int countElements = 1;
	
	for(i <- messages) {
		int countStrings = 1;
		
		// The counts keep track of the position in the string. On specific places capitals and conjunctions are added
		for (/str st := i) {
			if(countElements == 1 && countStrings == 1) newString += capitalize(st) + stringSummation(countStrings, numberOfStrings(i));
			else newString += st + stringSummation(countStrings, numberOfStrings(i));
			countStrings += 1;
		}
		
		newString += listSummation(countElements, size(messages), "commaAnd");
		countElements += 1;
	}
	
	return newString;
}

str getStrings(list[&T] messages, "commaOr") {
	str newString = "";
	int countElements = 1;
	
	for(i <- dup(messages)) {
		int countStrings = 1;
		
		// The count keeps track of the position in the string. On specific places conjunctions are added
		for (/str st := i) {
			newString += st + stringSummation(countStrings, numberOfStrings(i));
			countStrings += 1;
		}
		
		newString += listSummation(countElements, size(dup(messages)), "commaOr");
		countElements += 1;
	}
	
	return newString;
}

str getStrings(list[&T] messages, "bullet") {
	str newString = "\n";
	int countElements = 1;
	
	for(i <- messages) {
		newString += "* ";
		int countStrings = 1;
		
		// The counts keep track of the position in the string. On specific places capitals and conjunctions are added
		for (/str st := i) {
			if(countStrings == 1) newString += capitalize(st) + stringSummation(countStrings, numberOfStrings(i));
			else newString += st + stringSummation(countStrings, numberOfStrings(i));
			countStrings += 1;
		}
		
		newString += listSummation(countElements, size(messages), "bullet");
		countElements += 1;
	}
	
	return newString;
}

str getStrings(&T f) {
	str newString = "";
	countElements = 1;
	
	// The count keeps track of the position in the string. On specific places capitals are added
	for (/str st := f) {
		if(countElements == 1) newString += capitalize(st) + " ";
		else newString += st + " ";
		countElements += 1;
	}
	
	return newString;
}

	
