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
package it.polito.iconvis.integration.db;

import it.polito.iconvis.business.startup.IconvisBean;
import javax.ejb.Singleton;
import javax.ejb.LocalBean;
import it.polito.iconvis.exception.IconvisQueryManagementException;
import it.polito.iconvis.integration.ontology.OntologyParser;
import it.polito.iconvis.integration.ontology.SimpleGraph;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.ejb.EJB;
import org.apache.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import static it.polito.iconvis.util.Constants.*;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class QueryManager {

    protected static Logger log = Logger.getLogger(APPLICATION_CODE + ".integration.db");
    private ArrayList<String> allIndividuals;
    @EJB
    private OntologyParser op;
    @EJB
    private IconvisDAO id;

    public void createIndividualsTable(SimpleGraph closeGraph, SimpleGraph inferredOpenGraph) throws IconvisQueryManagementException {
        log.debug("[QueryManager::createIndividualsTable] BEGIN");
        try {
            IconvisBean.individualsOfClassesTable = new HashMap<String, ArrayList<String>>();
            ArrayList<String> classes = op.classExtractor(closeGraph);
            for (String aclass : classes) {
                ArrayList<String> arr = new ArrayList<String>();
                IconvisBean.individualsOfClassesTable.put(aclass, arr);
            }
            ArrayList<HashMap<String, String>> indivClasses = op.individualOfClassExtractor(inferredOpenGraph);
            ArrayList<String> as = new ArrayList<String>();
            for (HashMap<String, String> s : indivClasses) {
                as.add(s.get("individual") + SEPARATOR_3 + SEPARATOR_1 + s.get("class") + SEPARATOR_1);
            }
            //g.a.w.
            for (String aclass : classes) {
                for (String indClass : as) {
                    if (indClass.contains(SEPARATOR_1 + aclass + SEPARATOR_1)) {
                        ArrayList<String> arre = IconvisBean.individualsOfClassesTable.get(aclass);
                        arre.add(indClass.replace(SEPARATOR_3 + SEPARATOR_1 + aclass + SEPARATOR_1, ""));
                    }
                }
            }
            allIndividuals = op.individualsOfASingleClassExtractor(inferredOpenGraph, "http://www.w3.org/2002/07/owl#Thing");
            IconvisBean.allIndividuals = allIndividuals;
            IconvisBean.individualsOfClassesTable.put("Thing", allIndividuals);
        } catch (Exception e) {
            log.error("[QueryManager::createIndividualsTable] Exception: ", e);
            throw new IconvisQueryManagementException("Exception generated during creation of the individuals table.");
        }
        log.debug("[QueryManager::createIndividualsTable] END");
    }

    public void mapIndividualToQuery() throws IconvisQueryManagementException {
        log.debug("[QueryManager::mapIndividualToQuery] BEGIN");
        try {
            IconvisBean.individualQueryMap = new HashMap<String, String>();
            // if in query_mapping.xml something is missing, individual with no query associated return a "NoQuerySet" string.
            for (String s : allIndividuals) {
                IconvisBean.individualQueryMap.put(s, "NoQuerySet");
            }
            File xml = new File(IconvisBean.ontologyFolderPath + "/query_mapping.xml");
            SAXReader reader = new SAXReader();
            Document doc = reader.read(xml);
            Element root = doc.getRootElement();


            List<Element> classlist = new ArrayList<Element>();
            classlist = root.elements("class");
            if (classlist != null && !classlist.isEmpty()) {
                for (Element elem : classlist) {
                    String classId = elem.attributeValue("id");
                    ArrayList<String> arr = IconvisBean.individualsOfClassesTable.get(classId);
                    if (!arr.isEmpty()) {
                        for (String indiv : arr) {
                            String sql = elem.elementText("class_query");
                            if (IconvisBean.labelMap.get(indiv) != null) {
                                IconvisBean.individualQueryMap.put(indiv, sql.replace("#default#", IconvisBean.labelMap.get(indiv)));
                            } else {
                                log.debug("[QueryManager::mapIndividualToQuery] No labels set on the node \"" + indiv + "\". This could affect the outcome of database queries, if you have not set a different behavior in query_mapping.xml.");
                            }
                        }
                    }
                }
            }
            List<Element> indivlist = new ArrayList<Element>();
            indivlist = root.elements("indiv");
            if (indivlist != null && !indivlist.isEmpty()) {
                for (Element elem : indivlist) {
                    String indivId = elem.attributeValue("id");
                    String sql = elem.elementText("indiv_query");
                    IconvisBean.individualQueryMap.put(indivId, sql.replace("#default#", IconvisBean.labelMap.get(indivId)));
                }
            }
        } catch (Exception e) {
            log.error("[QueryManager::mapIndividualToQuery] Exception: ", e);
            throw new IconvisQueryManagementException("Exception generated during the mapping of individuals to SQL query.");
        }
        log.debug("[QueryManager::mapIndividualToQuery] END");
    }

    public void setFlagAboutDBData() throws IconvisQueryManagementException {
        log.debug("[QueryManager::setFlagAboutDBData] BEGIN");
        try {
            ArrayList<String[]> result = new ArrayList<String[]>();
            for (String individual : allIndividuals) {
                String query = IconvisBean.individualQueryMap.get(individual);
                String[] array = new String[2];
                array[0] = individual;
                array[1] = "1";
                if (query.equals("NoQuerySet")) {
                    array[1] = "0";
                } else {
                    int numQueryResults = id.countQueryResults(query);
                    if (numQueryResults == 0) {
                        array[1] = "0";
                    }
                }
                result.add(array);
            }
            IconvisBean.dbDataFlags = result;
        } catch (Exception e) {
            log.error("[QueryManager::setFlagAboutDBData] Exception: ", e);
            throw new IconvisQueryManagementException("Exception generated during the setting of flags about DB data.");
        }
        log.debug("[QueryManager::setFlagAboutDBData] END");
    }
}
