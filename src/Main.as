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
	import flash.text.TextField;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private var sprCurva:Sprite = new Sprite();
		
		private var wMin:Number = 0.032;
		private var wMax:Number = 0.965;
		
		private var fixed:Boolean = true; 	//true: posição fixa do sprite que contém a curva do comprimento de onda.
											//false: posição variável, de acordo com o sprite que muda as cores.
		private var widthSprCurva:Number;
		
		private var pontoClick:Point;
		private var clickDif:Point;
		private var BMDEspectro:BitmapData = new Espectro();

		private var espectro:Bitmap = new Bitmap(BMDEspectro);

		private var rectangle:Sprite = new Sprite();
		
		private var espectroWidth:Number = 600;
		
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
			
			scrollRect = new Rectangle(0, 0, 700, 323);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			TextField(entradaComprimento).restrict = "0123456789";
			
			addChild(sprCurva);
			sprCurva.x = 50 + espectroWidth / 2;
			sprCurva.y = 100;
			
			setChildIndex(sprCurva, 0);
			
			if(fixed){
				widthSprCurva = espectroWidth;
			}else{
				widthSprCurva = 55;
			}
			
			quadradoArraste.addChild(rectangle);
			quadradoArraste.setChildIndex(rectangle, 0);
			quadradoArraste.buttonMode = true;

			addChild(espectro);
			espectro.x = 50;
			espectro.y = 186.1;
			espectro.width = espectroWidth;
			mudaCorEspectro();

			setChildIndex(quadradoArraste, numChildren - 1);
			//setChildIndex(informacoes, numChildren - 1);
			//informacoes.visible = false;
			//howTo.visible = false;
			
			addListeners();
			
			reset(null);
			setChildIndex(borda, numChildren - 1);
			
			iniciaTutorial();
		}
		
		private function addListeners():void
		{
			entradaComprimento.addEventListener(KeyboardEvent.KEY_DOWN, entradaHandler);
			quadradoArraste.addEventListener(MouseEvent.MOUSE_DOWN, iniciaArraste);
			stage.addEventListener(MouseEvent.CLICK, clickEspectro);
			
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
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
			if((stage.mouseY >= espectro.y && stage.mouseY < espectro.y + espectro.height) && (stage.mouseX >= espectro.x && stage.mouseX < espectroWidth + espectro.x))
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
			var posColor:Number = (quadradoArraste.x - espectro.x) * (550/espectroWidth);
			var corEspectro:int = BMDEspectro.getPixel(posColor, 15);
			
			rectangle.graphics.clear();
			
			rectangle.graphics.beginFill(corEspectro);
			//rectangle.graphics.drawRect(-16, -67, 32, 134);
			rectangle.graphics.drawCircle(0, 0, 75/2);
			
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
			
			//for(var i:Number = 0 * Math.PI; i < widthSprCurva; i+= passo){
				//sprCurva.graphics.moveTo(i,amplitude * Math.sin(i * w));
				//sprCurva.graphics.lineTo(i+passo, amplitude * Math.sin((i+passo) * w));
			//}
			
			for(var i:Number = -widthSprCurva / 2; i < widthSprCurva / 2; i+= passo){
				sprCurva.graphics.moveTo(i,amplitude * Math.sin(i * w));
				sprCurva.graphics.lineTo(i+passo, amplitude * Math.sin((i+passo) * w));
			}
			
		}
		
		private function reset(e:MouseEvent):void 
		{
			entradaComprimento.text = "575";
			
			var posQuadradoArraste:Number = Math.round((((Number(entradaComprimento.text) - 400) * (espectroWidth - 1)) / 350) + espectro.x);
			
			quadradoArraste.x = posQuadradoArraste;
			mudaCorEspectro();
		}
		
		
		//Tutorial
		private var posQuadradoArraste:Point = new Point();
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		//private var tutoPhaseFinal:Boolean;
		private var tutoSequence:Array = ["Este é um espectro de cores. Você pode clicar sobre o espectro para visualizar a cor desejada.",
										  "Esta caixa mostra a cor selecionada no espectro. Você pode arrastá-la para selecionar cores diferentes.",
										  "Aqui é mostrado o valor do comprimento de onda da cor selecionada. Você pode entrar com um valor de comprimento de onda (entre 400 e 750) para verificar a cor associada.",
										  "Aqui mostramos um exemplo de ondas para a visualização dos diferentes comprimentos de ondas associados às cores."];
										  
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			atualizaPos();
			tutoPos = 0;
			//tutoPhaseFinal = false;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(espectro.x + 30,espectro.y),
								posQuadradoArraste,
								new Point(125, 38),
								new Point(350, 130)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								["" , CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.CENTER]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			//feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function atualizaPos():void
		{
			if (quadradoArraste.x >= 350) {
				posQuadradoArraste.x = quadradoArraste.x - (quadradoArraste.width / 2);
			}
			else {
				posQuadradoArraste.x = quadradoArraste.x + (quadradoArraste.width / 2);
			}
			posQuadradoArraste.y = quadradoArraste.y;
		}
		
		private function closeBalao(e:Event):void 
		{
			atualizaPos();
			/*if (tutoPhaseFinal) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			}else{*/
				tutoPos++;
				if (tutoPos >= tutoSequence.length) {
					balao.removeEventListener(Event.CLOSE, closeBalao);
					balao.visible = false;
					//feedBackScreen.addEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
					//tutoPhaseFinal = true;
				}else {
					if (tutoPos == 1) {
						var pos:String;
						if (quadradoArraste.x >= 350) pos = CaixaTexto.RIGHT;
						else pos = CaixaTexto.LEFT;
						balao.setText(tutoSequence[tutoPos], pos, tutoBaloonPos[tutoPos][1]);
						balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
					}else{
						balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
						balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
					}
				}
			//}
		}
		
		/*
		private function iniciaTutorialSegundaFase(e:Event):void 
		{
			if(tutoPhaseFinal){
				balao.setText("Você pode começar um novo exercício clicando aqui.", tutoBaloonPos[2][0], tutoBaloonPos[2][1]);
				balao.setPosition(160, pointsTuto[2].y);
				tutoPhaseFinal = false;
			}
		}
		*/
		
	}

}