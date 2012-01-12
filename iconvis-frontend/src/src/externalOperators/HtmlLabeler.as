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

package externalOperators{
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.label.Labeler;
	
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

/**
*
* @author Giuseppe Futia
*
*/			
	public class HtmlLabeler extends Labeler{
		public var width:Number = 110;
		public var height:Number = 50;
		
		private var _css:StyleSheet = new StyleSheet();
		private var modify:Object = new Object();

		public function HtmlLabeler(source:*, group:String=Data.NODES,
			format:TextFormat=null, policy:String=CHILD, filter:*=null){
			super(source, group, format, policy, filter);
			modify.fontFamily="Helvetica, _sans";
			modify.fontSize=12;
			modify.fontWeight="bold";
			modify.color="#FFFFFF";
			modify.textAlign="center";
			_css.setStyle(".modify",modify);
			
		}

		public function get css():StyleSheet { return _css; }
		public function set css(css:StyleSheet):void { _css = css; }

		/** @inheritDoc */
		protected override function getLabel(d:DataSprite,
			create:Boolean=false, visible:Boolean=true):TextSprite{
			var label:TextSprite = super.getLabel(d, create, visible);
			label.textField.multiline = false;
			label.textField.styleSheet = _css;
			//trace(d);
			if(getLabelText(d)!=null)
				label.textField.htmlText = "<span class='modify'>"+getLabelText(d)+"</span>";
			
			label.textField.wordWrap = true;
			label.textField.width = width;
			label.textField.autoSize = TextFieldAutoSize.CENTER;
			return label;
		}
	} 
}