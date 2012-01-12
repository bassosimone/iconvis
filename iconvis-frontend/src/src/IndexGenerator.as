package{
	
	public class IndexGenerator{
		private var childrenUri:Array;
		private var labels:Array;
		private var childrenLabels:Array;
		
		private var _mapLetter:Object;
		private var _letterChildren:Array;
		private var alphabet:Array = ["A","B","C","D","E","F","G","H","I","L","M","N","O","P","Q","R","S","T","U","V","Z"];
		//private var letterArray:Array =[arrayA,arrayB,arrayC,arrayD,arrayE,arrayF,arrayG,arrayH,arrayI,arrayL,arrayM,arrayN,arrayO,arrayP,arrayQ,arrayR,arrayS,arrayT,arrayU,arrayV,arrayZ];
		
		public function IndexGenerator(childrenUri:Array,labels:Array){
			this.childrenUri = childrenUri;
			this.labels = labels;
			mapLetter = new Object();
			provideChildrenLabels();
			//trace("Le label dei children sono: "+childrenLabels);
			checkFirstLetter();
			//mapLetter["T"] = mapLetter["T"].replace("undefined","");
			//trace(mapLetter["T"]);
		}
		
		public function provideChildrenLabels():void{
			childrenLabels = new Array();
			for(var i:int = 0; i<childrenUri.length; i++){
				var label:String = findNodeLabel(childrenUri[i],labels);
				childrenLabels.push(label);
			}
		}
		
		public function checkFirstLetter():void{
			for(var i:int = 0; i<childrenLabels.length; i++){
				var firstLetter:String = childrenLabels[i].toString().charAt(0).toUpperCase();
				for(var j:int = 0; j<alphabet.length; j++){
					if(firstLetter == alphabet[j]){
						mapLetter[alphabet[j].toString()]+=childrenUri[i]+",";
					}
				}	
			}
			createLettersChildrenUri(mapLetter);
		}
		
		private function findNodeLabel(uri:String,labels:Array):String{
			var label:String = "";
			for(var j:int=0; j<labels.length; j++){
				if(j==labels.length-1){
					if (labels[j][0] != uri){
						label = uri; //If you don't find a label property, you can assign the uri as label of the node
					}
				}								
				else if (labels[j][0] == uri){
					label = labels[j][1];
					return label;
					break;
				}
			}
			return label;		
		}
		
		public function createLettersChildrenUri(mapLetter:Object):void{
			letterChildren = new Array();
			if(mapLetter["A"]!=undefined){
				letterChildren.push("A");
			}
			if(mapLetter["B"]!=undefined){
				letterChildren.push("B");
			}
			if(mapLetter["C"]!=undefined){
				letterChildren.push("C");
			}
			
			if(mapLetter["D"]!=undefined){
				letterChildren.push("D");
			}
			
			if(mapLetter["E"]!=undefined){
				letterChildren.push("E");
			}
			
			if(mapLetter["F"]!=undefined){
				letterChildren.push("F");
			}
			
			if(mapLetter["G"]!=undefined){
				letterChildren.push("G");
			}
			
			if(mapLetter["H"]!=undefined){
				letterChildren.push("H");
			}
			
			if(mapLetter["I"]!=undefined){
				letterChildren.push("I");
			}
			
			if(mapLetter["L"]!=undefined){
				letterChildren.push("L");
			}
			
			if(mapLetter["M"]!=undefined){
				letterChildren.push("M");
			}
			
			if(mapLetter["N"]!=undefined){
				letterChildren.push("N");
			}
			
			if(mapLetter["O"]!=undefined){
				letterChildren.push("O");
			}
			
			if(mapLetter["P"]!=undefined){
				letterChildren.push("P");
			}
			
			if(mapLetter["Q"]!=undefined){
				letterChildren.push("Q");
			}
			
			if(mapLetter["R"]!=undefined){
				letterChildren.push("R");
			}
			
			if(mapLetter["S"]!=undefined){
				letterChildren.push("S");
			}
			
			if(mapLetter["T"]!=undefined){
				letterChildren.push("T");
			}
			
			if(mapLetter["U"]!=undefined){
				letterChildren.push("U");
			}
			
			if(mapLetter["V"]!=undefined){
				letterChildren.push("V");
			}
			
			if(mapLetter["Z"]!=undefined){
				letterChildren.push("Z");
			}	
		}
		
/** -----------------------------------------Getters and Setters------------------------------------------------------- **/		
		
		public function get mapLetter():Object{
			return _mapLetter;
		}
		
		public function set mapLetter(ml:Object):void{
			_mapLetter = ml;
		}
		
		public function get letterChildren():Array{
			return _letterChildren;
		}
		
		public function set letterChildren(lc:Array):void{
			_letterChildren = lc;
		}
		
	}// endo of class Index Generator
}