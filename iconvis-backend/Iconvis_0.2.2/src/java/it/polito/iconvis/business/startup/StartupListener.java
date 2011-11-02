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

import javax.servlet.ServletContextEvent;
import it.polito.iconvis.util.Constants;
import javax.ejb.EJB;
import org.apache.log4j.Logger;

/**
 *
 * @author Federico Cairo
 */
public class StartupListener implements javax.servlet.ServletContextListener {

    private Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".business.startup");
    @EJB
    private IconvisBean iconvisBean;

    @Override
    public void contextInitialized(ServletContextEvent arg0) {
        try {
            iconvisBean.startUp();
        } catch (Exception ex) {
            log.error("[StartupListener::contextInitialized] Exception: ", ex);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent arg0) {
        log.debug("Servlet Context is destroyed....");
    }
}
