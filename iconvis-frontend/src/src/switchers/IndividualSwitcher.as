package switchers{
	import animations.SwitcherAnimator;
	
	import buttons.BackwardButton;
	import buttons.ForwardButton;
	
	import flare.animate.TransitionEvent;
	
	import flash.events.MouseEvent;
	
	import ontologyDataStructures.IndividualGraph;
	
	import renderers.IndividualRender;
	
	import views.IndividualGraphView;
	
	public class IndividualSwitcher{
		private var individualGraphView:IndividualGraphView;
		private var individualGraph:IndividualGraph;
		private var individualRenderer:IndividualRender;
		private var individuals:Array;
		private var switchIndex:int;
		private var switcherAnimator:SwitcherAnimator;
		private var forwardButton:ForwardButton;
		private var backwardButton:BackwardButton;
		
		
		public function IndividualSwitcher(individualGraphView:IndividualGraphView, individualGraph:IndividualGraph, individualRenderer:IndividualRender){
			this.individualGraphView = individualGraphView;
			this.individualGraph = individualGraph;
			this.individualRenderer = individualRenderer;
			this.individuals = individualGraph.individuals;
			forwardButton = new ForwardButton();
			backwardButton = new BackwardButton();
			switchIndex = individualGraph.switchIndex;
			switcherAnimator = new SwitcherAnimator();
		}
		
		public function setButton(rootNode:OntologyClass):void{
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
			else if(rootNode.getChildByName("forwardButton")!=null){
				forwardButton.removeEventListener(MouseEvent.CLICK,forwardNodes);
				rootNode.removeChild(forwardButton);
				backwardButton.removeEventListener(MouseEvent.CLICK,backwardNodes);
				rootNode.removeChild(backwardButton);
			}
		}
		
		public function forwardNodes(event:MouseEvent):void{
			var ontologyClass:OntologyClass = event.currentTarget.parent;
			if(hasConditionForForward(ontologyClass)){
				ontologyClass.setChildrenSubset(ontologyClass.data.childrenSubset+1);
				var subset:int = ontologyClass.data.childrenSubset;
				switchNodes(ontologyClass,subset);
				if(hasConditionForBackward(ontologyClass)){
					backwardButton.buttonMode = true;
					backwardButton.alpha = 1;
				}
				if(!hasConditionForForward(ontologyClass)){
					forwardButton.buttonMode = false;
					forwardButton.alpha = 0.5;
				}
			}
		}
		
		public function backwardNodes(event:MouseEvent):void{
			var ontologyClass:OntologyClass = event.currentTarget.parent;
			if(hasConditionForBackward(ontologyClass)){
				ontologyClass.setChildrenSubset(ontologyClass.data.childrenSubset-1);
				var subset:int = ontologyClass.data.childrenSubset;
				switchNodes(ontologyClass,subset);
				if(!hasConditionForBackward(ontologyClass)){
					backwardButton.buttonMode = false;
					backwardButton.alpha = 0.5;
				}
				if(hasConditionForForward(ontologyClass)){
					forwardButton.buttonMode = true;
					forwardButton.alpha = 1;
				}
			}
		}
		
		public function switchNodes(ontologyClass:OntologyClass,subset:int):void{
			for (var i:int=0; i<ontologyClass.childDegree; i++){
				if(i==ontologyClass.childDegree-1){
					switcherAnimator.animOut(ontologyClass.getChildNode(i),i-0.8*i).addEventListener(TransitionEvent.END, function():void{
						removeNodes(ontologyClass);
						restoreNodes(ontologyClass,subset);
						individualGraphView.checkStatusGraph(individualGraph); //FONDAMENTALE PER LA GESTIONE DEI LISTENER DOPO LO SWITCH --> Lo faccio subito dopo che ho fatto il restore dei nodi
						individualGraphView.update(0.25).play();
						for(var r:int=0; r<ontologyClass.childDegree; r++){
							switcherAnimator.animIn(ontologyClass.getChildNode(r),0).addEventListener(TransitionEvent.END,function():void{
								//individualGraphView.setNormalState();
							});
						}
					});	
				}
				else{
					switcherAnimator.animOut(ontologyClass.getChildNode(i),i-0.80*i);
				} 
			}
		}
		
		public function hasConditionForForward(ontologyClass:OntologyClass):Boolean{
			var hasCondition:Boolean = false;
			var children:Array = new Array();
			var subset:int = ontologyClass.data.childrenSubset+1;
			if(individualGraph.isLetterGraph)
				children = individualGraph.letterChildren;
			else
				children = individualGraph.childrenUri
			if(children[subset*switchIndex]!=undefined)
				hasCondition = true;
			else hasCondition = false;
			return hasCondition;
		}
		
		public function hasConditionForBackward(ontologyClass:OntologyClass):Boolean{
			var hasCondition:Boolean;
			var subset:int = ontologyClass.data.childrenSubset;
			if(subset == 0)
				hasCondition = false;
			else hasCondition = true;
			return hasCondition;
		}
		
		public function removeNodes(ontologyClass:OntologyClass):void{
			while(ontologyClass.childDegree>0)
				individualGraphView.tree.remove(ontologyClass.lastChildNode);
		}
		
		public function restoreNodes(ontologyClass:OntologyClass,subset:int):void{
			var childrenUri:Array = new Array();
			if(individualGraph.isLetterGraph)
				childrenUri = individualGraph.letterChildren;
			else
				childrenUri = individualGraph.childrenUri
			individualGraph.createRootChildren(ontologyClass,childrenUri,subset,false);
			for(var j:int = 0; j<ontologyClass.childDegree; j++){
				ontologyClass.getChildNode(j).renderer = individualRenderer;
			}
		}
	}
}