package switchers{
	import animations.SwitcherAnimator;
	
	import buttons.BackwardButton;
	import buttons.ForwardButton;
	
	import flare.animate.TransitionEvent;
	import flare.vis.data.EdgeSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ontologyDataStructures.RelationGraph;
	
	import renderers.IndividualRender;
	
	import views.RelationGraphView;
	
	public class RelationSwitcher{
		private var relationGraphView:RelationGraphView;
		private var relationGraph:RelationGraph;
		private var individualRenderer:IndividualRender;
		private var relations:Array;
		private var switchIndex:int;
		private var switcherAnimator:SwitcherAnimator;
		private var forwardButton:ForwardButton;
		private var backwardButton:BackwardButton;
		
		public function RelationSwitcher(relationGraphView:RelationGraphView, relationGraph:RelationGraph, individualRenderer:IndividualRender){
			this.relationGraphView = relationGraphView;
			this.relationGraph = relationGraph;
			this.individualRenderer = individualRenderer;
			this.relations = relationGraph.relations;
			forwardButton = new ForwardButton();
			backwardButton = new BackwardButton();
			switchIndex = relationGraph.switchIndex;
			switcherAnimator = new SwitcherAnimator();
		}
		
		public function setButton(rootNode:OntologyIndividual):void{
			if(rootNode.data.childrenSubset>=0){
				forwardButton.addEventListener(MouseEvent.CLICK,forwardNodes);
				forwardButton.buttonMode = true;
				forwardButton.alpha = 1;
				rootNode.addChild(forwardButton);
				backwardButton.buttonMode = false;
				backwardButton.alpha = 0.5;
				backwardButton.addEventListener(MouseEvent.CLICK,backwardNodes);
				rootNode.addChild(backwardButton);
			}
			else{
				removeButton(rootNode);
			}
		}
	
		public function removeButton(rootNode:OntologyIndividual):void{
			if(rootNode.getChildByName("forwardButton")!=null){
				forwardButton.removeEventListener(MouseEvent.CLICK,forwardNodes);
				rootNode.removeChild(forwardButton);
				backwardButton.removeEventListener(MouseEvent.CLICK,backwardNodes);
				rootNode.removeChild(backwardButton);
			}
		}
		
		public function forwardNodes(event:MouseEvent):void{
			var ontologyIndividual:OntologyIndividual = event.currentTarget.parent;
			if(hasConditionForForward(ontologyIndividual)){
				ontologyIndividual.setChildrenSubset(ontologyIndividual.data.childrenSubset+1);
				var subset:int = ontologyIndividual.data.childrenSubset;
				switchNodes(ontologyIndividual,subset);
				if(hasConditionForBackward(ontologyIndividual)){
					backwardButton.buttonMode = true;
					backwardButton.alpha = 1;
				}
				if(!hasConditionForForward(ontologyIndividual)){
					forwardButton.buttonMode = false;
					forwardButton.alpha = 0.5;
				}
			}
		}
		
		public function backwardNodes(event:MouseEvent):void{
			var ontologyIndividual:OntologyIndividual = event.currentTarget.parent;
			if(hasConditionForBackward(ontologyIndividual)){
				ontologyIndividual.setChildrenSubset(ontologyIndividual.data.childrenSubset-1);
				var subset:int = ontologyIndividual.data.childrenSubset;
				switchNodes(ontologyIndividual,subset);
				if(!hasConditionForBackward(ontologyIndividual)){
					backwardButton.buttonMode = false;
					backwardButton.alpha = 0.5;
				}
				if(hasConditionForForward(ontologyIndividual)){
					forwardButton.buttonMode = true;
					forwardButton.alpha = 1;
				}
			}
		}
		
		public function switchNodes(ontologyIndividual:OntologyIndividual,subset:int):void{
			for (var i:int=0; i<ontologyIndividual.childDegree; i++){
				if(i==ontologyIndividual.childDegree-1){
					switcherAnimator.animOut(ontologyIndividual.getChildNode(i),i-0.8*i).addEventListener(TransitionEvent.END, function():void{
						removeNodes(ontologyIndividual);
						restoreNodes(ontologyIndividual,subset);
						relationGraphView.checkStatusGraph(relationGraph); //FONDAMENTALE PER LA GESTIONE DEI LISTENER DOPO LO SWITCH --> Lo faccio subito dopo che ho fatto il restore dei nodi
						relationGraphView.update(0.25).play();
						for(var r:int=0; r<ontologyIndividual.childDegree; r++){
							switcherAnimator.animIn(ontologyIndividual.getChildNode(r),0).addEventListener(TransitionEvent.END,function():void{
								
							});
						}
						relationGraphView.setEdgeLabelsVisualization();
					});	
				}
				else{
					switcherAnimator.animOut(ontologyIndividual.getChildNode(i),i-0.80*i);
				} 
			}
		}
		
		public function hasConditionForForward(ontologyIndividual:OntologyIndividual):Boolean{
			var hasCondition:Boolean = false;
			var children:Array = new Array();
			var subset:int = ontologyIndividual.data.childrenSubset+1;
			if(relationGraph.status == 0){
				children = relationGraph.numberObjects;
			}		
			else if(relationGraph.status == 1){
				children = relationGraph.letterObjects;
			}	
			else if(relationGraph.status == 2){
				if(relationGraphView.uriObjects!=null)
					children = relationGraphView.uriObjects;
				else children = relationGraph.uriObjects;
			}	
			if(children[subset*switchIndex]!=undefined)
				hasCondition = true;
			else hasCondition = false;
			return hasCondition;
		}
		
		public function hasConditionForBackward(ontologyIndividual:OntologyIndividual):Boolean{
			var hasCondition:Boolean;
			var children:Array = new Array();
			var subset:int = ontologyIndividual.data.childrenSubset;
			if(subset == 0)
				hasCondition = false;
			else hasCondition = true;
			return hasCondition;
		}
		
		public function removeNodes(ontologyIndividual:OntologyIndividual):void{
			while(ontologyIndividual.childDegree>0)
				relationGraphView.tree.remove(ontologyIndividual.lastChildNode);
		}
		
		public function restoreNodes(ontologyIndividual:OntologyIndividual,subset:int):void{
			var children:Array = new Array();
			var relations:Array = new Array();
			if(relationGraph.status == 0){
				children = relationGraph.numberObjects;
				relations = relationGraph.numberPredicates;
			}		
			else if(relationGraph.status == 1){
				children = relationGraph.letterObjects;
				relations = relationGraph.letterPredicates;
			}	
			else if(relationGraph.status == 2){
				if(relationGraphView.uriObjects!=null){
					relations = relationGraphView.uriPredicates;
					children = relationGraphView.uriObjects;
				}else{
					relations = relationGraph.uriPredicates;
					children = relationGraph.uriObjects;	
				}
			}	
			relationGraph.createRootChildren(ontologyIndividual,children,relations,subset);
			for(var j:int = 0; j<ontologyIndividual.childDegree; j++){
				ontologyIndividual.getChildNode(j).renderer = individualRenderer;
			}
		}
	}
}