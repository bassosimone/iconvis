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

package externalControls{
	import buttons.ClassButton;
	
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.util.Displays;
	import flare.vis.controls.Control;
	import flare.vis.data.NodeSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.events.ChildExistenceChangedEvent;
	
	import views.ClassGraphView;
	
/**
*
* @author Giuseppe Futia
*
*/			
	public class MovingControl extends Control{
		
		private var _hit:InteractiveObject;
		private var classGraphView:ClassGraphView;
		private var classButton:ClassButton;
		private var mainStage:Stage;
		private var dummyStage:Object;
		private var leftMostNodeFinded:NodeSprite; 
		private var rightMostNodeFinded:NodeSprite;
		private var leftMostPointFinded:Point;
		private var rightMostPointFinded:Point;
		private var currentClass:NodeSprite;
		
		public function MovingControl(classGraphView:ClassGraphView,classButton:ClassButton,mainStage:Stage){
			this.classGraphView = classGraphView;
			this.classButton = classButton;
			this.mainStage = mainStage;
			dummyStage = new Object();
			dummyStage.width = mainStage.width;
			dummyStage.height = mainStage.height;
			leftMostNodeFinded = new NodeSprite();
			rightMostNodeFinded = new NodeSprite();
			leftMostPointFinded = new Point(0,0);
			rightMostPointFinded = new Point(0,0);
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				if (obj.stage != null) onAdd();
				//originalMatrix = obj.transform.matrix;  //modification
				//zoomDelta = 1; //modification
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject{
			onRemove();
			_object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//originalMatrix = null; //modification
			return super.detach();
		}
		
		private function onAdd(evt:Event=null):void{
			//_stage = _object.stage;
			//if (_hit == null) {
				//_hit = _stage;
			//}
			_object.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			classButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownClassButton);	 
		}
		
		private function onRemove(evt:Event=null):void{
			_object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			classButton.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownClassButton);
		}
		
		private function onMouseDown(event:MouseEvent):void{
			var nodeSprite:NodeSprite = event.target as NodeSprite;
			if(nodeSprite == null)
				return;
			//smartMove(nodeSprite);	
		}
		
		private function onMouseDownClassButton(event:MouseEvent):void{
			var classButton:ClassButton = event.currentTarget as ClassButton;
			if(classButton == null)
				return;
			var nodeSprite:NodeSprite = classGraphView.currentClass;
		}
		
		public function checkNodePosition(nodeSprite:NodeSprite):void{
			//trace(firstChild.data.uri+" x globalpoint: "+firstGlobalPoint.x);
			currentClass = nodeSprite;
			var clickPoint:Point = new Point();
			clickPoint.x = currentClass.x; clickPoint.y = currentClass.y;
			currentClass.data.firstPosX = currentClass.parent.localToGlobal(clickPoint).x;
			currentClass.data.firstPosY = currentClass.parent.localToGlobal(clickPoint).y;
			
			if(nodeSprite.childDegree>0 && nodeSprite.expanded==true){
				var firstChild:NodeSprite = nodeSprite.firstChildNode;
				var lastChild:NodeSprite = nodeSprite.lastChildNode;
				var firstChildPoint:Point = new Point(0,0); firstChildPoint.x = firstChild.x; firstChildPoint.y = firstChild.y;
				var lastChildPoint:Point = new Point(0,0); lastChildPoint.x = lastChild.x; lastChildPoint.y = lastChild.y;
				
				var firstGlobalPoint:Point = new Point(firstChild.parent.localToGlobal(firstChildPoint).x, firstChild.parent.localToGlobal(firstChildPoint).y);        
				var lastGlobalPoint:Point = new Point(lastChild.parent.localToGlobal(lastChildPoint).x,lastChild.parent.localToGlobal(lastChildPoint).y);
				
				var leftMostNode:NodeSprite = firstChild;
				var rightMostNode:NodeSprite = lastChild;
				var leftMostPoint:Point = firstGlobalPoint;
				var rightMostPoint:Point = lastGlobalPoint;
				
				if(leftMostNode.expanded && leftMostNode.childDegree>0){
					var nodeChildren:Array = new Array();
					for(var i:int = 0; i<leftMostNode.childDegree; i++){
						nodeChildren.push(leftMostNode.getChildNode(i));
					}
					checkLeftMostNode(nodeChildren,leftMostNode,firstGlobalPoint);
					leftMostPoint = leftMostPointFinded;
				}
				
				if(rightMostNode.expanded && rightMostNode.childDegree>0){
					//trace("Il nodo più a destra è espanso");
					var nodeChildren:Array = new Array();
					for(var i:int = 0; i<rightMostNode.childDegree; i++){
						nodeChildren.push(rightMostNode.getChildNode(i));
					}
					//trace("L'ultimo figlio del nodo più a destra è: "+nodeChildren[rightMostNode.childDegree-1].data.uri);
					checkRightMostNode(nodeChildren,rightMostNode,lastGlobalPoint);
					rightMostPoint = rightMostPointFinded;
				}
				smartMove(leftMostPoint,rightMostPoint);
			}
			else if(nodeSprite.expanded == false){
				backMove(currentClass.data.firstPosX,currentClass.data.firstPosY).play();
			}
		}
		
		private function checkRightMostNode(openedNodes:Array, rightMostNode:NodeSprite, lastGlobalPoint:Point):void{
			rightMostNodeFinded = new NodeSprite();
			rightMostPointFinded = new Point(0,0);
			var openedSons:Array = openedNodes;
			var lastSonGlobalPoint:Point = lastGlobalPoint;
			var rightMostSon:NodeSprite = rightMostNode;
			//trace("Stato di: "+openedNodes[0].data.uri+" expanded: "+openedNodes[0].expanded);
			for(var i:int = 0; i<openedNodes.length; i++){
				var lastChildTemp:NodeSprite = openedNodes[i];
				var lastChildPointTemp:Point = new Point(0,0); lastChildPointTemp.x = lastChildTemp.x; lastChildPointTemp.y = lastChildTemp.y;
				var lastGlobalPointTemp:Point = new Point(lastChildTemp.parent.localToGlobal(lastChildPointTemp).x, lastChildTemp.parent.localToGlobal(lastChildPointTemp).y);        
				//trace("Il vecchio nodo ha uri: "+rightMostSon.data.uri+" e posizione x: "+lastSonGlobalPoint.x)
				//trace("Il nuovo nodo ha uri: "+lastChildTemp.data.uri+" e posizione x: "+lastGlobalPointTemp.x);	
				if(lastGlobalPointTemp.x>lastSonGlobalPoint.x){
					//trace("Ho trovato il nuovo nodo più a destra di tutti")
					lastSonGlobalPoint = lastGlobalPointTemp;
					rightMostSon = openedNodes[i];
					rightMostPointFinded = lastSonGlobalPoint;
					rightMostNodeFinded = rightMostSon;
				}	
			}
			//trace("All'interno di checkRightMost Node-------------------------------------------------")
			//trace(rightMostSon.data.uri+" x point: "+lastSonGlobalPoint.x);
			if(rightMostSon.expanded && rightMostSon.childDegree>0){
				//trace("Il nodo più a sinistra è espanso");
				var nodeChildren:Array = new Array();
				for(var i:int = 0; i<rightMostNode.childDegree; i++){
					nodeChildren.push(rightMostNode.getChildNode(i));
				}
				//trace("Il primo figlio del nodo più a destra è: "+nodeChildren[i].data.uri);
				//trace("Vado a reiterare");
				checkRightMostNode(nodeChildren,rightMostSon,lastSonGlobalPoint);
			}
			//return lastSonGlobalPoint;
		}
		
		
		private function checkLeftMostNode(openedNodes:Array, leftMostNode:NodeSprite, firstGlobalPoint:Point):void{
			leftMostNodeFinded = new NodeSprite();
			leftMostPointFinded = new Point(0,0);
			var openedSons:Array = openedNodes;
			var firstSonGlobalPoint:Point = firstGlobalPoint;
			var leftMostSon:NodeSprite = leftMostNode;
			for(var i:int = 0; i<openedNodes.length; i++){
				var firstChildTemp:NodeSprite = openedNodes[i];
				var firstChildPointTemp:Point = new Point(0,0); firstChildPointTemp.x = firstChildTemp.x; firstChildPointTemp.y = firstChildTemp.y;
				var firstGlobalPointTemp:Point = new Point(firstChildTemp.parent.localToGlobal(firstChildPointTemp).x, firstChildTemp.parent.localToGlobal(firstChildPointTemp).y);        
				//trace("Il vecchio nodo ha uri: "+leftMostSon.data.uri+" e posizione x: "+firstSonGlobalPoint.x)
				//trace("Il nuovo nodo ha uri: "+firstChildTemp.data.uri+" e posizione x: "+firstGlobalPointTemp.x);	
				//trace("Il valore di x di firstGlobalPointTemp: "+firstGlobalPointTemp.x);
				//trace("Il valore x di firstglobalPoint è: "+firstSonGlobalPoint.x);
				if(firstGlobalPointTemp.x<firstSonGlobalPoint.x){
					//trace("Ho trovato il nuovo nodo più a sinistra di tutti");
					//trace("Il vecchio nodo più a sinistra aveva uri: "+leftMostSon.data.uri+" e posizione x: "+firstSonGlobalPoint.x);
					firstSonGlobalPoint = firstGlobalPointTemp;
					leftMostSon = openedNodes[i];
					//trace("Il nuovo nodo più a sinistra ha uri: "+leftMostSon.data.uri+" e posizione x: "+firstSonGlobalPoint.x);
					leftMostPointFinded = firstSonGlobalPoint;
					leftMostNodeFinded = leftMostSon;
					//trace(leftMostPointFinded);
				}	
			}
			//trace("All'interno di checkLeftMost Node-------------------------------------------------")
			//trace(leftMostSon.data.uri+" x point: "+firstSonGlobalPoint.x);
			if(leftMostSon.expanded && leftMostSon.childDegree>0){
				//trace("Il nodo più a sinistra è espanso");
				var nodeChildren:Array = new Array();
				for(var i:int = 0; i<leftMostNode.childDegree; i++){
					nodeChildren.push(leftMostNode.getChildNode(i));
				}
				//trace("Il primo figlio del nodo più a sinistra è: "+nodeChildren[0].data.uri);
				//trace("Vado a reiterare");
				checkLeftMostNode(nodeChildren,leftMostSon,firstSonGlobalPoint);
			}
			//if()
			//trace("Il punto di cui faccio il return è: "+firstSonGlobalPoint.x);
			//return firstSonGlobalPoint;
			//return firstSonGlobalPoint;
		}
		
		private function smartMove(leftMostPoint:Point,rightMostPoint:Point):void{
			//trace("Il nodo più a sinistra è alla posizione: "+leftMostPoint);
			//trace("Il nodo più a destra è alla posizione: "+rightMostPoint);
			//trace("La y del nodo è: "+leftMostPoint.y);
			//trace("La dimensione dello stage: "+dummyStage.height);
			
			//var transitioner:Transitioner = new Transitioner(0.8);
			//Controlla se devo spostarmi verso l'alto e subito dopo verso sinistra o verso destra
			if(leftMostPoint.y+45>dummyStage.height){
				//trace("Muovo in alto");
				var upMoveTransitioner:Transitioner = upMove(leftMostPoint);
				upMoveTransitioner.addEventListener(TransitionEvent.END,function():void{
					//trace("Movimento terminato");
					if(leftMostPoint.x<55){ //Controlla se devo spostarmi verso destra - Ricorda che tale cifra rappresenta metà della dimensione del nodo
						rightMove(leftMostPoint).play();
					}
					else if(rightMostPoint.x>dummyStage.width-55){
						leftMove(rightMostPoint).play();
					}
				});
				upMoveTransitioner.play();
			}
			
			//Controlla se devo spostarmi verso il basso e subito dopo verso sinistra o verso destra
			
			
			else if(leftMostPoint.x<55){ //Controlla se devo spostarmi verso destra - Ricorda che tale cifra rappresenta metà della dimensione del nodo
				rightMove(leftMostPoint).play();
			}
			else if(rightMostPoint.x>dummyStage.width-55){
				leftMove(rightMostPoint).play();
			}
			//Controlla se devo spostarmi verso sinistra
			//transitioner.play();
		}
		
		
		private function rightMove(leftMostPoint:Point):Transitioner{
			var transitioner:Transitioner = new Transitioner(0.8);
			var mt:Matrix = _object.transform.matrix;
			mt = Displays.panMatrixBy(mt,-leftMostPoint.x+55,0);
			transitioner.$(_object.transform).matrix=mt;
			return transitioner;
		}
		
		private function leftMove(rightMostPoint:Point):Transitioner{
			var transitioner:Transitioner = new Transitioner(0.8);
			var mt:Matrix = _object.transform.matrix;
			mt = Displays.panMatrixBy(mt,-(rightMostPoint.x-dummyStage.width)-55,0);
			transitioner.$(_object.transform).matrix=mt;
			return transitioner;
		}
		
		private function upMove(leftMostPoint:Point):Transitioner{
			var transitioner:Transitioner = new Transitioner(0.8);
			var mt:Matrix = _object.transform.matrix;
			mt = Displays.panMatrixBy(mt,0,-(leftMostPoint.y-dummyStage.height)-70);
			transitioner.$(_object.transform).matrix=mt;
			return transitioner;
		}
		
		private function backMove(firstPosX,firstPosY){
			var transitioner:Transitioner = new Transitioner(0.8);
			var mt:Matrix = _object.transform.matrix;
			mt = Displays.panMatrixBy(mt,-(firstPosX - currentClass.data.lastPosX), -(firstPosY - currentClass.data.lastPosY));
			transitioner.$(_object.transform).matrix=mt;
			return transitioner;
		}
		
		
/**------------------------------------------ Getters and Setters --------------------------------------------------- **/		
	}// end of class MovingControl
}