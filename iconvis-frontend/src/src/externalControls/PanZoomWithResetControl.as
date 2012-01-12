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
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.util.Displays;
	import flare.vis.Visualization;
	import flare.vis.controls.Control;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;

/**
*
* @author Giuseppe Futia
*
*/		
	public class PanZoomWithResetControl extends Control{
		
		public var zoomMax:Number;
		public var zoomMin:Number;
	
		public var resetInProcess:Boolean;
		/** The Matrix class represents a transformation matrix that determines how to map points from one coordinate space to another.*/
		protected var originalMatrix:Matrix;  //modification 
		
		protected var zoomDelta:Number;
		
		private var px:Number, py:Number;
		private var dx:Number, dy:Number;
		private var mx:Number, my:Number;
		private var _drag:Boolean = false;
		
		private var _hit:InteractiveObject;
		private var _stage:Stage;
		private var mainStage:Stage;
		private var _dummyStage:Object;
		private var _inProcess:Boolean = false;
		
		/** The active hit area over which pan/zoom interactions can be performed. */
		public function get hitArea():InteractiveObject { return _hit; }// Getter and Setter to return and set the specific area of mouse events
		public function set hitArea(hitArea:InteractiveObject):void {
			if (_hit != null) onRemove();
			_hit = hitArea;
			if (_object && _object.stage != null) onAdd();
		}
		
		public function PanZoomWithResetControl(hitArea:InteractiveObject = null, zoomMin:Number = 0,zoomMax:Number=10000):void{
			_hit = hitArea;
			this.zoomMin = zoomMin;
			this.zoomMax = zoomMax;
			this.mainStage = mainStage;
			dummyStage = new Object();
			//dummyStage.width = mainStage.width;
			//dummyStage.height = mainStage.height;
			originalMatrix = null; //modification
			resetInProcess = false;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				if (obj.stage != null) onAdd();
				
				originalMatrix = obj.transform.matrix;  //modification
				zoomDelta = 1; //modification
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject{
			onRemove();
			_object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			originalMatrix = null; //modification
			return super.detach();
		}	 
		
		public function resetPanZoom(t:Transitioner = null, playImmediately:Boolean = true):void  {
			if (resetInProcess) {
				return;
			}
			
			zoomDelta = 1;
			if (t == null)  {
				_object.transform.matrix = originalMatrix;
			} else {
				resetInProcess = true;
				t.$(_object.transform).matrix = originalMatrix;
				t.addEventListener(TransitionEvent.END, function(evt:Event):void {
					resetInProcess = false;
				});
				if (playImmediately) {
					t.play();
				}
			}
		}
		
		private function onAdd(evt:Event=null):void{
			_stage = _object.stage;
			if (_hit == null) {
				_hit = _stage;
			}
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//_hit.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			//_hit.addEventListener(MouseEvent.CLICK,smartMove);	
		}
		
		private function onRemove(evt:Event=null):void{
			_hit.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//_hit.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			//_hit.removeEventListener(MouseEvent.CLICK,smartMove);
			
		}
		
		private function onMouseDown(event:MouseEvent) : void{
			if (_stage == null || resetInProcess) return;
			if (_hit == _object && event.target != _hit) return;
			if (event.target.name=="classButton") return;
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			px = mx = event.stageX;
			py = my = event.stageY;
			_drag = true;
		}
			
		private function onMouseMove(event:MouseEvent) : void{
			if (!_drag || resetInProcess || _inProcess) return;
			
			
			var x:Number = event.stageX;
			var y:Number = event.stageY;
			
			if (!event.ctrlKey) {
				dx = dy = NaN;
				
				Displays.panBy(_object, x - mx, y - my);	
			} else {
				if (isNaN(dx)) {
					dx = event.stageX;
					dy = event.stageY;
				}
				var dz:Number = 1 + (y - my) / 100;
				dz = getLimitedZoom(dz);
				Displays.zoomBy(_object, dz, dx, dy);
			}
			mx = x;
			my = y;
		}
		
		private function onMouseUp(event:MouseEvent) : void{
			if (resetInProcess) { return;}
			dx = dy = NaN;
			_drag = false;
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);	
		}
		
		private function onMouseWheel(event:MouseEvent) : void{
            if (resetInProcess) { return;}
            var dw:Number = event.delta;
            var dz:Number = dw < 0 ? 0.975 : 1.025;
            
            dz = getLimitedZoom(dz);
            
            var oldX:Number = _object.x;
            var oldY:Number = _object.y;
            Displays.zoomBy(_object, dz);
           //	_object.x = stage.mouseX - ((stage.mouseX - oldX)*dz);
           //_object.y = stage.mouseY - ((stage.mouseY - oldY)*dz);
        }
		
		protected function getLimitedZoom(dz:Number):Number {

			if (zoomDelta * dz > zoomMax) {
					dz = zoomMax / zoomDelta;
			} else if (zoomDelta * dz < zoomMin) {
				dz = zoomMin / zoomDelta;
			}
			
			zoomDelta *= dz;
				
			return dz;		
		}
		
		public function setPosition(vis:DisplayObject,dx:int,dy:int):Transitioner{
			var transitioner:Transitioner= new Transitioner(0.8);
			var mt:Matrix = vis.transform.matrix;
			Displays.panMatrixBy(mt,dx,dy);
			transitioner.$(vis.transform).matrix=mt;
			transitioner.play();
			return transitioner;
		}
		
		public function previewGraphView(point:Point,zoom):Transitioner{
			var transitioner:Transitioner= new Transitioner(0.8);
			var mt:Matrix=_object.transform.matrix;
			mt=Displays.zoomMatrixBy(mt,zoom,point);
			transitioner.$(_object.transform).matrix=mt;
			transitioner.play();
			return transitioner;
		}
		
		public function backToNormalState():Transitioner{
			var transitioner:Transitioner = new Transitioner(0.8);
			resetPanZoom(new Transitioner(0.8));
			return transitioner;
		}
		
/**------------------------------------- Getters and Setters -----------------------------------------------------**/		
		
		public function get dummyStage():Object{
			return _dummyStage;
		}
		
		public function set dummyStage(ds:Object):void{
			_dummyStage = ds;
		}
		
		public function get inProcess():Boolean{
			return _inProcess;
		}
		
		public function set inProcess(ip:Boolean):void{
			_inProcess = ip;	
		}
		
	} // end of class PanZoomWithResetControl
}