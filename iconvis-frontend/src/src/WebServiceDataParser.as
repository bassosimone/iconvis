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

package {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
/**
*
* @author Giuseppe Futia
*
*/		
	public class WebServiceDataParser{
		
		public function WebServiceDataParser(){
			
		}
		
		public function parseGraphTreeData(data:String):Array{
			data = data.substring(1,data.length-1);
			var arrayTemp:Array = data.split("\n");
			//arrayTemp.toString();
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("###");
			}
			return results;
			//trace("End parse graph tree data");
        }
        
        public function parseIndividualsData(data:String):Array{
        	data = data.substring(1,data.length-1);
			var arrayTemp:Array = data.split("\n");
			//arrayTemp.toString();
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("###");
			}
			//trace(results);
			return results;
			//trace("End parse individual data");
        }
        
        public function parseRelationsData(data:String):Array{
        	data = data.substring(1,data.length-1);
			var arrayTemp:Array = data.split("\n");
			//arrayTemp.toString();
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("###");
			}
			//trace(results);
			return results;
			//trace("End parse relations data");
        }
        
        public function parseLabelData(data:String):Array{
        	data = data.substring(1,data.length-1);
			var arrayTemp:Array = data.split("\n");
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("=");
			}
			//trace(results);
			return results;
			//trace("End parse label data");
        }
        
        public function parseIndividualsProperties(data:String):Array{
        	data=data.substring(1,data.length-1);
			var arrayTemp:Array=data.split("\n");
			//arrayTemp.toString();
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i]=arrayTemp[i].split("###");
			}
			return results;
        }
		
		public function parseFlagsOnIndividualsData(data:String):Array{
			data = data.substring(1,data.length-1);
			var arrayTemp:Array = data.split("\n");
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("=");
			}
			return results;
		}
		
		public function parseLodQueriesData(data:String):Array{
			data = data.substring(1,data.length-1);
			//        	trace("LOD QUERIES:"+data);
			var arrayTemp:Array = data.split("\n");
			//arrayTemp.toString();
			var results:Array = new Array();
			for(var i:int=0;i<arrayTemp.length;i++){
				results[i] = arrayTemp[i].split("###");
			}
			return results;
		}
	}
}