package buttons{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class BackwardButton extends Sprite{
		private var loader:Loader;
		private var urlRequest:URLRequest;
		
		public function BackwardButton(){
			loader = new Loader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				trace("Can't load plus image");
			});
			urlRequest = new URLRequest("images/backward.png");
			loader.load(urlRequest);
			this.addChild(loader);
			this.x = this.x+55;
			this.y = this.y+17;
			loader.name = "backwardButton";
			this.name = "backwardButton";
			this.buttonMode = true;
		}
	}
}