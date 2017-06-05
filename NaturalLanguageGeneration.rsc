module gen::naturallanguage::NaturalLanguageGeneration

import lang::Parser;
import gen::GeneratorUtils;
import gen::tests::GeneratorTest;
import lang::Builder;
import lang::ExtendedSyntax;
import gen::documentation::PropertiesFileReader;
import gen::documentation::docgen::DocumentGenerator;

import gen::naturallanguage::ContentDetermination;
import gen::naturallanguage::Linearization;
import gen::naturallanguage::Lexicalization;
import gen::naturallanguage::MessageRefinement;
import gen::naturallanguage::Structuring;
import gen::naturallanguage::Types;

import IO;
import ParseTree;
import Set;
import String;
import Node;

 
// The Natural Language Generation System (NLGS) takes a ING-specification as input and has a verbalization of the specification as output.
// The NLGS consists of five sequential modules (There is no consensus in literature on how to denote the parts of a NLG System. I choose to use the Rascal 
// term 'Module', because every part of the NLG System is implemented into its own module), where each module's output acts as the input for the following 
// module. The output of the system is delivered in pdf format. The call for modules are separated into two functions, such that naturallanguage generation 
// can also be called from GeneratorUtils.rsc.
// Module 1: Content Determination
// Module 2: Linearization
// Module 3: Lexicalization
// Module 4: Message Refinement
// Module 5: Structuring
// The NLG system is extensively tested for OnUsCreditTransfer. The lexicalization module covers at least OnUsCreditTranfer, Transaction, and KwartaalLimiet.

// TestNLG() declares hardcoded input and output locations for the NLG System. For test purpuses. To run the NLG System on one of the tested specifications: 
// 1) uncomment the desired specI
// 2) To avoid the time consuming pos-tagger: uncomment the related list in isNoun() in the AuxilaryFunctions file
void testNLG() {
	// Location of the input specification
	loc specI = |project://ing-specs/src/booking/sepa/ct/OnUsCreditTransfer.ebl|;
	// loc specI = |project://rebel-core/examples/simple_transaction/Transaction.ebl|;
	// loc specI = |project://ing-specs/src/account/payment/limit/KwartaalLimiet.ebl|;
	
	// Location of the output specification	
	loc specO = |file:///Users/renevangasteren/Documents/Information%20Science/Scriptie/Workspace/rebel/ing-rebel-generators-master/src/gen/naturallanguage/specification.md|;
	
	startNLG(specI, specO, true);	
}

// startNLG() starts the natural generation system and given the input and output file, and calls the first module. The function can be called in debug mode 
// that includes printing the recursion steps in the lexicalization module, and skipping the pos-tagger. 
void startNLG(loc input, loc output) = startNLG(input, output, false);

void startNLG(loc input, loc output, bool debug) {
	// Call module 1: content determination
	Built m = determineContent(input);
	
	// Call other modules
	generateNaturalLanguage(m, output, debug);
}

// generateNaturalLanguage() calls module 2-5
void generateNaturalLanguage(Built m, loc outputLocation, bool debug) {
	// Create file with specification tree (i.e inlined Module)
	Module t = m.inlinedMod;
		
	// Call module 2: linearization
	LinSpecification linSpec = linearize(t);
	
	// Call module 3: lexicalisation
	LexSpecification lexSpecs = lexicalize(linSpec, debug);
	
	//Call module 4: message refinement
	LexSpecification refinedSpecs = refineMessages(lexSpecs, debug);
	
	//Call module 5: structuring
	str outputText = structure(refinedSpecs);
	
	generateOutputFile(outputLocation, outputText);
}

// generateOutputFile creates a markdown file and transforms it into pdf
void generateOutputFile(loc outputLocation, str outputText) {
	// create a file with output in markdown 
	writeFile(outputLocation, outputText);
	println("TEST");
	println(outputLocation);
	
	// create a pdf file 
	generateDoc(outputLocation, pdf(), readPropertiesFile(|project://ing-rebel-generators/src/gen/naturallanguage/settings.properties|));
}


