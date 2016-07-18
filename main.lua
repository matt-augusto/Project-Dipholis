debug = true

--Sistema de colisão (Ctrl + C Ctrl + v msm)
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

jogador = { x = 200, y = 400, vel = 150, img = nil}

--vars do jogador
isVivo = true
score = 0
shotsfired = 0
shotshit = 0
shotsmissed = 0
accuracy = 0
deathscore = 0
highscore = 0

--timevars
atira = true --atirar balas
atiraTimerMax = 0.2
atiraTimer = atiraTimerMax
enviaInimTimerMax = 0.4 --spawnar inimigos
enviaInimTimer = enviaInimTimerMax

--Declaração de imagens para o loading ser mais rápido
bgImg = nil
inimImg = nil
balaImg = nil

--Declaração de tabelas
balas = {}
inimigos = {}

--Declaração de sons
inimMorte = nil
sndBala = nil
morreu = nil
music = nil

function love.load(arg) --Carregando assets de fato (imgs e sons)
  jogador.img = love.graphics.newImage('img/jogador.png')
  balaImg = love.graphics.newImage('img/bala.png')
  inimImg = love.graphics.newImage('img/inimigo.png')

  inimMorte = love.audio.newSource('snd/inimMorte.mp3', 'static')
  sndBala = love.audio.newSource('snd/tiro.mp3', 'static')
  morreu = love.audio.newSource('snd/morreu2.mp3', 'static')
  music = love.audio.newSource('snd/music.mp3')
  sndBala:setVolume(0.5)
  inimMorte:setVolume(0.65)
end

function love.update(dt) --Lógica do jogo
  if love.keyboard.isDown('escape') then
    isPaused = true
  end

  if isPaused then
    if love.keyboard.isDown('y') then
      love.event.push('quit')
    end
    if love.keyboard.isDown('n') then
      isPaused = false
    end
  end

  if isVivo and not isPaused then
    music:play()
    --bala
    atiraTimer = atiraTimer - (1 * dt)
    if atiraTimer < 0 then
      atira = true
    end

    for i, bala in ipairs(balas) do
      bala.y = bala.y - (250 * dt)

      if bala.y < 0 then
        table.remove(balas, i)
        shotsmissed = shotsmissed + 1
      end
    end --fim bala

    --inimigos
    enviaInimTimer = enviaInimTimer - (1 * dt)
    if enviaInimTimer < 0 then
      enviaInimTimer = enviaInimTimerMax
      rndPos = math.random(10, love.graphics.getWidth() - 80)
      novoInim = {x = rndPos, y = -10, img = inimImg}
      table.insert(inimigos, novoInim)
    end

    for i, inimigo in ipairs(inimigos) do
      inimigo.y = inimigo.y + (200 * dt)

      if inimigo.y > 600 then
        table.remove(inimigos, i)
        score = score - 2
      end
    end

    --controles
  if isVivo then
    if love.keyboard.isDown('left') then
      if jogador.x > 0 then
        jogador.x = jogador.x - (jogador.vel*dt)
      end
    elseif love.keyboard.isDown('right') then
      if jogador.x < (love.graphics.getWidth() - jogador.img:getWidth()) then
        jogador.x = jogador.x + (jogador.vel*dt)
      end
    end
    if love.keyboard.isDown('up') then
      if jogador.y > 0 then
        jogador.y = jogador.y - (jogador.vel*dt)
      end
    elseif love.keyboard.isDown('down') then
      if jogador.y < (love.graphics.getHeight() - jogador.img:getHeight()) then
        jogador.y = jogador.y + (jogador.vel*dt)
      end
    end
    if love.keyboard.isDown('z') and atira then
      novaBala = { x = jogador.x + (jogador.img:getWidth()/2), y = jogador.y, img = balaImg}
      sndBala:play()
      table.insert(balas, novaBala)
      atira = false
      shotsfired = shotsfired + 1
      atiraTimer = atiraTimerMax
    end
  end --fim controles

    --colisao
    for i, inimigo in ipairs(inimigos) do
      for j, bala in ipairs(balas) do
        if CheckCollision(inimigo.x, inimigo.y, inimigo.img:getWidth(), inimigo.img:getHeight(), bala.x, bala.y, bala.img:getWidth(), bala.img:getHeight()) then
          table.remove(inimigos, i)
          table.remove(balas, j)
          inimMorte:play()
          score = score + 2
          shotshit = shotshit + 1
        end
      end

      if CheckCollision(inimigo.x, inimigo.y, inimigo.img:getWidth(), inimigo.img:getHeight(), jogador.x, jogador.y, jogador.img:getWidth(), jogador.img:getHeight()) and isVivo then
        table.remove(inimigos, i)
        music:stop()
        morreu:play()
        isVivo = false
        deathscore = score
        if score > highscore then
          highscore = score
        end
      end
    end --fim colisao
  end

  --restart
  if not isVivo and love.keyboard.isDown('r') then
    balas = {}
    inimigos = {}

    atira = atiraTimerMax
    enviaInimTimer = enviaInimTimerMax

    jogador.x = 200
    jogador.y = 400

    shotsfired = 0
    shotshit = 0
    shotsmissed = 0
    accuracy = 0

    score = 0
    isVivo = true
  end --fim restart
end --fim update

function love.draw(dt)
  if isPaused then
    love.graphics.print("PAUSE", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.print("Quer sair? Y/N", love.graphics.getWidth() / 2, (love.graphics.getHeight() / 2) + 10)
  else
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Tiros: " .. shotsfired, 10, 20)
    love.graphics.print("Acertos: " .. shotshit, 10, 30)
    love.graphics.print("Erros: " .. shotsmissed, 120, 30)
    love.graphics.print("High Score: " .. highscore, 300, 10)
    love.graphics.print("Last Score: " .. deathscore, 300, 20)
    love.graphics.setBackgroundColor(0, 0, 100)
    if isVivo then
      love.graphics.draw(jogador.img, jogador.x, jogador.y)
    else
      love.graphics.print("Se fodeu", 200, 150)
    end

    for i, bala in ipairs(balas) do
      love.graphics.draw(bala.img, bala.x, bala.y)
    end

    for i, inimigo in ipairs(inimigos) do
      love.graphics.draw(inimigo.img, inimigo.x, inimigo.y)
    end
  end
end
