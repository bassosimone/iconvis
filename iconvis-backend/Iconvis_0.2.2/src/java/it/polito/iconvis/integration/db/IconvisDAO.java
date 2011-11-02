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
import it.polito.iconvis.exception.IconvisDBOperationException;
import java.io.File;
import java.net.MalformedURLException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import org.apache.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import static it.polito.iconvis.util.Constants.*;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class IconvisDAO {

    protected static Logger log = Logger.getLogger(APPLICATION_CODE + ".integration.db");

    public void getConnectionDataFromXml() throws MalformedURLException, DocumentException {
        log.debug("[QueryManager::getConnectionDataFromXml] BEGIN");
        File xml = new File(IconvisBean.ontologyFolderPath + "/query_mapping.xml");
        SAXReader reader = new SAXReader();
        Document doc = reader.read(xml);
        Element root = doc.getRootElement();
        Element database = root.element("database");
        IconvisBean.databaseURL = database.elementText("url");
        IconvisBean.databaseVendor = database.elementText("vendor");
        IconvisBean.databaseDriver = database.elementText("driver");
        IconvisBean.databaseUser = database.elementText("user");
        IconvisBean.databasePassword = database.elementText("password");
        log.info("[iconviz] Got DB connection data from XML. USERNAME: " + IconvisBean.databaseUser + " PASSWORD: " + IconvisBean.databasePassword + " URL: " + IconvisBean.databaseURL);
        log.debug("[QueryManager::getConnectionDataFromXml] END");
    }

    public Connection getDBConnection() {
        log.debug("[QueryManager::getDBConnection] BEGIN");
        Connection con = null;
        try {
            Class.forName(IconvisBean.databaseDriver).newInstance();
            con = DriverManager.getConnection(IconvisBean.databaseURL, IconvisBean.databaseUser, IconvisBean.databasePassword);
        } catch (Exception e) {
            log.error("[QueryManager::getDBConnection] Exception: ", e);
        }
        log.debug("[QueryManager::getDBConnection] END");
        return con;
    }

    public String retrieveData(String s) throws IconvisDBOperationException {
        log.debug("[QueryManager::retrieveData] BEGIN");
        String result = null;
        try {
            Connection con = getDBConnection();
            Statement stmt = con.createStatement();
            String query = null;
            StringBuilder sb = new StringBuilder();
            String[] split = s.split(";;");
            String URI = split[0];
            String classIndiv = split[1];
            if (classIndiv.equals("indiv")) {
                query = IconvisBean.individualQueryMap.get(URI);
                log.info("[QueryManager::retrieveData] SQL query: " + query);
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    sb.append(rs.getString(1)).append(SEPARATOR_2).append(rs.getString(2)).append(SEPARATOR_3);
                }
            } else {
                for (String indiv : IconvisBean.individualsOfClassesTable.get(URI)) {
                    query = IconvisBean.individualQueryMap.get(indiv);
                    log.info("[QueryManager::retrieveData] SQL query: " + query);
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        sb.append(rs.getString(1)).append(SEPARATOR_2).append(rs.getString(2)).append(SEPARATOR_3);
                    }
                }
            }
            con.close();
            log.info("[QueryManager::retrieveData] Result: " + sb.toString());
            result = sb.toString();
        } catch (Exception e) {
            log.error("[QueryManager::retrieveData] Exception: ", e);
            throw new IconvisDBOperationException("Exception generated during CRUD operations on DB. ");
        }
        log.debug("[QueryManager::retrieveData] END");
        return result;
    }

    // input: a query    output: number of results
    public int countQueryResults(String query) throws IconvisDBOperationException {
        log.debug("[QueryManager::countQueryResults] BEGIN");
        int count = 0;
        try {
            Connection con = getDBConnection();
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                count++;
            }
        } catch (Exception e) {
            log.error("[QueryManager::countQueryResults] Exception: ", e);
            throw new IconvisDBOperationException("Exception generated during results query counting on DB.");
        }
        log.debug("[QueryManager::countQueryResults] END");
        return count;
    }
}
