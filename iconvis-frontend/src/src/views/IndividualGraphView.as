package views{
	
	import animations.SwitcherAnimator;
	
	import buttons.ForwardButton;
	import buttons.IndividualButton;
	import buttons.LetterButton;
	
	import externalControls.PanZoomWithResetControl;
	
	import externalLayouts.RootInCenterCircleLayout;
	
	import externalOperators.HtmlLabeler;
	
	import flare.animate.Tween;
	import flare.util.Orientation;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.IndentedTreeLayout;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import ontologyDataStructures.IndividualGraph;
	
	import renderers.ClassRenderer;
	import renderers.IndividualRender;
	
	import switchers.IndividualSwitcher;
	
	public class IndividualGraphView extends Visualization{
		private var relations:Array;
		private var individualGraph:IndividualGraph;
		private var individualSwitcher:IndividualSwitcher;
		private var _panZoomControl:PanZoomWithResetControl;
		private var changeViewController:ChangeViewController;
		private var _isInTransition:Boolean = false;
		private var classRenderer:ClassRenderer;
		private var individualRenderer:IndividualRender;
		private var switcherAnimator:SwitcherAnimator;
		private var letterButton:LetterButton;
		
		private var count:int = 0;
		
		public function IndividualGraphView(individualGraph:IndividualGraph,changeViewController:ChangeViewController,relations:Array){
			this.individualGraph = individualGraph;
			this.changeViewController = changeViewController;
			this.data = individualGraph;
			this.relations = relations;
			classRenderer = new ClassRenderer();
			individualRenderer = new IndividualRender();
			individualSwitcher = new IndividualSwitcher(this, individualGraph, individualRenderer);
			switcherAnimator = new SwitcherAnimator();
			nodesRender(individualGraph);
			setOperators();
			checkStatusGraph(individualGraph);
		}
		
		public function setOperators():void{
			var labeler:HtmlLabeler = new HtmlLabeler("data.label",
													Data.NODES, 
													new TextFormat("Verdana", "14", "0xffffffff", true),
													null,
													Labeler.CHILD);
			this.operators.add(labeler);
			var rootInCircleLayout:RootInCenterCircleLayout= new RootInCenterCircleLayout();
			this.operators.add(rootInCircleLayout);
			panZoomControl = new PanZoomWithResetControl();
			this.controls.add(panZoomControl);
			this.update();
		}
		
		public function nodesRender(individualGraph:IndividualGraph):void{
			var rootNode:OntologyClass = individualGraph.tree.nodes[0];
			rootNode.renderer = classRenderer;
			for(var i:int = 0; i<rootNode.childDegree; i++){
				rootNode.getChildNode(i).renderer = individualRenderer;	
			}
			individualSwitcher.setButton(rootNode);
		}
		
		public function checkStatusGraph(individualGraph:IndividualGraph):void{
			var rootNode:OntologyClass = tree.nodes[0];
			if(individualGraph.isLetterGraph){
				for(var i:int = 0; i<rootNode.childDegree;i++){
					rootNode.getChildNode(i).buttonMode = true;
					rootNode.getChildNode(i).addEventListener(MouseEvent.CLICK,changeLettersInIndividuals);
				}
			} 
			else{
				for(var j:int = 0; j<rootNode.childDegree; j++){
					if(individualHasRelations(rootNode.getChildNode(j) as OntologyIndividual)){
						rootNode.getChildNode(j).buttonMode = true;
						rootNode.getChildNode(j).addEventListener(MouseEvent.CLICK,showRelations);
					}	
				}
			} 
		}     
		
		public function individualHasRelations(IndividualNode:OntologyIndividual):Boolean{
			var hasRelations:Boolean = false
			var individualUri:String = IndividualNode.data.uri;
			//trace("L'uri dell'individuo è: "+individualUri);
			for (var j:int = 0; j<relations.length; j++){
				if(individualUri == relations[j][0]){
					//trace("cazzo");
					hasRelations = true;
					return hasRelations;
				}
			}	
			return hasRelations;	
		}
		
		public function changeLettersInIndividuals(event:MouseEvent):void{
			individualGraph.isLetterGraph = false;
			var individualLetter:OntologyIndividual = OntologyIndividual(event.currentTarget);
			var letter:String = individualLetter.data.uri;
			var rootNode = individualLetter.parentNode;
			var mapLetter:Object = individualGraph.mapLetter;
			//var childrenUri:Array = new Array();
			var childrenUriString:String = mapLetter[letter].replace("undefined","");
			var childrenUri:Array = childrenUriString.split(",");
			childrenUri.pop();
			individualSwitcher.removeNodes(rootNode);
			if(childrenUri.length>individualGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			individualGraph.createRootChildren(rootNode,childrenUri,rootNode.data.childrenSubset,individualGraph.isLetterGraph);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			individualSwitcher.setButton(rootNode);
			letterButton = new LetterButton();
			letterButton.addEventListener(MouseEvent.CLICK,changeIndividualsInLetters);
			rootNode.addChild(letterButton);
			checkStatusGraph(individualGraph);
			//var disappearTween:Tween = new Tween(this,0.7,{alpha:0});	
		}
		
		public function changeIndividualsInLetters(event:MouseEvent):void{
			individualGraph.isLetterGraph = true;
			var rootNode:OntologyClass = event.currentTarget.parent;
			var letterChildren:Array = individualGraph.letterChildren;
			if(letterChildren.length>individualGraph.switchIndex)
				rootNode.setChildrenSubset(0);
			else
				rootNode.setChildrenSubset(-1);
			individualSwitcher.removeNodes(rootNode);
			individualGraph.createRootChildren(rootNode,letterChildren,rootNode.data.childrenSubset,individualGraph.isLetterGraph);
			for(var j:int = 0; j<rootNode.childDegree; j++){
				rootNode.getChildNode(j).renderer = individualRenderer;
			}
			this.update();
			individualSwitcher.setButton(rootNode);
			letterButton.removeEventListener(MouseEvent.CLICK,changeIndividualsInLetters);
			rootNode.removeChild(letterButton);
			checkStatusGraph(individualGraph);
		}
		
		public function showRelations(event:MouseEvent):void{
			changeViewController.changeView(NodeSprite(event.currentTarget),"View Relations");
		}
		
		public function setTransitionState():void{
			var rootNode:OntologyClass = this.tree.nodes[0];
			for(var i:int = 0; i<rootNode.childDegree; i++){
				if(individualHasRelations(rootNode.getChildNode(i) as OntologyIndividual)){
					rootNode.getChildNode(i).buttonMode = false;
					rootNode.getChildNode(i).removeEventListener(MouseEvent.CLICK,showRelations);
				}	
			}
		}
		
		public function setPreviewState():void{
			panZoomControl.inProcess = true;
			this.buttonMode = true;
		}
		
		public function setNormalState():void{
			var rootNode:OntologyClass = this.tree.nodes[0];
			panZoomControl.inProcess = false;
			for(var i:int = 0; i<rootNode.childDegree; i++){
				if(individualHasRelations(rootNode.getChildNode(i) as OntologyIndividual)){
					rootNode.getChildNode(i).buttonMode = true;
					rootNode.getChildNode(i).addEventListener(MouseEvent.CLICK,showRelations);
				}	
			}
			this.buttonMode = false;
		}
		
/** -----------------------------------------Getters and Setters------------------------------------------------------- **/
		
		public function get panZoomControl():PanZoomWithResetControl{
			return _panZoomControl;
		}
		
		public function set panZoomControl(pzc:PanZoomWithResetControl):void{
			_panZoomControl = pzc;
		}
	}// end of Class IndividualGraphView 
}