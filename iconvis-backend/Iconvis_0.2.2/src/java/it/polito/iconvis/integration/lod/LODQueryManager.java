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
package it.polito.iconvis.integration.lod;

import it.polito.iconvis.business.startup.IconvisBean;
import javax.ejb.Singleton;
import javax.ejb.LocalBean;
import it.polito.iconvis.exception.IconvisLODManagementException;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
public class LODQueryManager {

    protected static Logger log = Logger.getLogger(APPLICATION_CODE + ".integration.lod");

    public void mapIndividualToSPARQLQuery() throws IconvisLODManagementException {
        log.debug("[QueryManager::mapIndividualToSPARQLQuery] BEGIN");
        try {
            IconvisBean.individualSPARQLQueryMap = new HashMap<String, String>();
            // if in LOD_query_mapping.xml something is missing, individual with no SPARQL query associated return a "NoQuerySet" string.
            for (String s : IconvisBean.allIndividuals) {
                IconvisBean.individualSPARQLQueryMap.put(s, "NoQuerySet");
            }
            File xml = new File(IconvisBean.ontologyFolderPath + "/LOD_mapping.xml");
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
                            String endpoint = elem.elementText("class_endpoint");
                            String sql = elem.elementText("class_query");
                            if (IconvisBean.labelMap.get(indiv) != null) {
                                IconvisBean.individualSPARQLQueryMap.put(indiv, sql.replace("#default#", IconvisBean.labelMap.get(indiv)) + SEPARATOR_1 + endpoint);
                            } else {
                                log.debug("[QueryManager::mapIndividualToSPARQLQuery] No labels set on the node \"" + indiv + "\". This could affect the outcome of SPARQL queries, if you have not set a different behavior in LOD_mapping.xml.");
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
                    String endpoint = elem.elementText("indiv_endpoint");
                    String sql = elem.elementText("indiv_query");
                    if (IconvisBean.labelMap.get(indivId) != null) {
                        IconvisBean.individualSPARQLQueryMap.put(indivId, sql.replace("#default#", IconvisBean.labelMap.get(indivId)) + SEPARATOR_1 + endpoint);
                    } else {
                        log.debug("[QueryManager::mapIndividualToSPARQLQuery] No labels set on the node \"" + indivId + "\". This could affect the outcome of SPARQL queries, if you have not set a different behavior in LOD_mapping.xml.");
                    }
                }
            }
        } catch (Exception e) {
            log.error("[QueryManager::mapIndividualToSPARQLQuery] Exception: ", e);
            throw new IconvisLODManagementException("Exception generated during the mapping of individuals to SQL query.");
        }
        log.debug("[QueryManager::mapIndividualToSPARQLQuery] END");
    }
}
