/**
 * LoadIndicator.as
 * 
 * @author Daniel Goldsworthy
 * 			daniel@sitedaniel.com
 * 			http://blog.sitedaniel.com
 * 			http://www.sitedaniel.com
 * 
 * A configurable spinning LoadIndicator
 * 
 * Copyright(c) 2010 Daniel Goldsworthy
 * Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 * http://creativecommons.org/licenses/by/3.0/
 * 
 **/
package views {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class LoadIndicator extends Sprite
	{
		private const RADIUS		:int = 18;
		private const NUM_BARS		:int = 16;
		private const BAR_LENGTH	:int = 8;
		private const BAR_HEIGHT	:int = 3;
		private const COLOUR		:int = 0x000000;
		private const SPEED			:int = 1;
		
		private var _radius			:int;
		private var _num_bars		:int;
		private var _bar_length		:int;
		private var _bar_height		:int;
		private var _colour			:int;
		private var _speed			:int;
		
		private var _frameCount		:int;
		
		/**
		* LoadIndicator
		* 
		* @param $parent	:DisplayObjectContainer the parent holding clip
		* @param $x			:int the x position
		* @param $y			:int the y position
		* @param $radius	:int the radius of the clip
		* @param $total_bars:int the number of bars
		* @param $bar_length:int the length of each bar
		* @param $bar_height:int the height of each bar
		* @param $colour	:int the colour of each bar
		* @param $speed		:int the number of frames to wait before moving to the next position
		*/
		public function LoadIndicator($parent:DisplayObjectContainer, 
										$x:int, 
										$y:int, 
										$radius:int = RADIUS,
										$total_bars:int = NUM_BARS,
										$bar_length:int = BAR_LENGTH,
										$bar_height:int = BAR_HEIGHT,
										$colour:int = COLOUR,
										$speed:int = SPEED)
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			x = $x;
			y = $y
			_radius 	= $radius;
			_num_bars 	= $total_bars;
			_bar_length = $bar_length;
			_bar_height	= $bar_height;
			_colour 	= $colour;
			_speed 		= $speed;
			
			//$parent.addChild(this);
		}
		
		/**
		* destroy
		* @description removes the clip from the parent, kills animation and cleans up
		*/
		public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, onFrame);
			while(numChildren > 0) removeChildAt(0);
			this.parent.removeChild(this);
		}
		
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			for(var i:int=0; i<_num_bars; i++){
				var bar:Sprite = getBar();
				bar.rotation = 360 / _num_bars * i;
				bar.alpha = 1 / _num_bars * i;
				addChild(bar);
			}
			_frameCount = 0;
			addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
		}
		
		private function onFrame(e:Event):void
		{
			if(++_frameCount % _speed == 0)
				rotation += 360 / _num_bars;
		}
		
		private function getBar():Sprite
		{
			var bar:Sprite = new Sprite();
			var g:Graphics = bar.graphics;
			g.clear();
			g.beginFill(_colour);
			g.drawRect(_radius - _bar_length, -_bar_height/2, _bar_length, _bar_height);
			g.endFill();
			return bar;
		}
	}
}