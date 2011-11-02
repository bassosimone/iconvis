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

import it.polito.iconvis.business.startup.IconvisBean;
import javax.ejb.Singleton;
import javax.ejb.LocalBean;
import org.apache.log4j.Logger;
import org.openrdf.model.Value;
import org.openrdf.repository.RepositoryException;
import org.openrdf.rio.RDFParseException;
import it.polito.iconvis.exception.IconvisOntoDataRetrieveException;
import it.polito.iconvis.util.Constants;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class OntologyParser {

    protected static Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".integration.ontology");

    public ArrayList<HashMap<String, String>> classAndIsaExtractor(SimpleGraph openGraph) throws IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::classAndIsaExtractor] BEGIN");
        ArrayList<HashMap<String, String>> classesIsa = new ArrayList<HashMap<String, String>>();
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT ?class1 ?class2 WHERE  { "
                    + "?class1 <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?class2 ." + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("class1");
                Value v2 = elemento.get("class2");
                if (v1.toString().contains(IconvisBean.ontologyURI) && (v2.toString().contains(IconvisBean.ontologyURI) || v2.toString().contains("#Thing"))) {
                    HashMap<String, String> hm = new HashMap<String, String>();
                    hm.put("class1", v1.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("class2", v2.toString().replaceAll("http://www.w3.org/2002/07/owl#Thing", "Thing").replaceAll(IconvisBean.ontologyURI + "#", ""));
                    classesIsa.add(hm);
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::classAndIsaExtractor] Exception: ", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of classes and IS-A relations from the ontology.");
        }
        log.debug("[OntologyParser::classAndIsaExtractor] END");
        return classesIsa;
    }

    public ArrayList<String> topClassesExtractor(SimpleGraph openGraph, SimpleGraph closeGraph) throws IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::topClassesExtractor] BEGIN");
        ArrayList<String> topClasses = new ArrayList<String>();
        try {
            ArrayList<String> downClasses = new ArrayList<String>();
            ArrayList<String> allClasses = classExtractor(closeGraph);
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT ?class1 ?class2 WHERE  { "
                    + "?class1 <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?class2 ." + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("class1");
                Value v2 = elemento.get("class2");
                if (v1.toString().contains(IconvisBean.ontologyURI) && (v2.toString().contains(IconvisBean.ontologyURI) || v2.toString().contains("#Thing"))) {
                    downClasses.add(v1.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                }
            }
            StringBuilder builder = new StringBuilder();
            for (String s : downClasses) {
                builder.append(" ").append(s).append(" ");
            }
            String downClassesString = builder.toString();
            for (String s : allClasses) {
                if (!downClassesString.contains(" " + s + " ")) {
                    topClasses.add(s);
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::topClassesExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of top classes from the ontology.");
        }
        log.debug("[OntologyParser::topClassesExtractor] END");
        return topClasses;
    }

    public ArrayList<String> classExtractor(SimpleGraph closeGraph) throws RepositoryException, RDFParseException, IOException, IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::classesExtractor] BEGIN");
        ArrayList<String> classes = new ArrayList<String>();
        try {
            ArrayList<HashMap<String, Value>> solutions = closeGraph.runSPARQL("SELECT ?classe WHERE  { "
                    + "?classe <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> ." + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v = elemento.get("classe");
                if (v.toString().contains(IconvisBean.ontologyURI)) {
                    classes.add(v.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::classesExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of classes from the ontology.");
        }
        log.debug("[OntologyParser::classesExtractor] END");
        return classes;
    }

    public ArrayList<HashMap<String, String>> individualOfClassExtractor(SimpleGraph openGraph) throws RepositoryException, RDFParseException, IOException, IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::individualOfClassExtractor] BEGIN");
        ArrayList<HashMap<String, String>> individualOfClasses = new ArrayList<HashMap<String, String>>();
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT ?individual ?class WHERE  { "
                    + "?individual <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?class ." + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("individual");
                Value v2 = elemento.get("class");
                if (v1.toString().contains(IconvisBean.ontologyURI) && (v2.toString().contains(IconvisBean.ontologyURI))) {
                    HashMap<String, String> hm = new HashMap<String, String>();
                    hm.put("individual", v1.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("class", v2.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    individualOfClasses.add(hm);
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::individualOfClassExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of individuals and rdfs:type properties from the ontology.");
        }
        log.debug("[OntologyParser::individualOfClassExtractor] END");
        return individualOfClasses;
    }

    public ArrayList<String[]> entityLabelMapper(SimpleGraph openGraph) throws RepositoryException, RDFParseException, IOException, IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::entityLabelMapper] BEGIN");
        ArrayList<String[]> labelMapArray = new ArrayList<String[]>();
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT ?uri ?label WHERE  { "
                    + "?uri <http://www.w3.org/2000/01/rdf-schema#label> ?label . "
                    + "FILTER (langMatches(lang(?label), \"" + IconvisBean.language + "\")) ." + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("uri");
                Value v2 = elemento.get("label");

                String[] array = new String[2];
                if (v1.toString().contains("#")) {
                    array[0] = v1.toString().split("#")[1];
                    array[1] = cleanLabels(v2.toString());
                    labelMapArray.add(array);
                }
            }
            IconvisBean.labelMap = createLabelsMapFromArray(labelMapArray);
        } catch (Exception e) {
            log.error("[OntologyParser::entityLabelMapper] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the mapping of ontology labels to ontology URIs.");
        }
        log.debug("[OntologyParser::entityLabelMapper] END");
        return labelMapArray;
    }

    public String cleanLabels(String imput) {
        String output1 = imput.replaceAll("\"", "");
        String output2 = output1.replace("@it", "");
        String output3 = output2.replace("@en", "");
        String output4 = output3.replace("@fr", "");
        String output5 = output4.replace("@de", "");
        return output5;
    }

    public ArrayList<HashMap<String, String>> allRelationsExtractor(SimpleGraph closeGraph) throws IconvisOntoDataRetrieveException, RepositoryException, RDFParseException, IOException {
        log.debug("[OntologyParser::allRelationsExtractor] BEGIN");
        ArrayList<HashMap<String, String>> relations = new ArrayList<HashMap<String, String>>();
        try {
            ArrayList<HashMap<String, Value>> solutions = closeGraph.runSPARQL("SELECT ?individual1 ?relation ?individual2 WHERE  { "
                    + "?individual1 ?relation ?individual2 ."
                    + "?relation <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#ObjectProperty> ."
                    + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("individual1");
                Value v2 = elemento.get("relation");
                Value v3 = elemento.get("individual2");
                if (v1.toString().contains(IconvisBean.ontologyURI) && (v2.toString().contains(IconvisBean.ontologyURI)) && v3.toString().contains(IconvisBean.ontologyURI)) {
                    HashMap<String, String> hm = new HashMap<String, String>();
                    hm.put("individual1", v1.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("relation", v2.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("individual2", v3.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    relations.add(hm);
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::allRelationsExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of relations between individuals from the ontology");
        }
        log.debug("[OntologyParser::allRelationsExtractor] END");
        return relations;
    }

    public ArrayList<String> superPropertiesExtractor(SimpleGraph openGraph) throws RepositoryException, RDFParseException, IOException, IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::superPropertiesExtractor] BEGIN");
        ArrayList<String> superProperties = new ArrayList<String>();
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT DISTINCT ?relation WHERE  { "
                    + "?x <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> ?relation"
                    + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v = elemento.get("relation");
                if (v.toString().contains(IconvisBean.ontologyURI)) {
                    superProperties.add(v.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::superPropertiesExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of super-properties from the ontology");
        }
        log.debug("[OntologyParser::superPropertiesExtractor] END");
        return superProperties;
    }

    public ArrayList<HashMap<String, String>> dataPropertyExtractor(SimpleGraph openGraph) throws IconvisOntoDataRetrieveException, RepositoryException, RDFParseException, IOException {
        log.debug("[OntologyParser::dataPropertyExtractor] BEGIN");
        ArrayList<HashMap<String, String>> relations = new ArrayList<HashMap<String, String>>();
        try {
            openGraph.addFile(IconvisBean.ontologyCompletePath, SimpleGraph.RDFXML);

            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT ?individual ?relation ?data WHERE  { "
                    + "?individual ?relation ?data ."
                    + "?relation <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> ."
                    + "}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v1 = elemento.get("individual");
                Value v2 = elemento.get("relation");
                Value v3 = elemento.get("data");
                if (v1.toString().contains(IconvisBean.ontologyURI) && (v2.toString().contains(IconvisBean.ontologyURI)) && (!v2.toString().contains("DBpediaProp"))) {
                    HashMap<String, String> hm = new HashMap<String, String>();
                    hm.put("individual", v1.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("relation", v2.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                    hm.put("data", v3.toString().replace("\"", "").replace("^^<http://www.w3.org/2000/01/rdf-schema#Literal>", ""));
                    relations.add(hm);
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::dataPropertyExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of data properties from the ontology");
        }
        log.debug("[OntologyParser::dataPropertyExtractor] END");
        return relations;
    }

    // parameter aclass has to be a complete URI
    public ArrayList<String> individualsOfASingleClassExtractor(SimpleGraph openGraph, String aclass) throws IconvisOntoDataRetrieveException {
        log.debug("[OntologyParser::individualsOfASingleClassExtractor] BEGIN");
        ArrayList<String> individuals = new ArrayList<String>();
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT DISTINCT ?individual WHERE  { "
                    + "?individual <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <" + aclass + "> .}");

            for (HashMap<String, Value> elemento : solutions) {
                Value v = elemento.get("individual");
                if (v.toString().contains(IconvisBean.ontologyURI)) {
                    individuals.add(v.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::individualsOfASingleClassExtractor] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of individuals of a single class from the ontology");
        }
        log.debug("[OntologyParser::individualsOfASingleClassExtractor] END");
        return individuals;
    }

    public HashMap<String, String> createLabelsMapFromArray(ArrayList<String[]> inputArr) {
        HashMap<String, String> result = new HashMap<String, String>();
        for (String[] couple : inputArr) {
            result.put(couple[0], couple[1]);
        }
        return result;
    }

    // parameter anIndividual has to be a complete URI
    public ArrayList<String> superClassesFromIndividual(SimpleGraph openGraph, String anIndividual) throws IconvisOntoDataRetrieveException {
        ArrayList<String> classes = new ArrayList<String>();
        log.debug("[OntologyParser::superClassesFromIndividual] BEGIN");
        try {
            ArrayList<HashMap<String, Value>> solutions = openGraph.runSPARQL("SELECT DISTINCT ?class WHERE  { "
                    + "<" + anIndividual + "> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?class .}");
            for (HashMap<String, Value> elemento : solutions) {
                Value v = elemento.get("class");
                if (v.toString().contains(IconvisBean.ontologyURI)) {
                    classes.add(v.toString().replaceAll(IconvisBean.ontologyURI + "#", ""));
                }
            }
        } catch (Exception e) {
            log.error("[OntologyParser::superClassesFromIndividual] Exception:", e);
            throw new IconvisOntoDataRetrieveException("Exception generated during the extraction of the types of an individual from ontology");
        }
        log.debug("[OntologyParser::superClassesFromIndividual] END");
        return classes;
    }

    public boolean testReasource() {
        log.debug("[OntologyParser::testResource] BEGIN");
        log.debug("[OntologyParser::testResource] END");
        return true;
    }
}
