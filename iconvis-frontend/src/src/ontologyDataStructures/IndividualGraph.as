package ontologyDataStructures{
	import flare.animate.Tween;
	import flare.vis.data.Tree;
	
	import flash.events.MouseEvent;
	
	import views.IndividualGraphView;
	
	public class IndividualGraph extends Tree{
		
		private var _individuals:Array
		private var _labels:Array; 
		private var _childrenUri:Array;
		private var _isLetterGraph:Boolean;
		private var _switchIndex:int = 8;
		private var groupIndex:int = 5;
		private var _mapLetter:Object;
		private var _letterChildren:Array;
		
		public function IndividualGraph(individuals:Array,labels:Array){
			this.individuals = individuals;
			this.labels = labels;
			childrenUri = new Array();
		}
		
		public function createStructure(ontologyClass:OntologyClass):void{
			var rootNode:OntologyClass = new OntologyClass();
			rootNode.setDataClass(ontologyClass.data.uri,ontologyClass.data.label,-1,false);
			this.root = rootNode;
			rootNode.expanded = true;
			for(var i:int = 0; i<individuals.length; i++){
				if(individuals[i][1] == rootNode.data.uri){
					childrenUri.push(individuals[i][0]);
				}
			}	
			if(childrenUri.length>groupIndex*switchIndex){ //Condizione nella quale i figli risultano essere maggiori di 40
				isLetterGraph = true;
				var indexGenerator:IndexGenerator = new IndexGenerator(childrenUri,labels);
				var subset:int;
				mapLetter = indexGenerator.mapLetter;
				letterChildren = indexGenerator.letterChildren;
				//trace("Lunghezza di letterChildren: "+letterChildren.length);
				if(letterChildren.length>switchIndex)
					rootNode.setChildrenSubset(0);
				else 
					rootNode.setChildrenSubset(-1);				
				createRootChildren(rootNode,letterChildren,rootNode.data.childrenSubset,isLetterGraph);
			}
			else{
				isLetterGraph = false
				if(childrenUri.length>switchIndex)
					rootNode.setChildrenSubset(0);	
				else
					rootNode.setChildrenSubset(-1);
				createRootChildren(rootNode,childrenUri,rootNode.data.childrenSubset,isLetterGraph);
			}			
		}
		
		public function createRootChildren(rootNode:OntologyClass,childrenUri:Array,subset:int,isLetterGraph):void{
			if(subset == -1){
				for(var i:int = 0; i<switchIndex; i++){
					if(childrenUri[i] != null){
						var childNode:OntologyIndividual = createChildNode(childrenUri[i],labels,rootNode);
					}	
				}
			}else{
				for(var j:int = subset*switchIndex; j<(subset+1)*switchIndex; j++){
					if(childrenUri[j] != undefined){
						var childNode:OntologyIndividual = createChildNode(childrenUri[j],labels,rootNode);
					}
				}
			}
		}
		
		public function createChildNode(uri:String, labels:Array, fatherNode:OntologyClass):OntologyIndividual{
			var uriNode:String = uri;
			var labelNode:String = findNodeLabel(uriNode,labels);
			var childNode:OntologyIndividual = new OntologyIndividual();
			this.addChild(fatherNode,childNode);
			childNode.setDataIndividual(uriNode,labelNode);
			childNode.x = fatherNode.x;
			childNode.y = fatherNode.y;
			return childNode;
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
		
/** -----------------------------------------Getters and Setters------------------------------------------------------- **/
		
		public function get individuals():Array{
			return _individuals;
		}
		
		public function set individuals(i:Array):void{
			_individuals = i;
		}
		
		public function get labels():Array{
			return _labels;
		}
		
		public function set labels(l:Array):void{
			_labels = l;
		}
		
		public function get childrenUri():Array{
			return _childrenUri;
		}
		
		public function set childrenUri(cu:Array):void{
			_childrenUri = cu;
		}
		
		public function get switchIndex():int{
			return _switchIndex;
		}
		
		public function set switchIndex(si:int):void{
			_switchIndex = si;	
		}
		public function get isLetterGraph():Boolean{
			return _isLetterGraph;
		}
		
		public function set isLetterGraph(ilg:Boolean):void{
			_isLetterGraph = ilg;	
		}
		
		public function get mapLetter():Object{
			return _mapLetter;
		}
		
		public function set mapLetter(ml:Object):void{
			_mapLetter = ml;
		}
		
		public function get letterChildren():Array{
			return _letterChildren;
		}
		
		public function set letterChildren(lc:Array):void{
			_letterChildren = lc;
		}
		
	} //end of Class IndividualGraph
}