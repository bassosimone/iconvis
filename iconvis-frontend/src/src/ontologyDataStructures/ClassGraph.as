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
 
package ontologyDataStructures {
	
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	
	import mx.messaging.channels.StreamingHTTPChannel;

/**
*
* @author Giuseppe Futia
*
*/		
	public class ClassGraph extends Tree{
		
		public var main;
		private var _classes:Array;
		private var _labels:Array; 
		private var individuals:Array;
		private var thingUri:String;
		private var _nodesMap:Object; //I need an associative array because it allows me to save for loops
		private var _switchIndex:int = 8;
		
		public function ClassGraph(main){
			this.main = main;
			this.classes = main.classes;
			this.labels = main.labels;
			this.individuals = main.individuals;
			nodesMap = new Object();
		}
		
		public function createStructure():void{
			var childrenUri:Array = new Array();
			var rootNode:OntologyClass = new OntologyClass();
			this.root = rootNode;
			//thingUri = findThingNodeUri(classes);
			thingUri = "Thing"
			for(var i:int = 0; i<classes.length; i++){
				if(classes[i][1] == thingUri){
					childrenUri.push(classes[i][0]);
				}
			}	
			if(childrenUri.length>switchIndex)
				rootNode.setChildrenSubset(0);	
			else rootNode.setChildrenSubset(-1);	
			rootNode.setDataClass(thingUri,"OPSA Ontology",rootNode.data.childrenSubset,false);
			putIntoNodeSpriteMap(nodesMap,rootNode.data.uri,rootNode);
			createRootChildren(rootNode, childrenUri,rootNode.data.childrenSubset);
		}
		
		public function createRootChildren(rootNode:OntologyClass,childrenUri:Array,subset:int):void{
			var siblingSubset:Array = new Array();
			if(subset==-1){
				for(var i:int = 0; i<childrenUri.length; i++){
					var childNode:OntologyClass = createChildNode(childrenUri[i],labels,-1,rootNode);
					siblingSubset.push(childNode);		
				}
			}
			else{
				for(var j:int = subset*switchIndex; j<(subset+1)*switchIndex; j++){
					if(childrenUri[j] != undefined){
						var childNode:OntologyClass = createChildNode(childrenUri[j],labels,-1,rootNode);
						siblingSubset.push(childNode);
					}
				}
			}
			createRootGrandsons(siblingSubset);
		}
		
		public function createRootGrandsons(siblings:Array):void{
			var siblingChildren:Array = new Array();
			for(var i:int=0;i<siblings.length;i++){
				var childrenIndex:int = 0;
				for(var j:int=0;j<classes.length;j++){
					if(classes[j][1]==siblings[i].data.uri){
						if(childrenIndex<=switchIndex-1){
							var childNode:OntologyClass = createChildNode(classes[j][0],labels,-1,siblings[i]);
							siblingChildren.push(childNode);
						}
						if(childrenIndex == switchIndex){
							siblings[i].setChildrenSubset(0);
						}
						childrenIndex++;						
					}		
				}	
			}		
			if(siblingChildren.length>0){			
				createRootGrandsons(siblingChildren);
			}	
		}
		
		public function createChildNode(uri:String, labels:Array, childrenSubset:int, fatherNode:OntologyClass):OntologyClass{
			var uriNode:String = uri;
			var labelNode:String = findNodeLabel(uriNode,labels);
			var hasIndividuals:Boolean = checkHasIndividuals(uri,this.individuals);
			var childNode:OntologyClass = new OntologyClass();
			this.addChild(fatherNode,childNode);
			childNode.setDataClass(uriNode,labelNode,-1,hasIndividuals);
			putIntoNodeSpriteMap(nodesMap, uriNode,childNode);
			childNode.x = fatherNode.x;
			childNode.y = fatherNode.y;
			childNode.expanded = false;
			return childNode;
		}
		
		public function checkHasIndividuals(uri:String,individuals:Array):Boolean{
			var hasIndividuals:Boolean = false;
			for(var i:int = 0; i<individuals.length; i++){
				if(individuals[i][1] == uri){
					hasIndividuals = true;
					return hasIndividuals;
				}
			}
			return hasIndividuals;
		}
		
		private function putIntoNodeSpriteMap(map:Object,key:String,value:NodeSprite):void{
			map[key] = value;
		}
		
		private function findNodeLabel(uri:String,labels:Array):String{
			var label:String = "";
			for(var j:int=0; j<labels.length; j++){
				if(j==labels.length-1){
					if (labels[j][0] != uri){
						label = uri; //If you don't find a label property, you can assign the uri as label of the node
					}
				}								
				else if (labels[j][0] == uri){
					label = labels[j][1];
					return label;
					break;
				}
			}
			return label;		
		}
		
		private function findThingNodeUri(classes:Array):String{
			var thingUri:String = "";
			var index:int = 0
			for(var j:int=0; j<classes.length; j++){
				if(classes[index][1]==classes[j][0]){
					index++;
					break;
				}
				else{
					if(j==classes.length-1){
						thingUri=classes[index][1];
						return thingUri;
					}				
				} 
			}
			return thingUri;
		}
/** -----------------------------------------Getters and Setters------------------------------------------------------- **/		
		
		public function get classes():Array{
			return _classes;
		}
		
		public function set classes(c:Array):void{
			_classes = c;
		}
		
		public function get labels():Array{
			return _labels;
		}
		
		public function set labels(l:Array):void{
			_labels = l;
		}
		
		public function get nodesMap():Object{
			return _nodesMap;
		}
		
		public function set nodesMap(nm:Object):void{
			_nodesMap = nm;
		}
		
		public function get switchIndex():int{
			return _switchIndex;
		}
		
		public function set switchIndex(si:int):void{
			_switchIndex = si;	
		}
		
	} //end of class ClassGraph
}