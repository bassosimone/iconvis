package buttons{
	import flash.display.Sprite;
	
	public class IndividualButton extends Sprite{
		
		public function IndividualButton(){
			var rect:Sprite = new Sprite();
			rect.graphics.lineStyle(0,0x000000);
			rect.graphics.beginFill(0x000000);
			rect.graphics.drawRect(0,0,1,10);
			rect.alpha=0.2;
			rect.graphics.endFill();
			rect.rotation-=45
			rect.name = "individual";
			
			var dot:Sprite = new Sprite(); 
			dot.buttonMode =true;
			dot.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot.graphics.beginFill(0x00F000); //beginFill(color)
			dot.graphics.drawRoundRect(4,41,35,15,22); 
			dot.alpha=1;
			dot.graphics.endFill();
			dot.name = "individual";
			
			var dot1:Sprite = new Sprite(); 
			dot1.buttonMode =true;
			dot1.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot1.graphics.beginFill(0x00F000); //beginFill(color)
			dot1.graphics.drawRoundRect(7,45,35,15,22);
			dot1.alpha=1;
			dot1.graphics.endFill();
			dot1.name = "individual";
			
			var dot2:Sprite = new Sprite(); 
			dot2.buttonMode =true;
			dot2.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot2.graphics.beginFill(0x00F000); //beginFill(color)
			dot2.graphics.drawRoundRect(10,49,35,15,22);
			dot2.alpha=1;
			dot2.graphics.endFill();
			dot2.name = "individual";
			
			dot.addChild(dot1);
			dot1.addChild(dot2);
			
			dot.addChild(rect);
			rect.y=rect.parent.y+34;
			rect.x=rect.parent.x+10;
			
			this.addChild(dot);
		}
	}
}