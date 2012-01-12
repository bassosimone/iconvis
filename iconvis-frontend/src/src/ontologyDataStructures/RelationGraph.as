package ontologyDataStructures{
	import flare.vis.data.Tree;
	
	public class RelationGraph extends Tree{
		//private var _individuals:Array
		private var _relations:Array;
		private var _labels:Array; 
		
		private var _uriPredicates:Array;
		private var _uriObjects:Array;
		
		private var _letterPredicates:Array;
		private var _letterObjects:Array;
		
		private var _numberPredicates:Array;
		private var _numberObjects:Array;
		
		private var _switchIndex:int = 8;
		private var _groupIndex:int = 5;
		private var relationsNumber:int = 8;
		private var _status:int= 0; //Se status = 0 --> riepilogo numeri. Se staus = 1 --> Lettere. Se status = 2 relazioni
		private var _mapLetter:Object;
		
		public function RelationGraph(relations:Array,labels:Array){
			this.relations = relations;
			this.labels = labels;
			uriPredicates = new Array();
			uriObjects = new Array(); 
			numberPredicates = new Array();
			numberObjects = new Array();
			letterPredicates = new Array();
			letterObjects = new Array();
		}
		
		public function createStructure(ontologyIndividual:OntologyIndividual):void{
			var rootNode:OntologyIndividual = new OntologyIndividual();
			rootNode.setDataIndividual(ontologyIndividual.data.uri,ontologyIndividual.data.label,-1);
			this.root = rootNode;
			rootNode.expanded = true;
			//var uriPredicatesLabel:Array = new Array();
			for(var i:int = 0; i<relations.length; i++){
				if(relations[i][0] == rootNode.data.uri){
					uriPredicates.push(relations[i][1]);
					uriObjects.push(relations[i][2]);
					//uriPredicatesLabel.push(relations[i][1]);
				}
			}
			//trace("Predicati: "+uriPredicatesLabel);
			//trace("Oggetti: "+uriBojectsLabel);
			//trace("Il numero di relazioni è: "+uriObjects.length);
			if(uriPredicates.length>relationsNumber){
				//trace("Sì il numero di relazioni supera il limite di :"+relationsNumber);
				status = 0;
				setRelationsNumberChildren(uriPredicates,numberPredicates,numberObjects);
				if(numberObjects.length>switchIndex)
					rootNode.setChildrenSubset(0);
				else
					rootNode.setChildrenSubset(-1);
				createRootChildren(rootNode,numberObjects,numberPredicates,rootNode.data.childrenSubset);
			}
			else{
				//trace("No il numero di relazioni non supera il limite di :"+relationsNumber);
				status = 2;
				if(uriObjects.length>switchIndex)
					rootNode.setChildrenSubset(0);
				else
					rootNode.setChildrenSubset(-1);
				createRootChildren(rootNode,uriObjects,uriPredicates,rootNode.data.childrenSubset);
			}
			
			//Gestione delle lettere riguardanti una specifica relazione
			//Gestione degli individui di una certe lettera, che sono legate all'individuo centrale con una specifica relazione
		}
		
		public function setRelationsNumberChildren(uriPredicates:Array,numberPredicates:Array,numberObjects:Array):void{
			var count:int = 1;
			numberPredicates[0] = uriPredicates[0];
			
			var uriP:Array = uriPredicates.sort();
			for(var i:int = 0; i<uriP.length; i++){
				if(i>0){
					if(uriP[i]==uriP[i-1]){
						count++;
					}
					else{
						numberPredicates.push(uriP[i]);
						numberObjects.push(count);
						count = 1;
					}
				}
				if(i == uriP.length-1){
					if(uriP[i]==uriP[i-1]){
						count++;
						numberObjects.push(count);
					}
					else{
						numberPredicates.push(uriP[i]);
						numberObjects.push(1);
					}
				}
			}
		}
		
		public function setRelationsLettersChildren(uriObjects:Array):void{
			var rootNode:OntologyIndividual = this.nodes[0];
			var indexGenerator:IndexGenerator = new IndexGenerator(uriObjects,labels);
			var subset:int;
			mapLetter = indexGenerator.mapLetter;
			letterObjects = indexGenerator.letterChildren;
		}
		
		public function createRootChildren(rootNode:OntologyIndividual,objects:Array,predicates:Array,subset:int):void{
			if(subset == -1){
				for(var i:int = 0; i<switchIndex; i++){
					if(objects[i] != null){
						var childNode:OntologyIndividual = createChildNode(objects[i],predicates[i],labels,rootNode);
					}	
				}
			}else{
				for(var j:int = subset*switchIndex; j<(subset+1)*switchIndex; j++){
					if(objects[j] != null){
						var childNode:OntologyIndividual = createChildNode(objects[j],predicates[j],labels,rootNode);
					}
				}
			}
		}
		
		public function createChildNode(uri:String, uriE, labels:Array, fatherNode:OntologyIndividual):OntologyIndividual{
			var uriNode:String = uri;
			var uriEdge:String = uriE;
			var labelNode:String = findNodeLabel(uriNode,labels);
			var childNode:OntologyIndividual = new OntologyIndividual();
			this.addChild(fatherNode,childNode);
			childNode.parentEdge.data.label = findNodeLabel(uriEdge,labels);
			childNode.parentEdge.data.uri = uriEdge;
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
		
		public function get relations():Array{
			return _relations;
		}
		
		public function set relations(r:Array):void{
			_relations = r;
		}
		
		public function get labels():Array{
			return _labels;
		}
		
		public function set labels(l:Array):void{
			_labels = l;
		}
		
		public function get uriPredicates():Array{
			return _uriPredicates;
		}
		
		public function set uriPredicates(up:Array):void{
			_uriPredicates = up;
		}
		
		public function get uriObjects():Array{
			return _uriObjects;
		}
		
		public function set uriObjects(uo:Array):void{
			_uriObjects = uo;
		}
		
		public function get numberPredicates():Array{
			return _numberPredicates;
		}
		
		public function set numberPredicates(np:Array):void{
			_numberPredicates = np;
		}
		
		public function get numberObjects():Array{
			return _numberObjects;
		}
		
		public function set numberObjects(no:Array):void{
			_numberObjects = no;
		}
		
		public function get letterPredicates():Array{
			return _letterPredicates;
		}
		
		public function set letterPredicates(lo:Array):void{
			_letterPredicates = lo;
		}
		
		public function get letterObjects():Array{
			return _letterObjects;
		}
		
		public function set letterObjects(lo:Array):void{
			_letterObjects = lo;
		}
		
		public function get switchIndex():int{
			return _switchIndex;
		}
		
		public function set switchIndex(si:int):void{
			_switchIndex = si;	
		}
		
		public function get groupIndex():int{
			return _groupIndex;
		}
		
		public function set groupIndex(gi:int):void{
			_groupIndex = gi;	
		}
		
		public function get status():int{
			return _status;
		}
		
		public function set status(s:int):void{
			_status = s;	
		}
		
		public function get mapLetter():Object{
			return _mapLetter;
		}
		
		public function set mapLetter(ml:Object):void{
			_mapLetter = ml;
		}
	} // end of class RelationGraph
}