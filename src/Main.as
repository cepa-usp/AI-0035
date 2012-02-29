package 
{
	import cepa.utils.ToolTip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import cepa.graph.rectangular.SimpleGraph;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private var sprCurva:Sprite = new Sprite();
		
		private var wMin:Number = 0.125;
		private var wMax:Number = 0.565;
		
		private var fixed:Boolean = true; 	//true: posição fixa do sprite que contém a curva do comprimento de onda.
											//false: posição variável, de acordo com o sprite que muda as cores.
		private var widthSprCurva:Number;
		
		private var pontoClick:Point;
		private var clickDif:Point;
		private var BMDEspectro:BitmapData = new Espectro();

		private var espectro:Bitmap = new Bitmap(BMDEspectro);

		private var rectangle:Sprite = new Sprite();
		
		private var espectroWidth:Number = 590;
		
		private var orientacoesScreen:InstScreen;
		private var creditosScreen:AboutScreen;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			scrollRect = new Rectangle(0, 0, 700, 280);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			addChild(sprCurva);
			sprCurva.y = 45;
			
			if(fixed){
				widthSprCurva = 600;
			}else{
				widthSprCurva = 50;
			}
			
			quadradoArraste.addChild(rectangle);
			quadradoArraste.buttonMode = true;

			addChild(espectro);
			espectro.x = 30;
			espectro.y = 148;
			espectro.width = espectroWidth;
			mudaCorEspectro();

			setChildIndex(quadradoArraste, numChildren - 1);
			//setChildIndex(informacoes, numChildren - 1);
			//informacoes.visible = false;
			//howTo.visible = false;
			
			addListeners();
			
			reset(null);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function addListeners():void
		{
			entradaComprimento.addEventListener(KeyboardEvent.KEY_DOWN, entradaHandler);
			
			//aboutButton.addEventListener(MouseEvent.CLICK, showHideInfo);
			//informacoes.addEventListener(MouseEvent.CLICK, showHideInfo);
			
			//instructionButton.addEventListener(MouseEvent.CLICK, showHideHowTo);
			//howTo.addEventListener(MouseEvent.CLICK, showHideHowTo);
			
			quadradoArraste.addEventListener(MouseEvent.MOUSE_DOWN, iniciaArraste);
			
			stage.addEventListener(MouseEvent.CLICK, clickEspectro);
			
			//botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, reset);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			
			createToolTips();
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function entradaHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				okButtonHandler(null);
				stage.focus = null;
			}
		}

		private function okButtonHandler(e:MouseEvent):void
		{
			if(Number(entradaComprimento.text) < 400)
			{
				entradaComprimento.text = "400";
			}
			else if(Number(entradaComprimento.text) > 750)
			{
				entradaComprimento.text = "750"
			}
			
			//var posQuadradoArraste:Number = Math.round(((Number(entradaComprimento.text) - 400) * 549) / 350);
			var posQuadradoArraste:Number = Math.round((((Number(entradaComprimento.text) - 400) * (espectroWidth - 1)) / 350) + espectro.x);
			
			quadradoArraste.x = posQuadradoArraste;
			mudaCorEspectro();
		}

		private function clickEspectro(e:MouseEvent):void
		{
			if((stage.mouseY >= 148 && stage.mouseY < 178) && (stage.mouseX >= 25 && stage.mouseX < espectroWidth + espectro.x))
			{
				quadradoArraste.x = stage.mouseX;
				mudaCorEspectro();
			}
		}

		private function iniciaArraste(e:MouseEvent):void
		{
			pontoClick = new Point(stage.mouseX, stage.mouseY);
			clickDif = new Point(quadradoArraste.x - pontoClick.x, quadradoArraste.y - pontoClick.y);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, arrastando);
			stage.addEventListener(MouseEvent.MOUSE_UP, paraArraste);
		}

		private function arrastando(e:MouseEvent):void
		{
			var pos:Number = stage.mouseX + clickDif.x;
			quadradoArraste.x = Math.max(espectro.x, Math.min(pos, espectroWidth + espectro.x - 1));
			
			mudaCorEspectro();
		}

		private function paraArraste(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, arrastando);
			stage.removeEventListener(MouseEvent.MOUSE_UP, paraArraste);
			
			pontoClick = null;
			clickDif = null;
		}

		private function mudaCorEspectro():void
		{
			var posComprimento:Number = quadradoArraste.x;
			var posColor:Number = quadradoArraste.x * (500/espectroWidth);
			var corEspectro:int = BMDEspectro.getPixel(posColor, 15);
			
			rectangle.graphics.clear();
			
			rectangle.graphics.beginFill(corEspectro);
			rectangle.graphics.drawRect(-16, -67, 32, 134);
			
			//var comprimentoOnda:Number = Math.round(((350 / 549) * posComprimento) + 400);
			var comprimentoOnda:Number = Math.round(((350 / (espectroWidth - 1)) * (posComprimento - espectro.x)) + 400);
			//var comprimentoOndaTexto:Number = Math.round(((350 / 499) * (posColor - 25)) + 400);
			//var comprimentoOnda:Number = Math.round(((350 / 499) * (posComprimento - 25)) + 400);
			
			entradaComprimento.text = String(comprimentoOnda);
			
			
			//var posQuadradoArraste:Number = Math.round(((Number(entradaComprimento.text) - 400) * 549) / 350);
			var posQuadradoArraste:Number = Math.round((((comprimentoOnda - 400) * (espectroWidth - 1)) / 350) + espectro.x);
			
			quadradoArraste.x = posQuadradoArraste;
			if(!fixed) sprCurva.x = quadradoArraste.x - widthSprCurva/2;
			desenhaCurva(posQuadradoArraste);
			
		}

		private function desenhaCurva(comp:Number):void
		{
			var amplitude:Number = 30;
			var w:Number = (wMax - wMin)/(espectroWidth - 1) * (comp - espectro.x) + wMin;
				
			var passo:Number = 0.5;
			sprCurva.graphics.clear();
			sprCurva.graphics.lineStyle(1, 0x000000);
			sprCurva.graphics.moveTo(0,0);
			
			for(var i:Number = 0 * Math.PI; i < widthSprCurva; i+= passo){
				sprCurva.graphics.moveTo(i,amplitude * Math.sin(i * w));
				sprCurva.graphics.lineTo(i+passo, amplitude * Math.sin((i+passo) * w));
			}
			
		}
		
		private function reset(e:MouseEvent):void 
		{
			entradaComprimento.text = "590";
			
			var posQuadradoArraste:Number = Math.round((((Number(entradaComprimento.text) - 400) * (espectroWidth - 1)) / 350) + espectro.x);
			
			quadradoArraste.x = posQuadradoArraste;
			mudaCorEspectro();
		}
		
	}

}