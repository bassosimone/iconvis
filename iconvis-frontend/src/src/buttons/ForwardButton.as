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

package buttons{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
/**
 *
 * @author Giuseppe Futia
 *
 */	
	
	public class ForwardButton extends Sprite{
		private var loader:Loader;
		private var urlRequest:URLRequest;
		
		public function ForwardButton(){
			loader = new Loader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				trace("Can't load plus image");
				});
			urlRequest = new URLRequest("images/forward.png");
			loader.load(urlRequest);
			this.addChild(loader);
			this.x = this.x+55;
			this.y = this.y-52;
			loader.name = "forwardButton";
			this.name = "forwardButton";
			this.buttonMode = true;
		}
	}
}