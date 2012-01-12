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
 
package views{
	import buttons.ClassButton;
	import buttons.ForwardButton;
	import buttons.IndividualButton;
	
	import externalControls.MovingControl;
	import externalControls.PanZoomWithResetControl;
	
	import externalOperators.HtmlLabeler;
	
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.util.Orientation;
	import flare.vis.Visualization;
	import flare.vis.controls.ExpandControl;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import ontologyDataStructures.ClassGraph;
	
	import renderers.ClassRenderer;
	
	import switchers.ClassSwitcher;

/**
*
* @author Giuseppe Futia
*
*/	
	public class ClassGraphView extends Visualization{
		private var classGraph:ClassGraph;
		private var _changeViewController:ChangeViewController;
		private var _classButton:ClassButton;
		private var individualButton:IndividualButton;
		private var classSwitcher:ClassSwitcher;
		private var plusButton:ForwardButton;
		private var classRenderer:ClassRenderer;
		private var _currentClass:OntologyClass;
		private var timer:Timer;
		private var _isInTransition:Boolean = false;
		private var mainStage:Stage;
		
		private var expandControl:ExpandControl;
		private var _panZoomControl:PanZoomWithResetControl;
		private var movingControl:MovingControl;
		
		public function ClassGraphView(classGraph:ClassGraph,mainStage:Stage){
			this.data = classGraph;
			this.mainStage = mainStage;
			plusButton = new ForwardButton();
			classButton = new ClassButton();
			individualButton = new IndividualButton();
			classRenderer = new ClassRenderer();
			this.tree.nodes.visit(classRenderer.nodeVisit);
			classSwitcher = new ClassSwitcher(this,classGraph,classRenderer);
			//this.x = - 250; //I have to put this offset because of the presence of NodeLinkTreeLayout
			//this.y = - 120;
			initialSetting();
			this.update();
		}
		
		public function initialSetting():void{
			for(var i:int=0; i<this.tree.nodes.length; i++){
      			this.tree.nodes[i].addEventListener(MouseEvent.MOUSE_OVER, onClassNode);
      			this.tree.nodes[i].addEventListener(MouseEvent.MOUSE_OUT, outClassNode);
      		}
      		timer = new Timer(800,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,function():void{
      			removeButtons();
      		});
      		setClassButtonListeners();
			setIndividualsButtonListeners();
      		setOperators();
			setControls();
			setNormalState();
		}	
		
		public function setOperators():void{
			var labeler:HtmlLabeler = new HtmlLabeler("data.label",
													Data.NODES, 
													new TextFormat("Verdana", "14", "0xffffffff", true)
													,null,
													Labeler.CHILD);
      		this.operators.add(labeler);
      		var nodeLinkTreeLayout:NodeLinkTreeLayout = new NodeLinkTreeLayout(Orientation.TOP_TO_BOTTOM,37, 5, 10);
      		this.operators.add(nodeLinkTreeLayout);
      		this.update();
		}
		
		public function setControls():void{
			expandControl = new ExpandControl();
			expandControl.attach(this);
			expandControl.object.addEventListener(MouseEvent.CLICK,expandNodes);
			panZoomControl = new PanZoomWithResetControl();
			this.controls.add(panZoomControl);
			movingControl = new MovingControl(this,classButton,mainStage);
			this.controls.add(movingControl);
		}
		
		private function onClassNode(event:MouseEvent):void{
			var ontologyClass:OntologyClass = event.currentTarget as OntologyClass;
			if(ontologyClass == null)
				return;
			removeButtons();
			for(var i:int = 0; i<this.tree.nodes.length;i++){
				if(this.tree.nodes[i].getChildByName("plusButton")!=null && !isInTransition){
					this.tree.nodes[i].removeChild(plusButton);
				}
			}
			if(ontologyClass.data.childrenSubset >= 0 && ontologyClass.expanded == true && !isInTransition){
				ontologyClass.addChild(plusButton);	
			}
			currentClass = ontologyClass;	
			setClassButton(ontologyClass);
			setIndividualButton(ontologyClass);
		}
		
		private function outClassNode(event:MouseEvent):void{
			var ontologyClass:OntologyClass = event.currentTarget as OntologyClass;
			if(ontologyClass==null)
				return;
			timer.start();
		}
		
		private function expandNodes(event:MouseEvent):void{
			var ontologyClass:OntologyClass = event.target as OntologyClass;
			if(ontologyClass == null)
				return;
			var point:Point= new Point();
           	point.x = ontologyClass.x;
           	point.y = ontologyClass.y;
           	if(ontologyClass.data.lastPosX == null){
				ontologyClass.data.lastPosX = ontologyClass.parent.localToGlobal(point).x;
				ontologyClass.data.lastPosY = ontologyClass.parent.localToGlobal(point).y;
           	}
			var expandTransitioner:Transitioner = this.update(0.4);
			expandTransitioner.addEventListener(TransitionEvent.START,expandTransitionStarted);
			expandTransitioner.addEventListener(TransitionEvent.END,expandTransitionFinished);
			removeButtons();
			if(!isInTransition)
				expandTransitioner.play();
			//var point:Point = new Point(0,0);
			//currentClass.localToGlobal(point)
			//trace("x position node: "+currentClass.localToGlobal(point).x);
			//trace("y position node: "+currentClass.localToGlobal(point).y);
			//trace("mainStage width: "+mainStage.width);
		}
		
		private function clickClassButton(event:MouseEvent):void{
			var point:Point= new Point();
           	point.x=currentClass.x;
           	point.y=currentClass.y;
           	if(currentClass.data.lastPosX==null){
           		currentClass.data.lastPosX=currentClass.parent.localToGlobal(point).x;
           		currentClass.data.lastPosY=currentClass.parent.localToGlobal(point).y;
           	}
			currentClass.expanded = true;
			removeButtons();
			var expandTransitioner:Transitioner = this.update(0.4);
			expandTransitioner.addEventListener(TransitionEvent.START,expandTransitionStarted);
			expandTransitioner.addEventListener(TransitionEvent.END,expandTransitionFinished);
			expandTransitioner.play();
		}
		
		private function showIndividuals(event:MouseEvent):void{
			removeButtons();
			changeViewController.changeView(currentClass,"View Individuals");
		}
		
		private function expandTransitionStarted(event:TransitionEvent):void{
			setTransitionState();
			removeButtons();
		}
		
		private function expandTransitionFinished(event:TransitionEvent):void{
			var ontologyClass:OntologyClass = currentClass;
			if (ontologyClass == null)
				return;
			if(ontologyClass.data.childrenSubset >= 0 && ontologyClass.expanded == true){
				plusButton.addEventListener(MouseEvent.CLICK,switchNodes);
			}
			else if(ontologyClass.getChildByName("forwardButton")!=null){
				ontologyClass.removeChild(plusButton);
			}
			setNormalState();		
			removeButtons();
			setClassButton(ontologyClass);
			setIndividualButton(ontologyClass);
			movingControl.checkNodePosition(currentClass);
		}
		
		private function setClassButton(ontologyClass:OntologyClass):void{
			if(ontologyClass.expanded==false && ontologyClass.childDegree>0 && isInTransition==false){
      			timer.stop();
      			classButton.x=ontologyClass.x;
      			classButton.y=ontologyClass.y;
      			classButton.name="classButton";
      			this.addChild(classButton);
   			}
			if(ontologyClass.childDegree>0){
				ontologyClass.buttonMode = true;
			}
		}
		
		public function setIndividualButton(ontologyClass:OntologyClass):void{
			if(ontologyClass.data.hasIndividuals){
				timer.stop();
				individualButton.x=ontologyClass.x;
				individualButton.y=ontologyClass.y;
				individualButton.name="individualButton";
				this.addChild(individualButton);
			}
		}
		
		private function removeButtons():void{
			if(this.getChildByName("classButton")!=null){
      			this.removeChild(classButton);
      		}
      		if(this.getChildByName("individualButton")!=null){
      			this.removeChild(individualButton);
      		} 
		}
		
		private function setClassButtonListeners():void{
			classButton.addEventListener(MouseEvent.ROLL_OVER,onButton);
			classButton.addEventListener(MouseEvent.ROLL_OUT,outButton);
  			classButton.addEventListener(MouseEvent.MOUSE_DOWN,clickClassButton);
		}
		
		private function setIndividualsButtonListeners():void{
			individualButton.addEventListener(MouseEvent.ROLL_OVER,onButton);
			individualButton.addEventListener(MouseEvent.ROLL_OUT,outButton);
			individualButton.addEventListener(MouseEvent.CLICK,showIndividuals);
		}
		
		private function onButton(event:MouseEvent):void{
			timer.stop();
		}
		
		private function outButton(event:MouseEvent):void{
			timer.start();
		}
		
		private function switchNodes(event:MouseEvent):void{
			removeButtons();
			classSwitcher.switchNodes(event.currentTarget.parent);
		}
		
		public function putExpandedChildren(thingNode:OntologyClass):Array{
			var thingChildren:Array = new Array();
			for (var i:int=0; i<thingNode.childDegree; i++){
				if(thingNode.getChildNode(i).expanded==true){
					thingChildren.push(thingNode.getChildNode(i));
				}
			}
			return thingChildren;
		}
		
		public function setNodesExpansion(thingChildren:Array):void{
			for(var i:int=0; i<thingChildren.length; i++){
				thingChildren[i].expanded = !thingChildren[i].expanded
			}
		}
		
		public function setTransitionState():void{
			isInTransition = true;
			for(var i:int=0; i<this.tree.nodes.length; i++){
				if(this.tree.nodes[i].getChildByName("forwardButton")!=null)
					plusButton.removeEventListener(MouseEvent.CLICK,switchNodes);
				this.tree.nodes[i].removeEventListener(MouseEvent.MOUSE_OVER, onClassNode);
				this.tree.nodes[i].removeEventListener(MouseEvent.MOUSE_OUT, outClassNode);
			}
		}
		
		public function setPreviewState():void{
			panZoomControl.inProcess = true;
			for(var i:int=0; i<this.tree.nodes.length; i++){
				if(this.tree.nodes[i].getChildByName("forwardButton")!=null){
					plusButton.removeEventListener(MouseEvent.CLICK,switchNodes);
					this.tree.nodes[i].removeChild(plusButton);
				}
				this.tree.nodes[i].removeEventListener(MouseEvent.MOUSE_OVER, onClassNode);
				this.tree.nodes[i].removeEventListener(MouseEvent.MOUSE_OUT, outClassNode);
			}
			this.controls.remove(expandControl);			
			this.buttonMode = true;
		}
		
		public function setNormalState():void{
			isInTransition = false;
			panZoomControl.inProcess = false;
			for(var i:int=0; i<this.tree.nodes.length; i++){
				if(this.tree.nodes[i].getChildByName("forwardButton")!=null)
					plusButton.addEventListener(MouseEvent.CLICK,switchNodes);
				this.tree.nodes[i].addEventListener(MouseEvent.MOUSE_OVER, onClassNode);
				this.tree.nodes[i].addEventListener(MouseEvent.MOUSE_OUT, outClassNode);
			}
			this.controls.add(expandControl);	
			this.buttonMode = false;
		}
		
/**------------------------------------------ Getters and setters ----------------------------------------------*/		
		
		public function get currentClass():OntologyClass{
			return _currentClass;
		}	
		
		public function set currentClass(cc:OntologyClass):void{
			this._currentClass = cc;
		}	
		
		public function get changeViewController():ChangeViewController{
			return _changeViewController;
		}	
		
		public function set changeViewController(cvc:ChangeViewController):void{
			this._changeViewController = cvc;
		}

		public function get classButton():ClassButton{
			return _classButton;
		}	
		
		public function set classButton(cb:ClassButton):void{
			this._classButton = cb;
		}	
		
		public function get isInTransition():Boolean{
			return _isInTransition;
		}	
		
		public function set isInTransition(iit:Boolean):void{
			this._isInTransition = iit;
		}
		
		public function get panZoomControl():PanZoomWithResetControl{
			return _panZoomControl;
		}
		
		public function set panZoomControl(pzc:PanZoomWithResetControl):void{
			_panZoomControl = pzc;
		}
	}
}