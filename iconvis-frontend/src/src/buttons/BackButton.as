package buttons{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class BackButton extends Sprite{
		
		private var loader:Loader;
		private var urlRequest:URLRequest;
			
		public function BackButton(){
			loader = new Loader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function():void{
				trace("Can't load back image");
			});
			urlRequest = new URLRequest("images/back.png");
			loader.load(urlRequest);
			this.addChild(loader);
			loader.name = "backButton";
			this.name = "backButton";
			this.x = this.x+600;
			this.buttonMode = true;
				
		}
	}
}