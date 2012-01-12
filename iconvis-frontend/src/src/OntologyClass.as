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
 * */
 
package {
	import flare.util.Strings;
	import flare.vis.data.NodeSprite;
	
/**
*
* @author Giuseppe Futia
*
*/	
	public class OntologyClass extends NodeSprite{
		
		public function OntologyClass(){
		
		}
		
		public function setDataClass(uri:String, label:String, childrenSubset:int, hasIndividuals:Boolean):void{
			this.data.uri = uri;
			this.data.label = label;
			this.data.childrenSubset = childrenSubset; 
			this.data.hasIndividuals = hasIndividuals;
		}
		
		public function setUri(uri:Strings):void{
			this.data.uri = uri;
		}
		
		public function setLabel(label:String):void{
			this.data.label = label;	
		}
		
		public function setChildrenSubset(childrenSubset:int):void{
			this.data.childrenSubset = childrenSubset;	
		}
		
		public function setHasIndividuals(hasIndividuals:Boolean):void{
			this.data.hasIndividuals = hasIndividuals;
		}
	}
}