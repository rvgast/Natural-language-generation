package gen.naturallanguage;

import java.io.DataInputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Properties;

import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.library.experiments.Compiler.RVM.Interpreter.RascalRuntimeException;
import org.rascalmpl.uri.URIResolverRegistry;
import org.rascalmpl.uri.file.FileURIResolver;
import org.rascalmpl.value.IBool;
import org.rascalmpl.value.ISourceLocation;
import org.rascalmpl.value.IString;
import org.rascalmpl.value.IValueFactory;

import edu.stanford.nlp.tagger.maxent.MaxentTagger;
import edu.stanford.nlp.util.StringUtils;

public class PosTagger {
    private final IValueFactory values;
    private static final String DEFAULT_TAG_FILE = "pos-models/english-bidirectional-distsim.tagger";
    //"pos-models/english-left3words-distsim.tagger";

    public PosTagger(final IValueFactory values) {
    	this.values = values;
    }
    
    public IString tagString(final IString input, final ISourceLocation modelPath) {
    	try {
			DataInputStream in = new DataInputStream(URIResolverRegistry.getInstance().getInputStream(modelPath));
		   	final MaxentTagger tagger = new MaxentTagger();

		   	final Properties p = StringUtils.argsToProperties("-model", modelPath.getPath());
		   	final Method init = tagger.getClass().getDeclaredMethod("readModelAndInit", Properties.class, DataInputStream.class, boolean.class);
		   	init.setAccessible(true);
		   	init.invoke(tagger, p, in, true);
	
	    	return values.string(tagger.tagString(input.getValue()).trim());
		}
    	catch (IOException e) {
			throw RuntimeExceptionFactory.io(values.string("IO Exception"), null, null);
		}
    	catch (NoSuchMethodException e) {
    		throw RuntimeExceptionFactory.io(values.string("No Such Method Exception " + e), null, null);
		}
    	catch (SecurityException e) {
    		throw RuntimeExceptionFactory.io(values.string("IO Exception"), null, null);
		}
    	catch (IllegalAccessException e) {
    		throw RuntimeExceptionFactory.io(values.string("Illegal Access Exception"), null, null);
		}
    	catch (IllegalArgumentException e) {
    		throw RuntimeExceptionFactory.io(values.string("Illegal Argument Exception"), null, null);
		}
    	catch (InvocationTargetException e) {
    		throw RuntimeExceptionFactory.io(values.string("Invocation Target Exception"), null, null);
		}	
    }
}