module gen::naturallanguage::PosTagger

// This file defines functions to call the part-of-speech tagger

@javaClass{gen.naturallanguage.PosTagger}
java str tagString(str input, loc modelPath);

str tagString(str input) = tagString(input, |project://ing-rebel-generators/pos-models/english-left3words-distsim.tagger|);
str tagString(str input, loc languageFile) = tagString(input, languageFile);
