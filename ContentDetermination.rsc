module gen::naturallanguage::ContentDetermination

import gen::GeneratorUtils;
import lang::Builder;

// The module Content Determinination extracts all information of a specification and generates a Rebel parse tree with that information.
// Input: location of an ING-specification file
// Output: Built of the specification
// alias Built = tuple[Module inlinedMod, Module normalizedMod, Refs refs, map[loc, Type] resolvedTypes, UsedBy usedBy] in file Builder.rsc

Built determineContent(loc specification) = b when just(Built b) := loadModule(specification);

