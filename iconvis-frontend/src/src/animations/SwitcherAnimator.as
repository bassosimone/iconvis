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

package animations{
	import flare.animate.Parallel;
	import flare.animate.Sequence;
	import flare.animate.TransitionEvent;
	import flare.animate.Tween;
	import flare.vis.data.NodeSprite;
	
/**
*
* @author Giuseppe Futia
*
*/
	
	public class SwitcherAnimator{
		
		public function SwitcherAnimator(){
			
		}
		
		public function animOut(node:NodeSprite,d:Number):Sequence{		
			var t01:Tween = new Tween(node,0.6,{scaleX:2})
			var t02:Tween = new Tween(node,0.6,{scaleY:2})
			var t1:Tween=new Tween(node,0.5,{alpha:0});
			var t2:Tween=new Tween(node,0.5,{x:node.parentNode.x});
			var t3:Tween=new Tween(node,0.5,{y:node.parentNode.y});
			var t4:Tween=new Tween(node,0.5,{height:0});
			var t5:Tween=new Tween(node,0.5,{width:0});
			
			var seq1:Sequence = new Sequence(new Parallel(t01,t02));
			
			var seq2:Sequence = new Sequence(new Parallel(t1,t2,t3,t4,t5));		
			seq1.delay=d;
			seq1.play();
			seq1.addEventListener(TransitionEvent.END,function():void{
				seq2.play();
			});
			return seq2;
		}
		
		public function animIn(node:NodeSprite, d:Number):Sequence{
			var t0:Tween=new Tween(node,0.6,{scaleX:2});
			var t1:Tween=new Tween(node,0.6,{scaleY:2});
			var t2:Tween=new Tween(node,0.6,{scaleX:1});
			var t3:Tween=new Tween(node,0.6,{scaleY:1});
			
			var seq1:Sequence= new Sequence(new Parallel(t0,t1));
			
			var seq2:Sequence=new Sequence(new Parallel(t2,t3));
			
			seq1.delay=d;
			seq1.play();
			seq1.addEventListener(TransitionEvent.END, function():void{
				seq2.play();
				
			});
			return seq2;	
		}
	}
}