module gen::naturallanguage::Lexicalization
import lang::Parser;
import gen::GeneratorUtils;
import lang::ExtendedSyntax;
import gen::tests::GeneratorTest;
import lang::Builder;
import lang::TypeInferrer;

import gen::naturallanguage::MessageRefinement;
import gen::naturallanguage::Types;
import gen::naturallanguage::AuxilaryFunctions;

import IO;
import ParseTree;
import Set;
import String;


// The module Lexicalization determines how the messages are translated to the target language (in this case English). Based on the Rebel syntax an Algabraic 
// data type is build (specified in AllTypes.rsc) with strings as leafs. This module is based on the Grammatical Framework (Ranta (2004)). The component takes 
// the ADT with ordered messages as an input and recursively builds a new ADT and lexicalize each message.
// Input: ADT with parts of the inlined module as leafs
// Output: ADT with lexicalized messages (strings) as leafs
// This module is tested on four Rebel specifications: OnUsCreditTransfer,

// The println()'s are kept for debug purposes.

// lexicalization() calls for lexicalization of the content of the linearized messages
LexSpecification lexicalize(LinSpecification m, bool debug) {
	// All (recursive) lexicalization rules
	// For testing purpuses print statements are included                         
	fqvn lex(FullyQualifiedVarName f) {
		println(55);
		println(f);
		return fqvn(lex(f.name));
	}
		
	statevia lex(StateVia e) {
		println(56);
		println(e);
		return via(lex(e.refs));
	}
	
	functiondef lex(FunctionDef f) {
		println(57);
		println(f);
		return func(lex(f.name), "given", lex(f.params), "in", lex(f.returnType), "=", lex(f.statement));
	}
	
	configparameter lex(ConfigParameter c) {
		println(58);
		println(c);
		return cparam(lex(c.name), "=", lex(c.val));
	}
	
	parameter lex(Parameter p) {
	 	println(59);
	 	println(p);
	 	if(lex(p.defaultValue) == "") return param(lex(p.name), "in", lex(p.tipe), lex(p.defaultValue));
	 	else return param(lex(p.name), "in", lex(p.tipe));
	}
	
	defaultval lex(DefaultValue? d) {
		println(60);
		//println(d);
		return dv("<d>");
	} 
	
	syncexpression lex(SyncExpr e) {
		println(62);
		println("<e.specName>[<e.id>]. <e.event> (<e.params>)" );
		return synce(lex(e.event), lex(e.params), "of", lex(e.specName), ", for which", lex(e.specName), "is identified by", lex(e.id));
	}
	
	statement lex((Statement)`(<Statement s>)`) {println(63); println("<s>"); return brackets(lex(s));}
	str lex((Statement)`case <Expr e> { <Case+ cases> } ;`) {println(64); println(s); return "<lex(e)> <lex(cases)>";}
	statement lex((Statement)`<Annotations annos> <Expr e> ;`) {println(65); println("<annos> <e>"); return anex("<annos>", lex(e));}
	
	//str lex(Case c) {println(66); println(c); return "<c.lit> =\> <c.stat>";}
	
	
	// Lexicalization of expressions
	expression lex((Expr) `( <Expr e> )`) {println(68); println("<e>"); return brackets(lex(e));}
	expression lex((Expr) `<Literal lit>`) {println(69); println("<lit>"); return literal(lex(lit));}
	expression lex((Expr) `<Ref ref>`) {println(70); println("<ref>"); return refer(lex(ref));}
	expression lex((Expr) `<VarName function>(<{Expr ","}* exprs>)`) {println(71); println("<function> <exprs>"); return func(lex(function), "given", lex(exprs));}
	expression lex((Expr) `<Expr lhs> . <VarName field>`) {println(72); println("<lhs> <field>"); return fieldAcc(lex(field), "of", lex(lhs));}
	expression lex((Expr) `{ <Expr lower> .. <Expr upper> }`) {println(73); return lowup("{", lex(lower), "..", lex(upper), "}");}
	expression lex((Expr) `<Expr var> [ <Expr indx> ]`) {println(74); println("<var> <indx>"); return varAcc(lex(var), "identified by", lex(indx));}
	expression lex((Expr) `( <{MapElement ","}* mapElems> )`) {println(75); println("<mapElems>"); return mapel(lex(mapElems));}
	expression lex((Expr) `{ <{Expr ","}* setElems> }`) {println(76); return staticSet("the options:", lex(setElems));}
	expression lex((Expr) `{ <VarName elemName> : <Expr st>|<{Expr ","}+ conditions>}`) = comprehension(lex(elemName), lex(st), lex(conditions));
	expression lex((Expr) `| <Expr st> |`) = cardinality(lex(st));
	expression lex((Expr) `forall <VarName elemName> : <Expr st> | <{Expr ","}+ conditions>`) = quantifier("forall",lex(elemName), lex(st), lex(conditions));
	expression lex((Expr) `exists <VarName elemName> : <Expr st> | <{Expr ","}+ conditions>`) = quantifier("exist", lex(elemName), lex(st), lex(conditions));
	expression lex((Expr) `new <Expr expr>`) {println(81); return new(lex(expr));}
	expression lex((Expr) `not <Expr expr>`) {println(82); return not("not", lex(expr));}
	expression lex((Expr) `- <Expr e>`) {println(83); return min("-", lex(e));}
	expression lex((Expr) `<Expr cond> ? <Expr whenTrue> : <Expr whenFalse>`) {println(83.5); return condition("if", lex(cond), ",", "then", lex(whenTrue), ",", "else", lex(whenFalse)) ;}
	expression lex((Expr) `<Expr lhs> * <Expr rhs>`) {println(84); return expr(lex(lhs), "multiplied by", lex(rhs));}
	expression lex((Expr) `<Expr lhs> in <Expr rhs>`) {println(85); return expr(lex(lhs), "is one of", lex(rhs));}
	expression lex((Expr) `<Expr lhs> / <Expr rhs>`) {println(86); return expr(lex(lhs), "divided by", lex(rhs));}
	expression lex((Expr) `<Expr lhs> % <Expr rhs>`) {println(87); return expr(lex(lhs), "modulo", lex(rhs));}
	expression lex((Expr) `<Expr lhs> + <Expr rhs>`) {println(88); return expr(lex(lhs), "added to", lex(rhs));}
	expression lex((Expr)`<Expr lhs> - <Expr rhs>`) {println(89);  return expr(lex(lhs), "subtracted by", lex(rhs)); }
	expression lex((Expr) `<Expr lhs> \< <Expr rhs>`) {println(90); return expr(lex(lhs), "is smaller than", lex(rhs)) ;}
	expression lex((Expr) `<Expr lhs> \<= <Expr rhs>`) {println(91); return expr(lex(lhs), "is smaller than or equal to", lex(rhs)) ;}
	expression lex((Expr) `<Expr lhs> \> <Expr rhs>`) {println(92); println("<lhs> <rhs>"); return expr(lex(lhs), "is greater than", lex(rhs));}
	expression lex((Expr) `<Expr lhs> \>= <Expr rhs>`) {println(93); println("<lhs> <rhs>"); return expr(lex(lhs), "is greater than or equal to", lex(rhs));}
	expression lex((Expr) `<Expr lhs> == <Expr rhs>`) {println(94); println("<lhs> <rhs>"); return expr(lex(lhs), "is equal to", lex(rhs));}
	expression lex((Expr) `<Expr lhs> != <Expr rhs>`) {println(95); println("<lhs> <rhs>"); return expr(lex(lhs), "is not equal to", lex(rhs));}
	expression lex((Expr) `initialized <Expr ex>`) {println(96); println("<ex>"); return zed(lex(ex), "is initialized");}
	expression lex((Expr) `finalized <Expr ex>`) {println(97); return zed(lex(ex), "is finalized");}
	expression lex((Expr) `<Expr lhs> instate <StateRef sr>`) {println(98); println("<lhs> <sr>"); return expr(lex(lhs), "instate", lex(rhs));}
	expression lex((Expr) `<Expr lhs> && <Expr rhs>`) {println(99); return expr(lex(lhs), "and", lex(rhs)) ;}
	expression lex((Expr) `<Expr lhs> || <Expr rhs>`) {println(100); return expr(lex(lhs), "or", lex(rhs)) ;}
	expression lex((Expr) `<Expr cond> -\> <Expr implication>`) {println(101); return ifthen("if", lex(cond), ",", "then", lex(implication)) ;}
	default expression lex(Expr e) {
		throw "failed to lex <e>";
	}
	
	// Lexicalisation of sets	
	expressionset lex({Expr ","}* e) { 
		println(102);
		list[expression] l = [];
		for(i <- e) {
			l = l + (lex(i));
		}
		return exprset(l);
	}
	
	parameterset lex({Parameter ","}* p) { 
		println(102.5);
		list[parameter] l = [];
		for(i <- p) {
			l = l + lex(i);
		}
		return paramset(l);
	}
	
	varnameset lex({VarName  "," }+ v) {
		list[varname] l = [];
		for(i <- v) {
			l = l + lex(i);
		}
		return varnameset(l);
	}
		
	
	stateref lex((StateRef) `<VarName state>`) {println(103); println("<state>"); return stateref(lex(state));}
	str lex((StateRef) `{<VarName+ states>}`) {
		println(101); 
		list[varname] l = [];
		for(i <- states) {
			l = l + lex(i);
		}
		return  varnameset("{", l, "}");
	}
	mapelement lex(MapElement m) {println(104); println("<m>"); return mapelem(lex(m.key), ":", lex(m.val));}
	
	fielddeclaration lex(FieldDecl f) {println(105); println("<f>"); return fielddecl(lex(f.name), "in", lex(f.tipe));}
	
	// Lexicalization of types
	tipe lex((Type)`Boolean`) = simple("boolean"); 
	tipe lex((Type)`Period`) = simple("period");
	tipe lex((Type)`Integer`) = simple("integer");
	tipe lex((Type)`Money`) = simple("money");
	tipe lex((Type)`Currency`) = simple("currency");
	tipe lex((Type)`Date`) = simple("date");
	tipe lex((Type)`Frequency`) = simple("frequency");
	tipe lex((Type)`Percentage`) = simple("percentage");
	tipe lex((Type)`Period`) = simple("period");
	tipe lex((Type)`Term`) = simple("term");
	tipe lex((Type)`String`) = simple("string");
	tipe lex((Type)`map [ <Type t1> : <Type t2> ]`) = mapp(lex(t1), "mapped on", lex(t2));
	tipe lex((Type)`set [ <Type t> ]`) = settipe("set of", lex(t));
	tipe lex((Type)`<Term t>`) = term(lex(t));
	tipe lex((Type)`Time`) = simple("time");
	tipe lex((Type)`IBAN`) = simple("IBAN");
	tipe lex((Type)`<Type t1>-\><Type t2>`) = func("function of", lex(t1), "to", lex(t2));
	tipe lex((Type)`( <{Type ","}+ t> )`) { 
		println(116);
		str l = "";
		for(i <- t) {
			l += "<lex(i)>, ";
		}
		return moretipes("{", l, "}");
	}
	tipe lex((Type)`<TypeName custom>`) = simple("<custom>");
	
	
	reference lex((Ref) `<FullyQualifiedVarName field>`) {println(111); println(field); return fqvn("<field>");}
	reference lex((Ref) `<FullyQualifiedName tipe>`) {println(112); return fqn("<tipe>");}
	reference lex((Ref) `this`) {println(113); return this("<m.specName>");}
	reference lex((Ref) `it`) {println(115); return itt("it");}
	
	
	// Lexicalization of literals
	literal lex((Literal)`<Int i>`) = integer(lex(i));
	literal lex((Literal)`<Bool b>`) = boolean(lex(b));
	literal lex((Literal)`<Period p>`) = period(lex(p));
	literal lex((Literal)`<Frequency f>`) = frequency(lex(f));
	literal lex((Literal)`<Term term>`) = tm(lex(term));
	literal lex((Literal)`<Date d>`) = date(lex(d));
	literal lex((Literal)`<Time t>`) = time(lex(t));
	literal lex((Literal)`<DateTime d>`) = dtime(lex(d));
	literal lex((Literal)`<Percentage p >`) = percentage(lex(p));
	literal lex((Literal)`<String s>`) = strin(lex(s));
	literal lex((Literal)`<Money m>`) = money(lex(m));
	literal lex((Literal)`<Currency c>`) = currency(lex(c));
	literal lex((Literal)`<IBAN i>`) = iban(lex(i));
	
	date lex(Date d) = dmy(d("<d.day>"), lex(d.month), y("<d.year>"));
	
	time lex(Time t) = hms(h("<t.hour>"), ":", m("<t.minutes>"), ":", s("<t.seconds>"));
	
	dtime lex((DateTime)`<Date date>,<Time time>`) = dtime(lex(date), lex(time)); 
	dtime lex((DateTime)`now`) = now("now");
	
	term lex(Term t) = facper(lex(t.factor), lex(t.period));
	
	money lex(Money m) = m1(lex(m.amount), lex(m.cur));
	
	currency lex((Currency)`EUR`) = euro("Euro");
	currency lex((Currency)`USD`) = dollar("US Dollar");
	default currency lex(Currency c) = other("<c.name>");
	
	
	iban lex(IBAN i) = ib("<i>");
	typename lex(TypeName t) = tn("<t>");
	varname lex(VarName v) { println(117); println("<v>"); return varname("<v>");}
	
	month lex((Month)`Jan`) = m("January");
	month lex((Month)`Feb`) = m("February");
	month lex((Month)`Mar`) = m("March");
	month lex((Month)`Apr`) = m("April");
	month lex((Month)`May`) = m("May");
	month lex((Month)`Jun`) = m("June");
	month lex((Month)`Jul`) = m("July");
	month lex((Month)`Aug`) = m("August");
	month lex((Month)`Sep`) = m("September");
	month lex((Month)`Oct`) = m("October");
	month lex((Month)`Nov`) = m("November");
	month lex((Month)`Dec`) = m("December");
	
	frequency lex((Frequency)`Daily`) = fq("daily");
	frequency lex((Frequency)`Weekly`) = fq("weekly");
	frequency lex((Frequency)`Monthly`) = fq("monthly");
	frequency lex((Frequency)`Quarterly`) = fq("quarterly");
	frequency lex((Frequency)`Yearly`) = fq("yearly");
	
	period lex((Period)`Day`) = p("days");
	period lex((Period)`Week`) = p("weeks");
	period lex((Period)`Month`) = p("months");
	period lex((Period)`Quarter`) = p("quarters");
	period lex((Period)`Year`) = p("year");
	
	boolean lex((Bool)`True`) = b("true");
	boolean lex((Bool)`False`) = b("false");
	
	percentage lex(Percentage per) = perc("<per>");
	
	integer lex(Int i) = inte("<i>");
	
	strin lex(String s) = stri("<s>");
	
	amount lex(MoneyAmount m) = amount("<m.whole>.<m.decimals>");
	
	// Call to lexicalize each message in an event
	LexEventType lex(LinEventType e) {
	 	return extev( [lex(f) | f <- e.eventName], 
					[lex(f) | f <- e.parameters], 
					[lex(f) | f <- e.stateFrom], 
					[lex(f) | f <- e.preconditions], 
					[lex(f) | f <- e.syncExpression], 
					[lex(f) | f <- e.postconditions], 
					[lex(f) | f <- e.stateTo]);
	}

	// Call to lexicalize each message in a specification	
	return extsp(lex(m.specName),
				m.annotation,
				[lex(f) | f <- m.fields], 
				[lex(e) | e <- m.events],
				[lex(e) | e <- m.ev],
				[lex(f) | f <- m.functions]);	

}