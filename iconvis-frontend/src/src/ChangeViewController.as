package{
	import buttons.ForwardButton;
	
	import flare.animate.Transition;
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.data.NodeSprite;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import ontologyDataStructures.ClassGraph;
	import ontologyDataStructures.IndividualGraph;
	import ontologyDataStructures.RelationGraph;
	
	import views.ClassGraphView;
	import views.IndividualGraphView;
	import views.MainView;
	import views.RelationGraphView;
	
	public class ChangeViewController{
		private var main;
		private var classes:Array;
		private var individuals:Array;
		private var relations:Array;
		private var labels:Array;
		
		private var mainView:MainView;
		private var dummyStage:Object;
		private var classGraph:ClassGraph;
		private var classGraphView:ClassGraphView;
		private var individualGraph:IndividualGraph;
		private var individualGraphView:IndividualGraphView;
		private var relationGraph:RelationGraph;
		private var relationGraphView:RelationGraphView;
		
		private var rootChildren:Array;
		private var originPosXClassGraph:int;
		private var originPosYClassGraph:int;
		private var originPosXIndividualGraph:int;
		private var originPosYIndividualGraph:int;
		
		public function ChangeViewController(mainView:MainView,main){
			this.mainView = mainView;
			dummyStage = new Object();
			dummyStage.width = 1280;
			dummyStage.height =	603;
			this.classGraphView = mainView.classGraphView;
			classGraphView.changeViewController = this;
			this.classes = main.classes;
			this.individuals = main.individuals;
			this.relations = main.relations;
			this.labels = main.labels;
		}
		
		public function changeView(node:NodeSprite,command:String):void{
			if(command == "View Individuals"){
				classGraphView.setTransitionState();
				originPosXClassGraph = classGraphView.x;
				originPosYClassGraph = classGraphView.y;
				var point:Point = setPoint(dummyStage.width/15,dummyStage.height/15,classGraphView);
				individualGraph = new IndividualGraph(individuals,labels);
				individualGraph.createStructure(OntologyClass(node));
				individualGraphView = new IndividualGraphView(individualGraph,this,relations);
				setClassGraphViewForPreview();
				classGraphView.update(0.8).play();
				var transitioner:Transitioner = classGraphView.panZoomControl.backToNormalState();
					transitioner.addEventListener(TransitionEvent.END,function():void{
						var previewTransition:Transitioner = classGraphView.panZoomControl.previewGraphView(point,0.38);
						previewTransition.addEventListener(TransitionEvent.END,function():void{
							classGraphView.setPreviewState();
							classGraphView.addEventListener(MouseEvent.CLICK,restoreClassGraphView);
							mainView.addChild(individualGraphView);
						});
					});
					transitioner.play();
			}
			else if(command == "View Relations"){
				//trace("passa alla visualizzazione delle relazioni");
				individualGraphView.setTransitionState();
				originPosXIndividualGraph = individualGraphView.x;
				originPosYIndividualGraph = individualGraphView.y;
				relationGraph = new RelationGraph(relations,labels);
				relationGraph.createStructure(OntologyIndividual(node));
				relationGraphView = new RelationGraphView(relationGraph,this,relations);
				mainView.addChild(relationGraphView);
				var point:Point = setPoint(dummyStage.width/15,-(dummyStage.height/2.5),individualGraphView);
				var previewTransition:Transitioner = individualGraphView.panZoomControl.previewGraphView(point,0.38);
				previewTransition.addEventListener(TransitionEvent.END,function():void{
					individualGraphView.setPreviewState();
					individualGraphView.addEventListener(MouseEvent.CLICK,restoreIndividualGraphView);
				});
			}
			else if(command == "View New Relations"){
				trace("Trova le nuove relazioni");
				mainView.removeChild(relationGraphView);
				relationGraph = new RelationGraph(relations,labels);
				relationGraph.createStructure(OntologyIndividual(node));
				relationGraphView = new RelationGraphView(relationGraph,this,relations);
				mainView.addChild(relationGraphView);
			}
				
				//trace("Point x: "+point.x);
				
				//var ontologyClass:OntologyClass = new OntologyClass();
				//ontologyClass.setDataClass("Comune_Francia","Edificio",0,"true"); //Ricordati che ste cazzate sono da togliere
			
				
				
				
				//var point:Point = new Point();
				//point.x = -classGraphView.panZoomControl.dummyStage.width/4; //Before 21 //correct 18
				
				//trace("Point x: "+point.x);
				
				
				//point.y = -classGraphView.panZoomControl.dummyStage.height///24;
				//classGraphView.panZoomControl.previewGraphView(point,0.38).play();
				
				
				
				
				
				//var Ontolo
				
				
				
				
				//individualGraph.createStructure( ,"a")		
			
		}
		
		public function restoreClassGraphView(event:MouseEvent):void{
			var backTransition:Transitioner = classGraphView.panZoomControl.backToNormalState();
			backTransition.addEventListener(TransitionEvent.END,function():void{
				classGraphView.panZoomControl.setPosition(classGraphView,originPosXClassGraph,originPosYClassGraph);
				classGraphView.setNormalState();
			});
			backTransition.play();
			classGraphView.removeEventListener(MouseEvent.CLICK,restoreClassGraphView);
			if(individualGraphView!=null){
				mainView.removeChild(individualGraphView);
				individualGraphView = null;
			}
			if(relationGraphView!=null){
				mainView.removeChild(relationGraphView);
				relationGraphView = null;
			}
			classGraphView.setNodesExpansion(rootChildren);
			classGraphView.update(0.8).play();
		}
		
		public function restoreIndividualGraphView(event:MouseEvent):void{
			var backTransition:Transitioner = individualGraphView.panZoomControl.backToNormalState();
			backTransition.addEventListener(TransitionEvent.END,function():void{
				individualGraphView.setNormalState();
			});
			backTransition.play();
			individualGraphView.removeEventListener(MouseEvent.CLICK,restoreIndividualGraphView);
			if(relationGraphView!=null){
				mainView.removeChild(relationGraphView);
				relationGraphView = null;
			}
		}
		
		public function setClassGraphViewForPreview():void{
			var rootNode:OntologyClass = classGraphView.tree.nodes[0];
			rootChildren = classGraphView.putExpandedChildren(rootNode);
			classGraphView.setNodesExpansion(rootChildren);
		}
		
		public function setPoint(x:int,y:int,vis:Visualization):Point{
			var point:Point = new Point();
			point.x = x; 
			point.y = y;
			var globalPoint:Point = new Point(-vis.parent.localToGlobal(point).x,-vis.parent.localToGlobal(point).y);
			return globalPoint;
		}
	} //end of class ChangeViewController
}