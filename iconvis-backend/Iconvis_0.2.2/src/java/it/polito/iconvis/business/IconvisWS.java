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
package it.polito.iconvis.business;

import it.polito.iconvis.business.startup.IconvisBean;
import it.polito.iconvis.integration.db.QueryManager;
import javax.jws.Oneway;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import org.apache.log4j.Logger;
import java.util.ArrayList;
import java.util.HashMap;
import it.polito.iconvis.exception.IconvisQueryManagementException;
import it.polito.iconvis.integration.ontology.OntologyParser;
import it.polito.iconvis.integration.db.IconvisDAO;
import javax.ejb.EJB;
import static it.polito.iconvis.util.Constants.*;

/**
 *
 * @author Federico Cairo
 */
@WebService()
public class IconvisWS {

    protected static Logger log = Logger.getLogger(APPLICATION_CODE + ".business");
    @EJB
    private OntologyParser op;
    @EJB
    private IconvisDAO id;
    @EJB
    private IconvisBean iconvisBean;
    @EJB
    private QueryManager qm;

    @WebMethod(operationName = "testResources")
    public boolean testResources() {
        log.debug("[IconvisWS::testResources] BEGIN");
        boolean result = op.testReasource();
        if (result) {
            log.info("**-------------------------------------**");
            log.info("  [iconviz] Iconviz Business is ready.  ");
            log.info("**-------------------------------------**");
        }
        log.debug("[IconvisWS::testResources] END");
        return result;
    }

    @WebMethod(operationName = "getGraphTreeData")
    public String getGraphTreeData() {
        log.debug("[IconvisWS::getGraphTreeData] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            ArrayList<String> topclasses = op.topClassesExtractor(iconvisBean.getOpengraph(), iconvisBean.getClosegraph());
            for (String tc : topclasses) {
                sb.append(tc).append(SEPARATOR_1+"Thing");
                sb.append('\n');
            }
            ArrayList<HashMap<String, String>> classes = op.classAndIsaExtractor(iconvisBean.getOpengraph());
            for (HashMap<String, String> s : classes) {
                sb.append((s.get("class1") + SEPARATOR_1 + s.get("class2")));
                sb.append('\n');
            }
            result = sb.toString();
            log.debug("**----------------------------------------------------**");
            log.info(" [iconviz] Retrieved data for building the tree graph. ");
            log.debug("**----------------------------------------------------**");
        } catch (Exception e) {
            log.error("[IconvisWS::getGraphTreeData] Exception: ", e);
        }
        log.debug("[IconvisWS::getGraphTreeData] END");
        return result;
    }

    @WebMethod(operationName = "getLabelMap")
    public String getLabelMap() {
        log.debug("[IconvisWS::getLabelMap] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            ArrayList<String[]> labelMap = op.entityLabelMapper(iconvisBean.getOpengraph());
            for (String[] s : labelMap) {
                sb.append(s[0]).append("=").append(s[1]);
                sb.append('\n');
            }
            result = sb.toString();
        } catch (Exception e) {
            log.error("[IconvisWS::getLabelMap] Exception: ", e);
        }
        log.debug("[IconvisWS::getLabelMap] END");
        return result;
    }

    @WebMethod(operationName = "getIndividualTypeData")
    public String getIndividualTypeData() {
        log.debug("[IconvisWS::getIndividualTypeData] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            ArrayList<HashMap<String, String>> individuals = op.individualOfClassExtractor(iconvisBean.getOpengraph());
            String controlString = "";
            for (HashMap<String, String> s : individuals) {
                if (!controlString.contains("@" + s.get("individual") + "@")) {
                    sb.append((s.get("individual") + SEPARATOR_1 + s.get("class")));
                    sb.append('\n');
                    controlString = controlString + "@" + s.get("individual") + "@";
                }
            }
            result = sb.toString();
            log.debug("**-----------------------------------------------------------------**");
            log.info(" [iconviz] Retrieved data about individuals and rdfs:type relations. ");
            log.debug("**-----------------------------------------------------------------**");
        } catch (Exception e) {
            log.error("[IconvisWS::getIndividualTypeData] Exception: ", e);
        }
        log.debug("[IconvisWS::getIndividualTypeData] END");
        return result;
    }

    @WebMethod(operationName = "getIndividualRelationsData")
    public String getIndividualRelationsData() {
        log.debug("[IconvisWS::getIndividualRelationsData] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            ArrayList<HashMap<String, String>> allRelations = op.allRelationsExtractor(iconvisBean.getInferredclosegraph());
            ArrayList<String> superRelations = op.superPropertiesExtractor(iconvisBean.getOpengraph());
            boolean ok = true;
            for (HashMap<String, String> a : allRelations) {
                for (String s : superRelations) {
                    if (a.get("relation").equals(s)) {
                        ok = false;
                    }
                }
                if (ok) {
                    sb.append((a.get("individual1") + SEPARATOR_1 + a.get("relation") + SEPARATOR_1 + a.get("individual2")));
                    sb.append('\n');
                }
                ok = true;
            }
            result = sb.toString();
            log.debug("**------------------------------------------------------------**");
            log.info(" [iconviz] Retrieved data about relations between individuals. ");
            log.debug("**------------------------------------------------------------**");
        } catch (Exception e) {
            log.error("[IconvisWS::getIndividualRelationsData] Exception: ", e);
        }
        log.debug("[IconvisWS::getIndividualRelationsData] END");
        return result;
    }

