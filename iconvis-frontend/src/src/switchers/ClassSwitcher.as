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

package switchers{
	import animations.SwitcherAnimator;
	
	import flare.animate.TransitionEvent;
	import flare.vis.data.NodeSprite;
	
	import ontologyDataStructures.ClassGraph;
	
	import renderers.ClassRenderer;
	
	import views.ClassGraphView;

/**
*
* @author Giuseppe Futia
*
*/
	
	public class ClassSwitcher{
		private var classGraphView:ClassGraphView;
		private var classGraph:ClassGraph;
		private var classRenderer:ClassRenderer;
		private var classes:Array;
		private var switchIndex:int;
		private var classSwitcherAnimator:SwitcherAnimator;
		
		public function ClassSwitcher(classGraphView:ClassGraphView, classGraph:ClassGraph, classRenderer:ClassRenderer){
			this.classGraphView = classGraphView;
			this.classGraph = classGraph;
			this.classRenderer = classRenderer;
			this.classes = classGraph.classes;
			switchIndex = classGraph.switchIndex;
			classSwitcherAnimator = new SwitcherAnimator();
		}
		
		public function switchNodes(ontologyClass:OntologyClass):void{
			classGraphView.setTransitionState();
			for (var i:int=0; i<ontologyClass.childDegree; i++){
				if(i==ontologyClass.childDegree-1){
					classSwitcherAnimator.animOut(OntologyClass(ontologyClass.getChildNode(i)),i-0.95*i).addEventListener(TransitionEvent.END, function():void{
						removeNodes(ontologyClass);
						restoreNodes(ontologyClass);
						classGraphView.update(0.25).play();
						for(var r:int=0; r<ontologyClass.childDegree; r++){
							classSwitcherAnimator.animIn(OntologyClass(ontologyClass.getChildNode(r)),r-0.95*r).addEventListener(TransitionEvent.END,function():void{
							classGraphView.setNormalState();
							classGraphView.setIndividualButton(ontologyClass);
							});
						}
					});	
				}
				else{
					classSwitcherAnimator.animOut(OntologyClass(ontologyClass.getChildNode(i)),i-0.95*i);
				} 
			}
		}

		public function removeNodes(ontologyClass:OntologyClass):void{
			while(ontologyClass.childDegree>0)
				classGraphView.tree.remove(ontologyClass.lastChildNode);
		}
		
		public function restoreNodes(ontologyClass:OntologyClass):void{
			var childrenUri:Array = new Array();
			var subset:int = ontologyClass.data.childrenSubset+1;
			for(var i:int = 0; i<classes.length; i++){
				if(classes[i][1] == ontologyClass.data.uri){
					childrenUri.push(classes[i][0]);
				}
			}
			if(childrenUri[subset*switchIndex]!=undefined){
				classGraph.createRootChildren(ontologyClass, childrenUri,subset);
				ontologyClass.data.childrenSubset = ontologyClass.data.childrenSubset+1;
				
			}else{
				ontologyClass.setChildrenSubset(0);
				classGraph.createRootChildren(ontologyClass, childrenUri,ontologyClass.data.childrenSubset);
			}
			classGraphView.tree.nodes.visit(classRenderer.nodeVisit);  
		}	
	}//end of ClassSwitcher 
}