module gen::naturallanguage::Linearization

import lang::ExtendedSyntax;
import gen::naturallanguage::Types;
import gen::naturallanguage::Lexicalization;
import gen::naturallanguage::AuxilaryFunctions;

import IO;
import List;

// The module Linearization determines what messages (as is it called in literature) should be communicated and in what order. Linearization is independent to 
// the output language. The messages are extracted from the inlined module and placed into an Algebraic Data Type called specification (specified in AllTypes.rsc).
// Input: inlined module of a specification
// Output: ADT with parts of the inlined module as leafs

// Lineariztion() extracts parts of the Rebel tree and places them in a constructed specification ADT
LinSpecification linearize(Module t) {
	// Specification name
	TypeName name = t.spec.name;  
	
	// Specification annotation (incl deletion of unwanted whitespace)
	list[str] annotation = [ deleteWhitespace("<a.contents>") | /TagString a := t.spec.annos];
	
	// Specification fields
	list[FieldDecl] fields = [ f | /FieldDecl f := t.spec];
	
	// Eventnames (order is conform the lifecycle)
	list[StateVia] eventNames = dup([ s | /StateVia s := t]);

	// Functions
	list[FunctionDef] functions = [ f | /FunctionDef f := t];
	
	// Events		
	list[LinEventType] getEvents() {
		list[LinEventType] events = [] ;
		
		for(EventDef event <- t.spec.events.events) {
			list[FullyQualifiedVarName] name = [event.name];
			list[Parameter] par = [ p | /Parameter p := event];
			list[VarName] from = getFromState(event.name, t);
			list[Expr] pre = [ e | /(Statement)`<Annotations _> <Expr e>;` := event.pre];
			list[SyncExpr] sync = [ s | /SyncExpr s := event.sync];
			list[Expr] post = [ e | /(Statement) `<Annotations _> <Expr e>;` := event.post];
			list[VarName] to = getToState(event.name, t);
			
			events += ev(name, par, from, pre, sync, post, to);
		}
		
		return events;
	}
			
	// eventTypes are sorted according to the order of eventNames
	list[LinEventType] orderEvents() {
		list[LinEventType] orderedEvents = [];
		
		for(i <- eventNames) {
			for(j <- getEvents()) {
				if("<i>" == "<j.eventName[0]>") orderedEvents += j;
			}
		}	
		
		return orderedEvents;
	}
	
	return sp(name, annotation, fields, eventNames, orderEvents(), functions);		
}

// get the fromState from a given event 
list[VarName] getFromState(FullyQualifiedVarName event, Module t) = [] when (!(t.spec has lifeCycle));

default list[VarName] getFromState(FullyQualifiedVarName event, Module t) {
	set[str] getStateVia(p) = {"<v>" | /StateVia i := p, /VarName v := i};
	return [i.from | /StateFrom i := t.spec.lifeCycle.from, "<event>" in getStateVia(i)];
}

// get the toState from a given event
list[VarName] getToState(FullyQualifiedVarName event, Module t) = [] when (!(t.spec has lifeCycle));

default list[VarName] getToState(FullyQualifiedVarName event, Module t) {
	set[str] getStateVia(p) = {"<v>" | /StateVia i := p, /VarName v := i};
	return [i.to | /StateTo i := t.spec.lifeCycle.from, "<event>" in getStateVia(i)];
}

