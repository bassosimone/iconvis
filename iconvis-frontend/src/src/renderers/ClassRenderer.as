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
 
package renderers{
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
		
/**
*
* @author Giuseppe Futia
*
*/			
	public class ClassRenderer implements IRenderer{
		private var radius:Number = 20;
		private var btnW = 150;
		private var btnH = 55;
		private var fillType:String = "linear";
		private var colors:Array = [0xF69C46, 0xEF5A2B];
		private var alphas:Array = [50, 50];
		private var ratios:Array = [0, 245];
		private var matrix:Object = {matrixType:"box", x:0, y:0, w:btnW, h:btnH, r:90/180*Math.PI};
		
		public function ClassRenderer(){
		
		}

		public function render(d:DataSprite):void{
			var sprite:Sprite=d;
			sprite.graphics.clear();
			sprite.graphics.lineStyle(0, 0xE88A41, 100, true, "none", "square", "round");
			sprite.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix as Matrix);		
			sprite.graphics.drawRoundRect(-56,-32,110,65,45,45);
			sprite.graphics.endFill();
		}
		
		public function nodeVisit(nodeSprite:NodeSprite):void{
			nodeSprite.renderer=this;
		}
	}
}