    @WebMethod(operationName = "getIndividualDataProperties")
    public String getIndividualDataProperties() {
        log.debug("[IconvisWS::getIndividualDataProperties] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            ArrayList<HashMap<String, String>> allRelations = op.dataPropertyExtractor(iconvisBean.getOpengraph());
            //ArrayList<String> superRelations = StartupListener.op.superPropertiesExtractor(StartupListener.ontologyCompletePath, StartupListener.ontologyURI);
            for (HashMap<String, String> a : allRelations) {
                sb.append((a.get("individual") + SEPARATOR_1 + a.get("relation") + SEPARATOR_1 + a.get("data")));
                sb.append('\n');
            }
            result = sb.toString();
            log.debug("**------------------------------------------------------------**");
            log.info(" [iconviz] Retrieved data properties. ");
            log.debug("**------------------------------------------------------------**");
        } catch (Exception e) {
            log.error("[IconvisWS::getIndividualDataProperties] Exception: ", e);
        }
        log.debug("[IconvisWS::getIndividualDataProperties] END");
        return result;
    }

    @WebMethod(operationName = "writeLog")
    @Oneway
    public void writeLog(@WebParam(name = "s") String s) {
        log.debug("[IconvisWS::writeLog] Log from ICONVIS front-end: " + s);
    }

    @WebMethod(operationName = "testDB")
    @Oneway
    public void testDB(@WebParam(name = "s") String s) {
        try {
            qm.createIndividualsTable(iconvisBean.getClosegraph(), iconvisBean.getInferredopengraph());
            qm.mapIndividualToQuery();
        } catch (IconvisQueryManagementException e) {
            // TODO Auto-generated catch block
        }
    }

    @WebMethod(operationName = "getDataFromDB")
    public String getDataFromDB(@WebParam(name = "s") String s) {
        log.debug("[IconvisWS::getDataFromDB] BEGIN");
        String result = null;
        try {
            result = id.retrieveData(s);
        } catch (Exception e) {
            log.error("[IconvisWS::getDataFromDB] Exception: ", e);
        }
        log.debug("[IconvisWS::getDataFromDB] END");
        return result;
    }

    @WebMethod(operationName = "getDataFlagsOnIndividuals")
    public String getDataFlagsOnIndividuals() {
        log.debug("[IconvisWS::getDataFlagsOnIndividuals] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            for (String[] s : iconvisBean.getDbDataFlags()) {
                sb.append(s[0]).append("=").append(s[1]);
                sb.append('\n');
            }
            result = sb.toString();
        } catch (Exception e) {
            log.error("[IconvisWS::getDataFlagsOnIndividuals] Exception: ", e);
        }
        log.debug("[IconvisWS::getDataFlagsOnIndividuals] END");
        return result;
    }

    @WebMethod(operationName = "getLODQueries")
    public String getLODQueries() {
        log.debug("[IconvisWS::getLODQueries] BEGIN");
        String result = null;
        try {
            StringBuilder sb = new StringBuilder();
            for (String indiv : iconvisBean.getAllIndividuals()) {
                String SPARQLquery = (iconvisBean.getIndividualSPARQLQueryMap().get(indiv)).split(SEPARATOR_1)[0];
                String SPARQLendpoint = (iconvisBean.getIndividualSPARQLQueryMap().get(indiv)).split(SEPARATOR_1)[1];
                sb.append(indiv).append(SEPARATOR_1).append(SPARQLquery).append(SEPARATOR_1).append(SPARQLendpoint);
                sb.append('\n');
            }
            result = sb.toString();
        } catch (Exception e) {
            log.error("[IconvisWS::getLODQueries] Exception: ", e);
        }
        log.debug("[IconvisWS::getLODQueries] END");
        return result;
    }

    @WebMethod(operationName = "isDBLodModuleActive")
    public boolean isDBLodModuleActive() {
        log.debug("[IconvisWS::isDBLodModuleActive] BEGIN");
        boolean result = false;
        try {
            if (iconvisBean.isIsDBLodModuleActive()) {
                result = true;
            }
        } catch (Exception e) {
            log.error("[IconvisWS::isDBLodModuleActive] Exception: ", e);
        }
        log.debug("[IconvisWS::isDBLodModuleActive] END");
        return result;
    }
}
