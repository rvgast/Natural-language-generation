module gen::naturallanguage::Types

import lang::ExtendedSyntax;

// ADT's to store linearilized Rebel specification (i.e. output of component Linearization). The ADT store parts of the inlined Module.
data LinSpecification = sp(TypeName specName, list[str] annotation, list[FieldDecl] fields, list[StateVia] events, list[LinEventType] ev, list[FunctionDef] functions);
data LinEventType = ev(list[FullyQualifiedVarName] eventName, list[Parameter] parameters, list[VarName] stateFrom, list[Expr] preconditions, list[SyncExpr] syncExpression, list[Expr] postconditions, list[VarName] stateTo); 
 
// ADT's to store lexicalized messages (i.e. output of component Lexicalization). Messages are lexicalized as ADT with strings as leafs.
data LexSpecification = extsp(typename specName, list[str] annotation, list[fielddeclaration] fields, list[statevia] events, list[LexEventType] ev, list[functiondef] functions);
data LexEventType = extev(list[fqvn] eventName, list[parameter] parameters, list[varname] stateFrom, list[expression] preconditions, list[syncexpression] syncExpression, list[expression] postconditions, list[varname] stateTo); 

data fqvn = fqvn(varname v);

data statevia = via(varnameset v);

data functiondef = func(fqvn f, str s1, parameterset p, str s2, tipe t, str s3, statement s);

data configparameter = cparam(varname v, str s, expression e);

data parameter = param(varname v, str s, tipe t, defaultval d) | param(varname v, str s, tipe t);

data defaultval = dv(str s);

data syncexpression = synce(varname v, expressionset p, str s1, typename t, str s2, typename t, str s3, expression e);

data statement = brackets(statement st) | anex(str s, expression e);

data expression = brackets(expression e)
				| expr(expression e1, str op, expression e2) 
				| literal(literal l)
				| refer(reference r) 
				| func(varname v, str s, expressionset es)
				| fieldAcc(varname f, str s, expression e) | fieldAcc(expression e, varname f) | fieldAcc(varname f) // Type used for refining '<x> of now'
				| varAcc(expression i, str s, expression e)
				| staticSet(str s, expressionset es)
				| new(expression e)
				| condition(str s1, expression e1, str s2, str s3, expression e2, str s4, str s5, expression e3)
				| zed(expression e, str s)
				| ifthen(str s1, expression e1, str s2, str s3, expression e2)
				| funcBody(statement st) // Type used for getFunctionBody
				;

// List of value in order to add summation words as strings
data expressionset = exprset(list[value] exp); 
data parameterset = paramset(list[value] par); 
data varnameset = varnameset(list[value] var) | varnamesettemp(varname); 

data stateref = stateref(varname v);

data mapelement = mapelem(expression e1, str s, expression e2);

data fielddeclaration = fielddecl(varname v, str s, tipe t);

data tipe = simple(str s) 
			| mapp(tipe t1, str s, tipe t2) 
			| settipe(str s1, tipe t)
			| term(term tt)
			| func(str s, tipe t1, str s2, tipe t2)
			| moretipes(str s1, str s2, str s3)
			;

data reference = fqvn(str f) | fqn(str f) | this(str s) | itt(str s); 
data literal = integer(integer i) 
			| boolean(boolean b)
			| period(period p)
			| frequency(frequency f)
			| tm(term t)
			| date(date d)
			| time(time tm)
			| dtime(dtime dt)
			| percentage(percentage per)
			| strin(strin s)
			| money(money m) 
			| currency(currency c)
			| iban(iban ib)
			;

data date = dmy(str d, str m, str y);

data time = hms(str s1, str s2, str s3, str s4, str s5);

data dtime = dt(date d, time t) | now(str s);

data term = facper(integer s1, period s2);
data money = m1(amount a, currency c);
data amount = amount(str a);
data currency = euro(str s) | dollar(str s) | other(str s);
data iban = ib(str s);
data typename = tn(str s);
data varname = varname(str v);

data month = m(str s);
data frequency = fq(str s);
data period = p(str s);
data boolean = b(str s);
data percentage = perc(str s1);
data integer = inte(str s);
data strin = stri(str s);
