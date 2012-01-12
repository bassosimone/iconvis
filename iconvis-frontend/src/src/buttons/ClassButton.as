package buttons{
	import flash.display.Sprite;
	
	
	public class ClassButton extends Sprite{
		
		public function ClassButton(){
			var rect:Sprite = new Sprite();
			rect.buttonMode = true;
			rect.graphics.lineStyle(0,0x000000);
			rect.graphics.beginFill(0x000000);
			rect.graphics.drawRect(0,0,1,10);
			rect.alpha=0.2;
			rect.graphics.endFill();
			rect.rotation+=45;
			rect.name="classButton";
			
			var dot:Sprite = new Sprite(); 
			dot.buttonMode =true;
			dot.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot.graphics.beginFill(0xf27937); //beginFill(color)
			dot.graphics.drawRoundRect(-42,41,35,15,22);
			dot.alpha=1;
			dot.graphics.endFill();
			dot.name="classButton";
			
			var dot1:Sprite = new Sprite(); 
			dot1.buttonMode =true;
			dot1.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot1.graphics.beginFill(0xf27937); //beginFill(color)
			dot1.graphics.drawRoundRect(-45,45,35,15,22);
			dot1.alpha=1;
			dot1.graphics.endFill();
			dot1.name="classButton";
			
			var dot2:Sprite = new Sprite(); 
			dot2.buttonMode =true;
			dot2.graphics.lineStyle(0, 0x999999); //lineStyle(thickness, color)
			dot2.graphics.beginFill(0xf27937); //beginFill(color)
			dot2.graphics.drawRoundRect(-48,49,35,15,22);
			dot2.alpha=1;
			dot2.graphics.endFill();
			dot2.name="classButton";
			dot.addChild(dot1);
			dot1.addChild(dot2);
			
			dot.addChild(rect);
			rect.y=rect.parent.y+34;
			rect.x=rect.parent.x-10;
			
			this.addChild(dot);
		}
	}
}