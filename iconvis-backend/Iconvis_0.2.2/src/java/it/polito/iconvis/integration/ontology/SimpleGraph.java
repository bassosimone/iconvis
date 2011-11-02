/**
 * Copyright 2010-2011 Federico Cairo, Giuseppe Futia
 *
 * This file is part of ICONVIS.
 *
 * ICONVIS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ICONVIS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with ICONVIS.  If not, see <http://www.gnu.org/licenses/>.
 */

package it.polito.iconvis.integration.ontology;

import it.polito.iconvis.util.Constants;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import org.apache.log4j.Logger;
import org.openrdf.model.BNode;
import org.openrdf.model.Resource;
import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.Value;
import org.openrdf.model.ValueFactory;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.query.BindingSet;
import org.openrdf.query.GraphQuery;
import org.openrdf.query.TupleQuery;
import org.openrdf.query.TupleQueryResult;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.rio.RDFFormat;
import org.openrdf.rio.RDFParseException;
import org.openrdf.rio.RDFWriter;
import org.openrdf.rio.Rio;
import org.openrdf.sail.inferencer.fc.ForwardChainingRDFSInferencer;
import org.openrdf.sail.memory.MemoryStore;

public class SimpleGraph {

    protected static Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".integration.ontology");
    Repository therepository = null;
    static RDFFormat NTRIPLES = RDFFormat.NTRIPLES;
    static RDFFormat N3 = RDFFormat.N3;
    public static RDFFormat RDFXML = RDFFormat.RDFXML;
    static String RDFTYPE = RDF.TYPE.toString();

    public SimpleGraph() {
        this(false);
    }

    public SimpleGraph(boolean inferencing) {
        log.debug("[SimpleGraph::constructor] BEGIN");
        try {
            if (inferencing) {
                therepository = new SailRepository(new ForwardChainingRDFSInferencer(new MemoryStore()));

            } else {
                therepository = new SailRepository(new MemoryStore());
            }
            therepository.initialize();
            log.debug("[SimpleGraph::constructor] END");
        } catch (RepositoryException e) {
            e.printStackTrace();
        }
    }

    public org.openrdf.model.Literal Literal(String s, URI typeuri) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                ValueFactory vf = con.getValueFactory();
                if (typeuri == null) {
                    return vf.createLiteral(s);
                } else {
                    return vf.createLiteral(s, typeuri);
                }
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public org.openrdf.model.Literal Literal(String s) {
        return Literal(s, null);
    }

    public URI URIref(String uri) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                ValueFactory vf = con.getValueFactory();
                return vf.createURI(uri);
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public BNode bnode() {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                ValueFactory vf = con.getValueFactory();
                return vf.createBNode();
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     *  Convenience URI import for RDF/XML sources
     * 
     * @param urlstring absolute URI of the data source
     */
    public void addURI(String urlstring) {
        addURI(urlstring, RDFFormat.RDFXML);
    }

    /**
     *  Import data from URI source
     *  Request is made with proper HTTP ACCEPT header
     *  and will follow redirects for proper LOD source negotiation
     * 
     * @param urlstring absolute URI of the data source
     * @param format RDF format to request/parse from data source
     */
    public void addURI(String urlstring, RDFFormat format) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                URL url = new URL(urlstring);
                URLConnection uricon = url.openConnection();
                uricon.addRequestProperty("accept", format.getDefaultMIMEType());
                InputStream instream = uricon.getInputStream();
                con.add(instream, urlstring, format, new Resource[0]);
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     *  Import RDF data from a string
     * 
     * @param rdfstring string with RDF data
     * @param format RDF format of the string (used to select parser)
     */
    public void addString(String rdfstring, RDFFormat format) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                StringReader sr = new StringReader(rdfstring);
                con.add(sr, "", format, new Resource[0]);
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     *  Import RDF data from a file
     * 
     * @param location of file (/path/file) with RDF data
     * @param format RDF format of the string (used to select parser)
     * @throws RepositoryException 
     * @throws IOException 
     * @throws RDFParseException 
     */
    public void addFile(String filepath, RDFFormat format) throws RepositoryException, RDFParseException, IOException {
        log.debug("[SimpleGraph::addFile] BEGIN");
        RepositoryConnection con = therepository.getConnection();
        con.add(new File(filepath), "", format, new Resource[0]);
        con.close();
        log.debug("[SimpleGraph::addFile] END");


    }

    /**
     *  Insert Triple/Statement into graph 
     * 
     * @param s subject uriref
     * @param p predicate uriref
     * @param o value object (URIref or Literal)
     */
    public void add(URI s, URI p, Value o) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                ValueFactory myFactory = con.getValueFactory();
                Statement st = myFactory.createStatement(s, p, o);
                con.add(st, new Resource[0]);
            } finally {
                con.close();
            }
        } catch (Exception e) {
            // handle exception
        }
    }

    /**
     *  Execute a CONSTRUCT/DESCRIBE SPARQL query against the graph 
     * 
     * @param qs CONSTRUCT or DESCRIBE SPARQL query
     * @param format the serialization format for the returned graph
     * @return serialized graph of results
     */
    public String runSPARQL(String qs, RDFFormat format) {
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                GraphQuery query = con.prepareGraphQuery(org.openrdf.query.QueryLanguage.SPARQL, qs);
                StringWriter stringout = new StringWriter();
                RDFWriter w = Rio.createWriter(format, stringout);
                query.evaluate(w);
                return stringout.toString();
            } finally {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     *  Execute a SELECT SPARQL query against the graph 
     * 
     * @param qs SELECT SPARQL query
     * @return list of solutions, each containing a hashmap of bindings
     */
    public ArrayList<HashMap<String, Value>> runSPARQL(String qs) {
        log.debug("[SimpleGraph::runSPARQL] BEGIN");
        try {
            RepositoryConnection con = therepository.getConnection();
            try {
                TupleQuery query = con.prepareTupleQuery(org.openrdf.query.QueryLanguage.SPARQL, qs);
                TupleQueryResult qres = query.evaluate();
                ArrayList<HashMap<String, Value>> reslist = new ArrayList<HashMap<String, Value>>();
                while (qres.hasNext()) {
                    BindingSet b = qres.next();
                    Set<String> names = b.getBindingNames();
                    HashMap<String, Value> hm = new HashMap<String, Value>();
                    for (String n : names) {
                        hm.put(n, b.getValue(n));
                    }
                    reslist.add(hm);
                }
                return reslist;
            } finally {
                con.close();
                log.debug("[SimpleGraph::runSPARQL] END");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
