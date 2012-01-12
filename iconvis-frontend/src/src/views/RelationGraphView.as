package views{
	import buttons.BackButton;
	import buttons.LetterButton;
	
	import externalLayouts.RootInCenterCircleLayout;
	
	import externalOperators.HtmlLabeler;
	
	import flare.animate.TransitionEvent;
	import flare.animate.Tween;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.profiler.showRedrawRegions;
	import flash.text.TextFormat;
	
	import ontologyDataStructures.IndividualGraph;
	import ontologyDataStructures.RelationGraph;
	
	import renderers.IndividualRender;
	
	import switchers.RelationSwitcher;
	
	public class RelationGraphView extends Visualization{
		private var relations:Array;
		private var relationGraph:RelationGraph;
		private var relationSwitcher:RelationSwitcher;
		private var changeViewController:ChangeViewController;
		//private var _isInTransition:Boolean = false;
		private var individualRenderer:IndividualRender;
		//private var switcherAnimator:SwitcherAnimator;
		private var backButton:BackButton;
		
		private var _uriPredicates:Array;
		private var _uriObjects:Array;
		
		public function RelationGraphView(relationsGraph:RelationGraph,changeViewController:ChangeViewController,relations:Array){
			this.relationGraph = relationsGraph;
			this.changeViewController = changeViewController;
			this.data = relationsGraph;
			this.relations = relations;
			backButton = new BackButton();
			individualRenderer = new IndividualRender();
			relationSwitcher = new RelationSwitcher(this,relationGraph,individualRenderer);
			nodesRender(relationsGraph);
			setOperators();
			setEdgeLabelsVisualization();
			checkStatusGraph(relationsGraph);
		}
		
		public function setOperators():void{
			var labeler:HtmlLabeler = new HtmlLabeler("data.label",
				Data.NODES, 
				new TextFormat("Verdana", "14", "0xffffffff", true),
				null,
				Labeler.CHILD);
			this.operators.add(labeler);
			var edgelabeler:HtmlLabeler=new HtmlLabeler("data.label",Data.EDGES, new TextFormat("Verdana", "14", "0xff000000", true),null,Labeler.CHILD);
			this.operators.add(edgelabeler);
			var rootInCircleLayout:RootInCenterCircleLayout = new RootInCenterCircleLayout();
			this.operators.add(rootInCircleLayout);
			this.update();
		}
		
		public function nodesRender(relationsGraph:RelationGraph):void{
			var rootNode:OntologyIndividual = relationsGraph.tree.nodes[0];
			rootNode.renderer = individualRenderer;
			for(var i:int = 0; i<rootNode.childDegree; i++){
				rootNode.getChildNode(i).renderer = individualRenderer;	
			}
			relationSwitcher.setButton(rootNode);
		}
		
		public function setEdgeLabelsVisualization():void{
			this.data.edges.visit(function(es:EdgeSprite):void{
				es.addEventListener(Event.RENDER,updateEdgeLabelPosition);
			});
			this.data.edges.setProperties({
				"props.label.textField.textColor":0x000000
			});	
		}
		
		private function updateEdgeLabelPosition(evt:Event):void {
			var es:EdgeSprite = evt.target as EdgeSprite;
			es.props.label.x = (es.source.x + es.target.x) / 2;
			es.props.label.y = (es.source.y + es.target.y) / 2-10;	
		}
		
		public function checkStatusGraph(relationsGraph:RelationGraph):void{
			var rootNode:OntologyIndividual = tree.nodes[0];
			if(relationsGraph.status == 0){
				for(var i:int = 0; i<rootNode.childDegree;i++){
					rootNode.getChildNode(i).buttonMode = true;
					if(rootNode.getChildNode(i).data.uri>relationsGraph.switchIndex*relationsGraph.groupIndex){
						rootNode.getChildNode(i).addEventListener(MouseEvent.CLICK,changeNumbersInLetters);
					}
					else{
						rootNode.getChildNode(i).addEventListener(MouseEvent.CLICK,changeNumbersInIndividuals);	
					}
				}
			}
			else if(relationsGraph.status == 1){
				for(var j:int = 0; j<rootNode.childDegree;j++){
					rootNode.getChildNode(j).buttonMode = true;
					rootNode.getChildNode(j).addEventListener(MouseEvent.CLICK,changeLettersInIndividuals);	
				}
			}
			else if(relationsGraph.status == 2){
				for(var j:int = 0; j<rootNode.childDegree;j++){
					rootNode.getChildNode(j).buttonMode = true;
					rootNode.getChildNode(j).addEventListener(MouseEvent.CLICK, showNewRelations);	
				}
			}
		}
		
		public function changeNumbersInLetters(event:MouseEvent):void{
			relationGraph.status = 1;
			var rootNode:OntologyIndividual = event.currentTarget.parentNode;
			var edgeParent:String = event.currentTarget.parentEdge.data.label;
			relationGraph.setRelationsLettersChildren(relationGraph.uriObjects);
			var letterObjects:Array = relationGraph.letterObjects;
			if(letterObjects.length>relationGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			for(var i:int = 0; i<letterObjects.length; i++){
				relationGraph.letterPredicates.push(edgeParent);
			}
			var letterPredicates:Array = relationGraph.letterPredicates;
			//trace("Le lettere sono: "+letterObjects);
			//trace("Le relazioni delle lettere: "+letterPredicates);
			relationSwitcher.removeNodes(rootNode);
			relationGraph.createRootChildren(rootNode,letterObjects,letterPredicates,rootNode.data.childrenSubset);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			relationSwitcher.setButton(rootNode);
			this.addChild(backButton);
			backButton.addEventListener(MouseEvent.CLICK,changeLettersInNumbers);
			checkStatusGraph(relationGraph);
			setEdgeLabelsVisualization();
		}
		
		public function changeNumbersInIndividuals(event:MouseEvent):void{
			//trace("Dentro changeNumbersInIndividuals");
			relationGraph.status = 2;
			var ontologyIndividual:OntologyIndividual = OntologyIndividual(event.currentTarget);
			var rootNode = ontologyIndividual.parentNode;
			var edgeParent:String = event.currentTarget.parentEdge.data.uri;
			uriPredicates = new Array();
			uriObjects = new Array();
			var relations:Array = relationGraph.relations;
			//trace("Uri soggetto: "+rootNode.data.uri);
			//trace("Uri predicato: "+edgeParent);
			
			for(var i:int = 0; i<relations.length; i++){
				if(relations[i][0]==rootNode.data.uri && relations[i][1]==edgeParent){
					uriPredicates.push(edgeParent);
					uriObjects.push(relations[i][2]);
				}
			}
			if(uriObjects.length>relationGraph.switchIndex){
				rootNode.setChildrenSubset(0);
			}
			else 
				rootNode.setChildrenSubset(-1);
			relationSwitcher.removeNodes(rootNode);
			relationGraph.createRootChildren(rootNode,uriObjects,uriPredicates,rootNode.data.childrenSubset);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			relationSwitcher.setButton(rootNode);
			checkStatusGraph(relationGraph);
			setEdgeLabelsVisualization();
		}
		
		public function changeLettersInIndividuals(event:MouseEvent):void{
			trace("Dentro Change Letters In Individuals");
			relationGraph.status = 2;
			var individualLetter:OntologyIndividual = OntologyIndividual(event.currentTarget);
			var letter:String = individualLetter.data.uri;
			var rootNode = individualLetter.parentNode;
			var edgeParent:String = event.currentTarget.parentEdge.data.uri;
			uriPredicates = new Array();
			var mapLetter:Object = relationGraph.mapLetter;
			var uriObjectsString:String = mapLetter[letter].replace("undefined","");
			uriObjects = uriObjectsString.split(",");
			uriObjects.pop();
			relationSwitcher.removeNodes(rootNode);
			if(uriObjects.length>relationGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			for(var i:int = 0; i<uriObjects.length; i++){
				uriPredicates.push(edgeParent);
			}
			relationGraph.createRootChildren(rootNode,uriObjects,uriPredicates,rootNode.data.childrenSubset);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			backButton.removeEventListener(MouseEvent.CLICK,changeLettersInNumbers);
			backButton.addEventListener(MouseEvent.CLICK,changeIndividualsInLetters);	
			relationSwitcher.removeButton(rootNode);
			relationSwitcher.setButton(rootNode);
			checkStatusGraph(relationGraph);
			setEdgeLabelsVisualization();
		}
		
		private function changeLettersInNumbers(event:MouseEvent):void{
			var rootNode:OntologyIndividual = this.tree.nodes[0];
			relationGraph.status = 0;
			if(relationGraph.numberObjects.length>relationGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			relationSwitcher.removeNodes(rootNode);
			relationGraph.createRootChildren(rootNode,relationGraph.numberObjects,relationGraph.numberPredicates,rootNode.data.childrenSubset);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			relationSwitcher.setButton(rootNode);
			checkStatusGraph(relationGraph);
			setEdgeLabelsVisualization();
			backButton.removeEventListener(MouseEvent.CLICK,changeLettersInNumbers);
			this.removeChild(backButton);
		}
		
		private function changeIndividualsInLetters(event:MouseEvent):void{
			relationGraph.status = 1;
			var rootNode:OntologyIndividual = this.tree.nodes[0];
			if(relationGraph.letterObjects.length>relationGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			relationSwitcher.removeNodes(rootNode);
			relationGraph.createRootChildren(rootNode,relationGraph.letterObjects,relationGraph.letterPredicates,rootNode.data.childrenSubset);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			relationSwitcher.setButton(rootNode);
			checkStatusGraph(relationGraph);
			setEdgeLabelsVisualization();
			backButton.removeEventListener(MouseEvent.CLICK,changeIndividualsInLetters);	
			backButton.addEventListener(MouseEvent.CLICK,changeLettersInNumbers);
		}
		
		private function showNewRelations(event:MouseEvent):void{
			if(this.getChildByName("backButton")!=null){
				this.removeChild(backButton);
			}
			var tween:Tween = new Tween(this,0.7,{alpha:0});
			tween.addEventListener(TransitionEvent.END,function():void{
				changeViewController.changeView(NodeSprite(event.target),"View New Relations");
			}); 
			tween.play();
		}
		
		public function get uriObjects():Array{
			return _uriObjects;
		}
		
		public function set uriObjects(uo:Array){
			_uriObjects = uo;
		}
		
		public function get uriPredicates():Array{
			return _uriPredicates;
		}
		
		public function set uriPredicates(up:Array):void{
			_uriPredicates = up;
		}
	}
}