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
 
package views {
	
	import flash.display.Sprite;
	import flash.display.Stage;
	
	import ontologyDataStructures.ClassGraph;

/**
*
* @author Giuseppe Futia
*
*/		
	public class MainView extends Sprite{
		private var classGraph:ClassGraph;
		private var _classGraphView:ClassGraphView;
		private var mainStage:Stage;
		
		public function MainView(classGraph:ClassGraph,mainStage:Stage){
			this.classGraph = classGraph;
			this.mainStage = mainStage;
		}
		
		public function setClassGraphView():void{
			classGraphView = new ClassGraphView(classGraph,mainStage);
			this.addChild(classGraphView);
		}
		
		public function get classGraphView():ClassGraphView{
			return _classGraphView;
		}
		
		public function set classGraphView(cgv):void{
			_classGraphView = cgv;
		}
	}// end of class MainView
}