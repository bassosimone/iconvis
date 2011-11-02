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
package it.polito.iconvis.business.startup;

import javax.ejb.Singleton;
import javax.ejb.LocalBean;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.ResourceBundle;
import it.polito.iconvis.exception.DatabaseAndLODSetupException;
import it.polito.iconvis.exception.OntologyInferenceException;
import it.polito.iconvis.exception.OntologyValidationException;
import it.polito.iconvis.integration.db.IconvisDAO;
import it.polito.iconvis.integration.db.QueryManager;
import it.polito.iconvis.integration.lod.LODQueryManager;
import it.polito.iconvis.integration.ontology.OntologyParser;
import it.polito.iconvis.integration.ontology.OntologyReasoner;
import it.polito.iconvis.integration.ontology.OntologyValidator;
import it.polito.iconvis.integration.ontology.SimpleGraph;
import it.polito.iconvis.util.Constants;
import javax.ejb.EJB;
import org.apache.log4j.Logger;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class IconvisBean {

    private Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".business.startup");
    public static String ontologyFolderPath;
    public static String ontologyCompletePath;
    public static String ontologyURI;
    public static String inferredOntologyPath;
    public static String databaseVendor;
    public static String databaseURL;
    public static String databaseDriver;
    public static String databaseUser;
    public static String databasePassword;
    public static String databaseModuleActive;
    public static String language;
    public static boolean isDBLodModuleActive;
    public static HashMap<String, String> individualQueryMap;
    public static HashMap<String, String> individualSPARQLQueryMap;
    public static HashMap<String, ArrayList<String>> individualsOfClassesTable;
    public static HashMap<String, String> labelMap;
    public static ArrayList<String[]> dbDataFlags;
    public static ArrayList<String> allIndividuals;
    private SimpleGraph opengraph;
    private SimpleGraph closegraph;
    private SimpleGraph inferredopengraph;
    private SimpleGraph inferredclosegraph;
    @EJB
    private OntologyParser op;
    @EJB
    private OntologyValidator ov;
    @EJB
    private OntologyReasoner or;
    @EJB
    private QueryManager qm;
    @EJB
    private LODQueryManager lqm;
    @EJB
    private IconvisDAO id;

    public void startUp() {
        log.debug("[IconvisBean::startUp] BEGIN");
        log.debug("**-------------------------------**");
        log.info(" [iconvis] Iconvis starting up... ");
        log.debug("**-------------------------------**");
        try {
            opengraph = new SimpleGraph();
            closegraph = new SimpleGraph(true);
            inferredopengraph = new SimpleGraph();
            inferredclosegraph = new SimpleGraph(true);
            ontologyValidation();
            ontologyInference();
            if (checkDBProperty()) {
                databaseAndLODSetup();
            }
        } catch (Exception ex) {
            log.error("[IconvisBean::startUp] Exception: ", ex);
        }
        log.debug("[IconvisBean::startUp] END");
    }

    public void ontologyValidation() throws OntologyValidationException {
        log.debug("[IconvisStartup::ontologyValidation] BEGIN");
        try {
            ResourceBundle resources = ResourceBundle.getBundle("configuration");
            ontologyFolderPath = resources.getString("ONTOLOGY_FOLDER_PATH");
            ontologyCompletePath = ontologyFolderPath + "/" + resources.getString("ONTOLOGY_FILE_NAME");
            language = resources.getString("LANG");
            boolean result = ov.validateOntology(ontologyCompletePath);
            if (result) {
                log.debug("**----------------------------------------**");
                log.info(" [iconvis] Ontology in input proved valid. ");
                log.debug("**----------------------------------------**");
            }
            ontologyURI = ov.getOntologyUri();
            opengraph.addFile(ontologyCompletePath, SimpleGraph.RDFXML);
            closegraph.addFile(ontologyCompletePath, SimpleGraph.RDFXML);
        } catch (Exception e) {
            log.error("[IconvisStartup::ontologyValidation] Exception: ", e);
            throw new OntologyValidationException("Exception generated during the validation of ontology in input.");
        }
        log.debug("[IconvisStartup::ontologyValidation] END");
    }

    public void ontologyInference() throws OntologyInferenceException {
        log.debug("[IconvisStartup::ontologyInference] BEGIN");
        try {
            inferredOntologyPath = or.createInferredOntology(ontologyFolderPath, ontologyCompletePath);
            if (inferredOntologyPath != null) {
                log.debug("**-----------------------------------------------------------------**");
                log.info(" [iconvis] Created new inferred ontology at: " + inferredOntologyPath);
                log.debug("**-----------------------------------------------------------------**");
                inferredopengraph.addFile(inferredOntologyPath, SimpleGraph.RDFXML);
                inferredclosegraph.addFile(inferredOntologyPath, SimpleGraph.RDFXML);
            }
        } catch (Exception e) {
            log.error("[IconvisStartup::ontologyInference] Exception: ", e);
            throw new OntologyInferenceException("Exception generated during the creation of inferred ontology.");
        }
        log.debug("[IconvisStartup::ontologyInference] END");

    }

    public void databaseAndLODSetup() throws DatabaseAndLODSetupException {
        log.debug("[IconvisStartup::databaseSetup] BEGIN");
        try {
            //senza il entityLabelMapper() non funzia, ma bisogna trovare un loco più consono.
            op.entityLabelMapper(opengraph);
            qm.createIndividualsTable(closegraph, inferredopengraph);
            qm.mapIndividualToQuery();
            lqm.mapIndividualToSPARQLQuery();
            id.getConnectionDataFromXml();
            Connection con = id.getDBConnection();
            if (con != null) {
                log.debug("**-----------------------------------------**");
                log.info("[iconvis] Database connection established. ");
                log.debug("**-----------------------------------------**");
                con.close();
            }
            qm.setFlagAboutDBData();
        } catch (Exception e) {
            log.error("[IconvisStartup::databaseSetup] Exception: ", e);
            throw new DatabaseAndLODSetupException("Exception generated during the database setup.");
        }
        log.debug("[IconvisStartup::databaseSetup] END");
    }

    public boolean checkDBProperty() throws DatabaseAndLODSetupException {
        boolean result = false;
        log.debug("[IconvisStartup::checkDBProperty] BEGIN");
        try {
            ResourceBundle resources = ResourceBundle.getBundle("configuration");
            databaseModuleActive = resources.getString("DATABASE_LOD_MODULE_ACTIVE");
            if (databaseModuleActive.equals("true")) {
                result = true;
                isDBLodModuleActive = true;
                log.info("[iconvis] Configuration of DB and LOD modules is active. ");
            } else {
                isDBLodModuleActive = false;
                log.info("[iconvis] Configuration of DB and LOD modules is not active. If you want to use a database and enrich it with LOD, please check your dev.properties file.");
            }
        } catch (Exception e) {
            log.error("[IconvisStartup::checkDBProperty] Exception: ", e);
            throw new DatabaseAndLODSetupException("Exception generated during the reading of DB module flag in configuration.xml. Configuration of DB module will not be active.");
        }
        log.debug("[IconvisStartup::checkDBProperty] END");
        return result;

    }

    public ArrayList<String> getAllIndividuals() {
        return allIndividuals;
    }

    public String getDatabaseDriver() {
        return databaseDriver;
    }

    public String getDatabaseModuleActive() {
        return databaseModuleActive;
    }

    public String getDatabasePassword() {
        return databasePassword;
    }

    public String getDatabaseURL() {
        return databaseURL;
    }

    public String getDatabaseUser() {
        return databaseUser;
    }

    public String getDatabaseVendor() {
        return databaseVendor;
    }

    public ArrayList<String[]> getDbDataFlags() {
        return dbDataFlags;
    }

    public HashMap<String, String> getIndividualQueryMap() {
        return individualQueryMap;
    }

    public HashMap<String, String> getIndividualSPARQLQueryMap() {
        return individualSPARQLQueryMap;
    }

    public HashMap<String, ArrayList<String>> getIndividualsOfClassesTable() {
        return individualsOfClassesTable;
    }

    public String getInferredOntologyPath() {
        return inferredOntologyPath;
    }

    public boolean isIsDBLodModuleActive() {
        return isDBLodModuleActive;
    }

    public HashMap<String, String> getLabelMap() {
        return labelMap;
    }

    public String getLanguage() {
        return language;
    }

    public String getOntologyCompletePath() {
        return ontologyCompletePath;
    }

    public String getOntologyFolderPath() {
        return ontologyFolderPath;
    }

    public String getOntologyURI() {
        return ontologyURI;
    }

    public SimpleGraph getClosegraph() {
        return closegraph;
    }

    public void setClosegraph(SimpleGraph closegraph) {
        this.closegraph = closegraph;
    }

    public SimpleGraph getInferredclosegraph() {
        return inferredclosegraph;
    }

    public void setInferredclosegraph(SimpleGraph inferredclosegraph) {
        this.inferredclosegraph = inferredclosegraph;
    }

    public SimpleGraph getInferredopengraph() {
        return inferredopengraph;
    }

    public void setInferredopengraph(SimpleGraph inferredopengraph) {
        this.inferredopengraph = inferredopengraph;
    }

    public SimpleGraph getOpengraph() {
        return opengraph;
    }

    public void setOpengraph(SimpleGraph opengraph) {
        this.opengraph = opengraph;
    }
}
