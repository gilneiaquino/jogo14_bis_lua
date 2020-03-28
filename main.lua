LARGURA_TELA = 320
ALTURA_TELA = 480
MAX_METEOROS = 20
METEOROS_ATINGIDOS = 0
NUMERO_METEOROS_OBJETIVO = 50
TELA_INICIO_JOGO = false


aviao_14bis = {
    src = "imagens/14bis.png",
    largura =55,
    altura =63,
    x = LARGURA_TELA/2 - 64/2;
    y = ALTURA_TELA - 64,
    tiros ={}
}


function darTiro() 
    disparo:play()
    local tiro =  {
        x = aviao_14bis.x + aviao_14bis.largura/2,
        y = aviao_14bis.y,
        largura = 16,
        altura = 16
    }

    table.insert(aviao_14bis.tiros,tiro)
end


x = 0
y = 0

meteoros = {}

function criarMeteoro()

    meteoro = {
        x = math.random(320),
        y = -70,
        largura =50,
        altura =44,
        peso = math.random(3),
        deslocamento_horizontal = math.random(-1,1)

    }
    table.insert(meteoros,meteoro); 
end

function destroiAviao()
    destruicao:play()
    aviao_14bis.src = "imagens/explosao_nave.png"
    aviao_14bis.image    = love.graphics.newImage(aviao_14bis.src)
    aviao_14bis.largura = 67
    aviao_14bis.altura = 77
end

function moviTiros() 
    for i=#aviao_14bis.tiros,1,-1 do
        if aviao_14bis.tiros[i].y > 0 then
            aviao_14bis.tiros[i].y = aviao_14bis.tiros[i].y -1
        else
            table.remove(aviao_14bis.tiros,i)
        end
    end
end



function temColisao(X1,Y1,L1,A1,X2,Y2,L2,A2)
    return X2 < X1 + L1 and
           X1 < X2 + L2 and
           Y1 < Y2 + A2 and    
           Y2 < Y1 + A1
end

function trocaMusicaDeFundo() 
    musica_ambiente:stop()
    game_over:play()
end

function checaColisaoComAviao()
    for k,meteoro in pairs(meteoros) do
        if temColisao(meteoro.x,meteoro.y,meteoro.largura,meteoro.altura,
                aviao_14bis.x,aviao_14bis.y,aviao_14bis.largura,aviao_14bis.altura) then
            trocaMusicaDeFundo()
            destroiAviao() 
            FIM_JOGO = true       
        end
    end  
end

function checaColisaoComTiros()
    for i = #aviao_14bis.tiros,1,-1 do
        for j = #meteoros,1,-1 do
            if temColisao(aviao_14bis.tiros[i].x, aviao_14bis.tiros[i].y,aviao_14bis.tiros[i].largura,aviao_14bis.tiros[i].altura,
            meteoros[j].x,meteoros[j].y,meteoros[j].largura,meteoros[j].altura) then
                METEOROS_ATINGIDOS = METEOROS_ATINGIDOS +1
                table.remove(aviao_14bis.tiros,i)
                table.remove(meteoros,j)
                break
            end    

        end 
    end
end

function checaTemColisoes()
     checaColisaoComAviao()
     checaColisaoComTiros()    
 end

function removeMeteoros()
   for i = #meteoros, 1, -1 do
      if meteoros[i].y > ALTURA_TELA then
        table.remove(meteoros,i)
        end
   end
 end

function moveMeteoro()
    for k,meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.peso
        meteoro.x = meteoro.x + meteoro.deslocamento_horizontal
    end   
end

function move14bis() 
    if love.keyboard.isDown('up') then
        aviao_14bis.y = aviao_14bis.y  -1
    end
    if love.keyboard.isDown('down') then
        aviao_14bis.y = aviao_14bis.y  +1
    end
    if love.keyboard.isDown('left') then
        aviao_14bis.x = aviao_14bis.x -1
    end
    if love.keyboard.isDown('right') then
        aviao_14bis.x = aviao_14bis.x  +1
    end
 
end 


function love.keypressed(tecla)
    if tecla == 'escape' then
        love.event.quit()
    elseif tecla == 'space' then
        darTiro()   
    end

end

function checaObjetivoConcluido()
    if METEOROS_ATINGIDOS >=NUMERO_METEOROS_OBJETIVO then
        VENCEDOR = true;
        musica_ambiente:stop()
        vencedor_som:play()
    end
end

-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(LARGURA_TELA,ALTURA_TELA,{resizable = false })
    love.window.setTitle("14bis vs Asteroids")
    math.randomseed(os.time())
 
    inicio_jogo_img = love.graphics.newImage("imagens/inicio_jogo.png")
    background = love.graphics.newImage("imagens/background.png")
    aviao_14bis.image = love.graphics.newImage(aviao_14bis.src)
    meteoro_img = love.graphics.newImage("imagens/meteoro.png")
    tiro_img = love.graphics.newImage("imagens/tiro.png")
    gameover_img = love.graphics.newImage("imagens/gameover.png")
    vencedor_img = love.graphics.newImage("imagens/vencedor.png")



   musica_ambiente = love.audio.newSource("audios/ambiente.wav","static")
   musica_ambiente:setLooping(true)
   musica_ambiente:play()

   destruicao = love.audio.newSource("audios/destruicao.wav","static")
   game_over = love.audio.newSource("audios/game_over.wav","static")
   disparo = love.audio.newSource("audios/disparo.wav","static")
   vencedor_som = love.audio.newSource("audios/winner.wav","static")





 end

-- Increase the size of the rectangle every frame.
function love.update(dt)

    if not TELA_INICIO_JOGO then
        if love.keyboard.isDown('return') then
            TELA_INICIO_JOGO = true
        end
    else 
        if not FIM_JOGO and not VENCEDOR then 
            if love.keyboard.isDown('up','left','down','right') then
                move14bis();
            end    
            
            removeMeteoros()
            if #meteoros < MAX_METEOROS then
                criarMeteoro()
            end
            moveMeteoro()
            moviTiros()
            checaTemColisoes()
            checaObjetivoConcluido()
        end
    end

    
end

-- Draw a coloured rectangle.
function love.draw()
  
    if not TELA_INICIO_JOGO then
        love.graphics.draw(background,0,0);
        love.graphics.draw(inicio_jogo_img,LARGURA_TELA/2 - inicio_jogo_img:getWidth()/2 , ALTURA_TELA/2);
     else
        love.graphics.draw(background,0,0);
        love.graphics.draw(aviao_14bis.image,aviao_14bis.x,aviao_14bis.y);
        love.graphics.print("Meteoros restantes "..NUMERO_METEOROS_OBJETIVO-METEOROS_ATINGIDOS,0,0)
    
        for k,meteoro in pairs(meteoros) do
            love.graphics.draw(meteoro_img,meteoro.x,meteoro.y);
        end
    
        for k,tiro in pairs(aviao_14bis.tiros) do
            love.graphics.draw(tiro_img,tiro.x,tiro.y);
        end
    
        if FIM_JOGO == true then
            love.graphics.draw(gameover_img,LARGURA_TELA/2 - gameover_img:getWidth()/2,ALTURA_TELA/2 -gameover_img:getHeight()/2);
        end
    
        if VENCEDOR == true then        
            love.graphics.draw(vencedor_img,LARGURA_TELA/2 - gameover_img:getWidth()/2,ALTURA_TELA/2 -gameover_img:getHeight()/2);
         end
    end
    

    
 end