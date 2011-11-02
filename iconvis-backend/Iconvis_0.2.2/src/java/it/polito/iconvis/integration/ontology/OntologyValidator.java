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
import it.polito.iconvis.util.Constants;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.UnknownHostException;
import java.util.Map;
import org.apache.log4j.Logger;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.io.OWLOntologyCreationIOException;
import org.semanticweb.owlapi.io.OWLParser;
import org.semanticweb.owlapi.io.OWLParserException;
import org.semanticweb.owlapi.io.UnparsableOntologyException;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.UnloadableImportException;

/**
 *
 * @author Federico Cairo
 */
@Singleton
@LocalBean
public class OntologyValidator {

    protected static Logger log = Logger.getLogger(Constants.APPLICATION_CODE + ".integration.ontology");
    private String ontologyUri;

    public OntologyValidator() {
        log.debug("[OntologyValidator::constructor] BEGIN");
        log.debug("[OntologyValidator::constructor] END");
    }

    public String getOntologyUri() {
        return ontologyUri;
    }

    public boolean validateOntology(String ontologyPath) throws Exception {
        log.debug("[OntologyValidator::validateOntology] BEGIN");
        boolean result = false;
        try {

            OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
            File file = new File(ontologyPath);
            OWLOntology localont = manager.loadOntologyFromOntologyDocument(file);
            ontologyUri = localont.getOntologyID().getOntologyIRI().toString();
            log.info("[iconviz] Loaded ontology with URI: " + ontologyUri);
            IRI documentIRI = manager.getOntologyDocumentIRI(localont);
            log.info("[iconviz] Artefact: " + documentIRI);
            result = true;
        } catch (OWLOntologyCreationIOException e) {
            IOException ioException = e.getCause();
            if (ioException instanceof FileNotFoundException) {
                log.error("[OntologyValidator::validateOntology] Could not load ontology. File not found: " + ioException.getMessage());
            } else if (ioException instanceof UnknownHostException) {
                log.error("[OntologyValidator::validateOntology] Could not load ontology. Unknown host: " + ioException.getMessage());
            } else {
                log.error("[OntologyValidator::validateOntology] Could not load ontology: " + ioException.getClass().getSimpleName() + " " + ioException.getMessage());
            }
            throw e;
        } catch (UnparsableOntologyException e) {
            log.error("[OntologyValidator::validateOntology] Could not parse the ontology: " + e.getMessage());
            Map<OWLParser, OWLParserException> exceptions = e.getExceptions();
            for (OWLParser parser : exceptions.keySet()) {
                log.error("Tried to parse the ontology with the " + parser.getClass().getSimpleName() + " parser");
                log.error("Failed because: " + exceptions.get(parser).getMessage());
            }
            throw e;
        } catch (UnloadableImportException e) {
            log.error("[OntologyValidator::validateOntology] Could not load import: " + e.getImportsDeclaration());
            OWLOntologyCreationException cause = e.getOntologyCreationException();
            log.error("Reason: " + cause.getMessage());
            throw e;
        } catch (OWLOntologyCreationException e) {
            log.error("[OntologyValidator::validateOntology] Could not load ontology: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            log.error("[OntologyValidator::validateOntology] Ontology validation unsuccessful. Check ontology and parameters in input.", e);
            throw e;
        }
        log.debug("[OntologyValidator::validateOntology] END");
        return result;
    }
}
