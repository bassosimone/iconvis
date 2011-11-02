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

import javax.ejb.Singleton;
import javax.ejb.LocalBean;
import it.polito.iconvis.exception.IconvisOntoDataRetrieveException;
import it.polito.iconvis.util.Constants;
import java.io.File;
import org.apache.log4j.Logger;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import com.clarkparsia.pellet.owlapiv3.PelletReasonerFactory;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class OntologyReasoner {

    protected static Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".integration.ontology");

    public OntologyReasoner() {
        log.debug("[OntologyReasoner::constructor] BEGIN");
        log.debug("[OntologyReasoner::constructor] END");
    }

    public String createInferredOntology(String ontologyFolderPath, String ontologyCompletePath) throws IconvisOntoDataRetrieveException {
        log.debug("[OntologyReasoner::createInferredOntology] BEGIN");
        String inferredOntologyPath = null;
        try {
            OWLReasonerFactory reasonerFactory = null;
            reasonerFactory = new PelletReasonerFactory();
            OWLOntologyManager man = OWLManager.createOWLOntologyManager();
            OWLOntology ont = man.loadOntologyFromOntologyDocument(new File(ontologyCompletePath));
            OWLReasoner reasoner = reasonerFactory.createNonBufferingReasoner(ont);
            OWLOntology infOnt = man.createOntology();
            log.info("[iconviz] Creating a new inferred ontology... ");
            InferredOntologyGenerator iog = new InferredOntologyGenerator(reasoner);
            iog.fillOntology(man, infOnt);
            inferredOntologyPath = ontologyFolderPath + "/" + "Inferred_Ontology.owl";
            man.saveOntology(infOnt, IRI.create(new File(inferredOntologyPath)));
        } catch (Exception e) {
            log.error("[OntologyReasoner::createInferredOntology] Exception: ", e);
            throw new IconvisOntoDataRetrieveException("Exception thrown during creation of the inferred ontology.");
        }
        log.debug("[OntologyReasoner::createInferredOntology] END");
        return inferredOntologyPath;
    }
}
