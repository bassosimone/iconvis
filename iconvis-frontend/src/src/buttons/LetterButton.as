package buttons{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class LetterButton extends Sprite{
		private var loader:Loader;
		private var urlRequest:URLRequest;
		
		public function LetterButton(){
			loader = new Loader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				trace("Can't load letter image");
			});
			urlRequest = new URLRequest("images/letter.png");
			loader.load(urlRequest);
			this.addChild(loader);
			this.x = this.x+55;
			this.y = this.y-16;
			loader.name = "letterButton";
			this.name = "letterButton";
			this.buttonMode = true;
		}
	}
}