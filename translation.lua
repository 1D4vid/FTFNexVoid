local Translations = {
    ["PT"] = {
        -- Sidebar (Menu Lateral)
        ["Highlight"] = "Destaques (ESP)", ["Visual"] = "Visuais", ["Progress"] = "Progresso", 
        ["Textures"] = "Texturas", ["Auto Farm"] = "Auto Farm", ["Fog"] = "Neblina", 
        ["Sound"] = "Sons", ["Advanced"] = "Avançado", ["Visual Skins"] = "Skins Visuais", 
        ["Teleport"] = "Teleporte",["Settings"] = "Configurações", ["Info"] = "Informações",

        -- Aba: Highlight
        ["ESP Features"] = "Funções de Visão (ESP)", ["Esp Players"] = "ESP Jogadores", ["Esp outline"] = "Contorno Jogadores", 
        ["Beast Highlight"] = "Brilho na Fera", ["Esp Tracer Line"] = "Linha (Tracer)", ["Tracer Origin"] = "Origem da Linha",["Esp Computers"] = "ESP Computadores", ["Esp Doors"] = "ESP Portas", ["Esp Freezepods"] = "ESP Cápsulas",
        ["Global Settings"] = "Configurações Globais",["Only Esp Beast"] = "Apenas ESP na Fera", ["Hide ESP Names"] = "Ocultar Nomes no ESP",
        ["Tracer Control"] = "Controle de Linhas", ["Tracer Thickness"] = "Espessura da Linha",
        ["Color Customization"] = "Cores de Preenchimento",["Beast highlight Color"] = "Cor do Brilho da Fera", 
        ["Survivor Fill Color"] = "Cor do Fundo: Sobrevivente", ["Beast Fill Color"] = "Cor do Fundo: Fera",["Freezepod Fill Color"] = "Cor do Fundo: Cápsula",["Outline Customization"] = "Cores de Contorno", ["Survivor Outline"] = "Contorno: Sobrevivente", 
        ["Beast Outline"] = "Contorno: Fera", ["Computer Outline"] = "Contorno: Computador", 
        ["Freezepod Outline"] = "Contorno: Cápsula", ["Door Outline"] = "Contorno: Porta",

        -- Aba: Visual
        ["Camera & UI"] = "Câmera e Interface", ["Fov Changer"] = "Alterar Campo de Visão", ["Font Changer"] = "Alterar Fonte da Tela", ["stretch screen"] = "Tela Esticada",
        ["Visual Name/Level"] = "Nome/Nível Falso", ["Enable Visuals"] = "Ativar Falsificação",["Fake Name"] = "Nome Falso", ["Fake Level"] = "Nível Falso", ["Select Icon"] = "Ícone Falso",
        ["Spoof Other Players"] = "Falsificar Outros Jogadores",["Enable Others Spoofing"] = "Ativar Falsificação de Outros", 
        ["Target Player"] = "Jogador Alvo", ["Select Player"] = "Selecionar Jogador", ["Target Fake Name"] = "Nome Falso Alvo", 
        ["Target Fake Level"] = "Nível Falso Alvo",["Target Fake Icon"] = "Ícone Falso Alvo", ["Apply To Selected Player"] = "Aplicar ao Jogador Selecionado", 
        ["Reset Selected Player"] = "Resetar Jogador Selecionado", ["Clear All Spoofed Players"] = "Limpar Todos Falsificados",
        ["Visual Environment"] = "Ambiente Visual", ["Hide Leaves (Only Homestead)"] = "Sem Folhas (Mapa Homestead)",["Gray characters"] = "Personagens Cinzas", ["Floorbang"] = "Atirar pelo Chão",["Wallhop Lines"] = "Linhas de Wallhop",

        -- Aba: Settings (Configurações e Saves)
        ["Menu Configuration"] = "Configuração do Menu", ["Menu Keybind:"] = "Tecla do Menu:", 
        ["Configuration Management"] = "Gerenciamento de Configurações", ["Config Name:"] = "Nome da Config:",["Save Config"] = "Salvar Config", ["Load Config"] = "Carregar Config", ["Set as Default"] = "Definir como Padrão", 
        ["Reset All Configs to Default"] = "Resetar Todas as Configurações", ["Available Configs:"] = "Configurações Disponíveis:",
        ["Server Management"] = "Gerenciamento de Servidor", ["Server Rejoin"] = "Reentrar no Servidor",["Random Servers"] = "Servidores Aleatórios",

        -- Modals / Telas de Info["Exit NexVoidHub"] = "Sair do NexVoidHub",["Are you absolutely sure you want to close the script? You will need to re-execute to open it again."] = "Tem certeza absoluta que deseja fechar o script? Você precisará reexecutar para abri-lo novamente.", ["Cancel"] = "Cancelar",["Yes, Exit"] = "Sim, Sair",
        ["SCRIPT INFO"] = "INFORMAÇÕES DO SCRIPT", ["Close"] = "Fechar",
        ["CREDITS"] = "CRÉDITOS",["PLAYER INFO"] = "INFO DO JOGADOR", ["SERVER INFO"] = "INFO DO SERVIDOR",["Thank you for using Nexvoid."] = "Obrigado por usar o NexVoid.",["NexVoid is a free script, don't pay for it."] = "NexVoid é um script grátis, não pague por ele.",

        -- Aba: Advanced
        ["Survivor"] = "Sobrevivente", ["Auto Save (Teleport)"] = "Salvar Amigos (Teleporte)", ["Auto Save (Silent)"] = "Salvar Amigos (Invisível)", 
        ["Beast Untie Player"] = "Fera Solta Jogadores", ["Anti Ragdoll"] = "Anti-Desmaio/Queda", ["Slow Beast"] = "Fera Lenta (Bug)", 
        ["Slow Runner Beast"] = "Fera Lenta Automática", ["Slow Beast Aura"] = "Aura de Fera Lenta", ["Slow Beast Aura Range"] = "Alcance Aura Fera Lenta", 
        ["Touch Fling"] = "Girar ao Tocar (Touch Fling)", ["No Hack Fail"] = "Nunca Errar o PC",
        ["Beast"] = "Fera (Beast)", ["Change Camera Mode"] = "Forçar Câmera Livre", ["Auto Tie"] = "Amarrar Automático", 
        ["Auto Tie Range"] = "Alcance Amarrar Auto", ["Hit Aura"] = "Aura de Dano", ["Hit Aura Range"] = "Alcance da Aura de Dano", 
        ["Hitbox Extender"] = "Aumentar Hitbox (Caixa de Dano)", ["Hitbox Size"] = "Tamanho da Hitbox", ["Show Hitbox"] = "Mostrar Hitbox", ["No Jump Delay"] = "Sem Atraso no Pulo",
        ["Players"] = "Movimentação", ["Fast Double Jump"] = "Pulo Duplo Rápido", ["Walkspeed"] = "Velocidade (Walkspeed)", 
        ["Speed Value"] = "Ajustar Velocidade",["Jump Power"] = "Força do Pulo", ["Jump Power Val"] = "Ajustar Pulo",["Fly"] = "Voar (Fly)", 
        ["Fly Speed"] = "Velocidade de Voo", ["Noclip"] = "Atravessar Paredes (Noclip)", ["ShiftLock"] = "Travar Câmera (ShiftLock)", ["Inf Jump"] = "Pulo Infinito",

        -- Aba: Auto Farm
        ["Auto Farm Version Beta"] = "Auto Farm (Versão Beta)", ["Enable Auto Farm"] = "Ativar Auto Farm", ["Auto Win Survivor"] = "Ganhar Automático (Sobrevivente)", ["Auto Win Beast"] = "Ganhar Automático (Fera)", ["Anti AFK"] = "Anti AFK",

        -- Aba: Progress
        ["Timers & Indicators"] = "Cronômetros e Indicadores", ["Computer Progress"] = "Progresso dos Computadores", ["Door Progress"] = "Progresso das Portas", ["ExitDoor Progress"] = "Progresso das Portas de Saída", ["GetUp Timer"] = "Tempo de Levantar", ["Beast Power Timer"] = "Tempo do Poder (Fera)",["Beast Power Timer V2"] = "Tempo do Poder V2", ["Beast Spawn Timer"] = "Tempo para Fera Nascer", ["WalkSpeed Detector"] = "Detector de Velocidade",

        -- Aba: Sounds["Mute Sounds"] = "Silenciar Sons", ["Remove Your Steps"] = "Remover Seus Passos",["Remove Your Jumps"] = "Remover Seus Pulos", ["Remove Pc Hack Sounds"] = "Remover Sons de Hack do PC", ["No hit sound"] = "Sem Som de Dano",
        ["General"] = "Geral", ["Volume Boost"] = "Aumento de Volume",
        ["Custom Sound Packs"] = "Pacotes de Som Customizados", ["Default Sounds (Reset All)"] = "Sons Padrões (Resetar Tudo)", ["Walk"] = "Andar", ["Jump"] = "Pular", ["Fall"] = "Cair", ["Normal"] = "Normal", ["Extra Jumps (Part 1)"] = "Pulos Extras (Parte 1)", ["Extra Jumps (Part 2)"] = "Pulos Extras (Parte 2)", ["Three Jumps"] = "Três Pulos", ["Yusei Jump"] = "Pulo do Yusei",

        -- Aba: Teleport
        ["Map Objects Teleport"] = "Teleporte para Objetos", ["Checkpoint (UI + R Key)"] = "Ponto de Retorno (UI + Tecla R)", ["Teleport Computer"] = "Teleportar: Computador", ["Teleport Exitdoor"] = "Teleportar: Porta de Saída", ["Teleport Freezepods"] = "Teleportar: Cápsula",
        ["Players Teleport"] = "Teleporte de Jogadores", ["Refresh"] = "Atualizar Lista", ["Teleport"] = "Teleportar",

        -- Aba: Textures["Textures Settings"] = "Configurações de Texturas", ["White Bricks"] = "Tijolos Brancos (White Bricks)", ["Snow Textures"] = "Texturas de Neve", ["Remove Textures"] = "Remover Texturas", ["FpsBooster"] = "Aumentar FPS", ["Ultra HD Graphics"] = "Gráficos Ultra HD", ["Minecraft Texture"] = "Textura de Minecraft",["Double Jump Effects"] = "Efeitos de Pulo Duplo", ["Apply"] = "Aplicar", ["Default"] = "Padrão", ["Mobile Button Jump"] = "Botão de Pulo (Mobile)", ["Crosshair Settings"] = "Configurações de Mira", ["Cursor Size"] = "Tamanho do Cursor",

        -- Aba: Fog & Calibrator
        ["Fog Settings"] = "Configurações de Neblina", ["No fog"] = "Sem Neblina", ["Black Fog"] = "Neblina Escura", ["FlashLight"] = "Lanterna", ["Advanced Color Calibrator"] = "Calibrador de Cores Avançado",["Enable Calibrator"] = "Ativar Calibrador", ["Enable FullBright"] = "Ativar Brilho (FullBright)", ["Contrast"] = "Contraste", ["Brightness"] = "Brilho", ["Saturation"] = "Saturação", ["Hue Filter"] = "Filtro de Matiz (Cor)",["Filter Opacity"] = "Opacidade do Filtro",

        -- Misc / Textos Base
        ["Inferior"] = "Abaixo", ["Topo"] = "Acima", ["Torso"] = "Peito",["Nenhum"] = "Nenhum"
    },
    ["ES"] = {
        -- Sidebar (Menu Lateral)
        ["Highlight"] = "Destaques (ESP)", ["Visual"] = "Visuales", ["Progress"] = "Progreso", 
        ["Textures"] = "Texturas", ["Auto Farm"] = "Auto Farm", ["Fog"] = "Niebla", 
        ["Sound"] = "Sonido", ["Advanced"] = "Avanzado", ["Visual Skins"] = "Skins Visuales", 
        ["Teleport"] = "Teletransporte", ["Settings"] = "Configuraciones", ["Info"] = "Información",

        -- Aba: Highlight
        ["ESP Features"] = "Opciones de ESP", ["Esp Players"] = "ESP Jugadores", ["Esp outline"] = "Contorno Jugadores", 
        ["Beast Highlight"] = "Brillo de Bestia", ["Esp Tracer Line"] = "Línea Trazadora", ["Tracer Origin"] = "Origen de la Línea",["Esp Computers"] = "ESP Computadoras", ["Esp Doors"] = "ESP Puertas",["Esp Freezepods"] = "ESP Cápsulas",
        ["Global Settings"] = "Ajustes Globales",["Only Esp Beast"] = "Solo ESP Bestia", ["Hide ESP Names"] = "Ocultar Nombres ESP",
        ["Tracer Control"] = "Control de Trazadoras", ["Tracer Thickness"] = "Grosor de la Línea",
        ["Color Customization"] = "Colores de Relleno",["Beast highlight Color"] = "Color Brillo Bestia", 
        ["Survivor Fill Color"] = "Color Relleno Superviviente", ["Beast Fill Color"] = "Color Relleno Bestia",["Freezepod Fill Color"] = "Color Relleno Cápsula",
        ["Outline Customization"] = "Colores de Contorno", ["Survivor Outline"] = "Contorno Superviviente",["Beast Outline"] = "Contorno Bestia", ["Computer Outline"] = "Contorno Computadora",["Freezepod Outline"] = "Contorno Cápsula", ["Door Outline"] = "Contorno Puerta",

        -- Aba: Visual
        ["Camera & UI"] = "Cámara e Interfaz", ["Fov Changer"] = "Cambiar FOV", ["Font Changer"] = "Cambiar Fuente", ["stretch screen"] = "Pantalla Estirada",
        ["Visual Name/Level"] = "Nombre/Nivel Falso",["Enable Visuals"] = "Activar Falso", ["Fake Name"] = "Nombre Falso", ["Fake Level"] = "Nivel Falso", ["Select Icon"] = "Ícono Falso",
        ["Spoof Other Players"] = "Falsificar Otros Jugadores", ["Enable Others Spoofing"] = "Activar Falsificación Ajena", 
        ["Target Player"] = "Jugador Objetivo", ["Select Player"] = "Seleccionar Jugador",["Target Fake Name"] = "Nombre Falso Objetivo", 
        ["Target Fake Level"] = "Nivel Falso Objetivo", ["Target Fake Icon"] = "Ícono Falso Objetivo", ["Apply To Selected Player"] = "Aplicar a Jugador Seleccionado", 
        ["Reset Selected Player"] = "Restablecer Jugador Seleccionado", ["Clear All Spoofed Players"] = "Limpiar Todos Falsificados",["Visual Environment"] = "Entorno Visual", ["Hide Leaves (Only Homestead)"] = "Sin Hojas (Solo Homestead)", ["Gray characters"] = "Personajes Grises", ["Floorbang"] = "Atravesar Suelo", ["Wallhop Lines"] = "Líneas de Wallhop",

        -- Aba: Settings (Configurações e Saves)
        ["Menu Configuration"] = "Configuración del Menú",["Menu Keybind:"] = "Tecla del Menú:", 
        ["Configuration Management"] = "Gestión de Configuraciones",["Config Name:"] = "Nombre de Config:", 
        ["Save Config"] = "Guardar Config",["Load Config"] = "Cargar Config", ["Set as Default"] = "Fijar como Predeterminado", 
        ["Reset All Configs to Default"] = "Restablecer Todas las Config",["Available Configs:"] = "Configuraciones Disponibles:",
        ["Server Management"] = "Gestión de Servidor", ["Server Rejoin"] = "Reentrar al Servidor", ["Random Servers"] = "Servidores Aleatorios",

        -- Modals / Telas de Info
        ["Exit NexVoidHub"] = "Salir de NexVoidHub",["Are you absolutely sure you want to close the script? You will need to re-execute to open it again."] = "¿Estás absolutamente seguro de que quieres cerrar el script? Necesitarás volver a ejecutarlo para abrirlo.", ["Cancel"] = "Cancelar", ["Yes, Exit"] = "Sí, Salir",
        ["SCRIPT INFO"] = "INFORMACIÓN DEL SCRIPT", ["Close"] = "Cerrar",["CREDITS"] = "CRÉDITOS", ["PLAYER INFO"] = "INFO DEL JUGADOR",["SERVER INFO"] = "INFO DEL SERVIDOR",
        ["Thank you for using Nexvoid."] = "Gracias por usar NexVoid.", ["NexVoid is a free script, don't pay for it."] = "NexVoid es un script gratuito, no pagues por él.",

        -- Aba: Advanced
        ["Survivor"] = "Superviviente", ["Auto Save (Teleport)"] = "Auto Salvar (Teletransporte)",["Auto Save (Silent)"] = "Auto Salvar (Invisible)", 
        ["Beast Untie Player"] = "Bestia Suelta Jugador", ["Anti Ragdoll"] = "Anti-Desmayo", ["Slow Beast"] = "Bestia Lenta", 
        ["Slow Runner Beast"] = "Bestia Lenta Automática", ["Slow Beast Aura"] = "Aura Bestia Lenta", ["Slow Beast Aura Range"] = "Rango Aura Bestia Lenta", 
        ["Touch Fling"] = "Volar al Tocar (Touch Fling)", ["No Hack Fail"] = "Nunca fallar PC",
        ["Beast"] = "Bestia", ["Change Camera Mode"] = "Forzar Cámara Libre", ["Auto Tie"] = "Atar Automático", 
        ["Auto Tie Range"] = "Rango Atar Auto", ["Hit Aura"] = "Aura de Golpe", ["Hit Aura Range"] = "Rango Aura de Golpe",["Hitbox Extender"] = "Extender Hitbox", ["Hitbox Size"] = "Tamaño de Hitbox",["Show Hitbox"] = "Mostrar Hitbox", ["No Jump Delay"] = "Sin Retraso de Salto",
        ["Players"] = "Jugadores", ["Fast Double Jump"] = "Doble Salto Rápido", ["Walkspeed"] = "Velocidad de Caminata", 
        ["Speed Value"] = "Valor de Velocidad", ["Jump Power"] = "Poder de Salto", ["Jump Power Val"] = "Valor de Salto", ["Fly"] = "Volar", 
        ["Fly Speed"] = "Velocidad de Vuelo", ["Noclip"] = "Atravesar Paredes", ["ShiftLock"] = "Bloqueo de Cámara", ["Inf Jump"] = "Salto Infinito",

        -- Aba: Auto Farm
        ["Auto Farm Version Beta"] = "Auto Farm (Versión Beta)", ["Enable Auto Farm"] = "Activar Auto Farm",["Auto Win Survivor"] = "Ganar Automático (Superviviente)", ["Auto Win Beast"] = "Ganar Automático (Bestia)", ["Anti AFK"] = "Anti AFK",

        -- Aba: Progress["Timers & Indicators"] = "Temporizadores e Indicadores", ["Computer Progress"] = "Progreso de Computadoras", ["Door Progress"] = "Progreso de Puertas", ["ExitDoor Progress"] = "Progreso Puerta de Salida", ["GetUp Timer"] = "Tiempo para Levantarse", ["Beast Power Timer"] = "Tiempo del Poder (Bestia)", ["Beast Power Timer V2"] = "Tiempo del Poder V2",["Beast Spawn Timer"] = "Temporizador Aparición Bestia", ["WalkSpeed Detector"] = "Detector de Velocidad",

        -- Aba: Sounds
        ["Mute Sounds"] = "Silenciar Sonidos",["Remove Your Steps"] = "Eliminar Tus Pasos", ["Remove Your Jumps"] = "Eliminar Tus Saltos", ["Remove Pc Hack Sounds"] = "Eliminar Sonidos de Hack PC", ["No hit sound"] = "Sin Sonido de Daño",
        ["General"] = "General", ["Volume Boost"] = "Aumento de Volumen",
        ["Custom Sound Packs"] = "Paquetes de Sonido",["Default Sounds (Reset All)"] = "Sonidos Predeterminados", ["Walk"] = "Caminar", ["Jump"] = "Salto", ["Fall"] = "Caer", ["Normal"] = "Normal",["Extra Jumps (Part 1)"] = "Saltos Extras (Parte 1)", ["Extra Jumps (Part 2)"] = "Saltos Extras (Parte 2)", ["Three Jumps"] = "Tres Saltos",["Yusei Jump"] = "Salto de Yusei",

        -- Aba: Teleport["Map Objects Teleport"] = "Teletransporte a Objetos", ["Checkpoint (UI + R Key)"] = "Punto de Control (UI + Tecla R)", ["Teleport Computer"] = "Teletransportar: Computadora",["Teleport Exitdoor"] = "Teletransportar: Puerta", ["Teleport Freezepods"] = "Teletransportar: Cápsula",
        ["Players Teleport"] = "Teletransporte de Jugadores", ["Refresh"] = "Actualizar Lista", ["Teleport"] = "Teletransportar",

        -- Aba: Textures
        ["Textures Settings"] = "Ajustes de Texturas", ["White Bricks"] = "Ladrillos Blancos (White Bricks)", ["Snow Textures"] = "Texturas de Nieve",["Remove Textures"] = "Eliminar Texturas", ["FpsBooster"] = "Aumentar FPS",["Ultra HD Graphics"] = "Gráficos Ultra HD", ["Minecraft Texture"] = "Textura de Minecraft",
        ["Double Jump Effects"] = "Efectos de Doble Salto", ["Apply"] = "Aplicar", ["Default"] = "Predeterminado", ["Mobile Button Jump"] = "Botón de Salto (Mobile)", ["Crosshair Settings"] = "Ajustes de Mira", ["Cursor Size"] = "Tamaño del Cursor",

        -- Aba: Fog & Calibrator
        ["Fog Settings"] = "Ajustes de Niebla", ["No fog"] = "Sin Niebla", ["Black Fog"] = "Niebla Oscura",["FlashLight"] = "Linterna", ["Advanced Color Calibrator"] = "Calibrador de Color Avanzado", ["Enable Calibrator"] = "Activar Calibrador", ["Enable FullBright"] = "Activar FullBright", ["Contrast"] = "Contraste", ["Brightness"] = "Brillo", ["Saturation"] = "Saturación",["Hue Filter"] = "Filtro de Matiz (Color)", ["Filter Opacity"] = "Opacidad del Filtro",

        -- Misc / Textos Base
        ["Inferior"] = "Abajo", ["Topo"] = "Arriba", ["Torso"] = "Pecho", ["Nenhum"] = "Ninguno"
    }
}

local TranslationModule = {}

-- Função auxiliar para procurar reverso do Dropdown caso volte pro Inglês (EN)
local function GetEnglishKey(value)
    for key, translatedVal in pairs(Translations["PT"]) do
        if value == translatedVal then return key end
    end
    for key, translatedVal in pairs(Translations["ES"]) do
        if value == translatedVal then return key end
    end
    return value
end

function TranslationModule.Translate(gui, lang)
    if not gui then return end

    -- Carrega o Dicionário selecionado (PT, ES ou nulo se for EN)
    local dict = Translations[lang]

    for _, element in pairs(gui:GetDescendants()) do
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            local currentText = element.Text
            
            -- Puxa o Texto Original (Inglês) salvo no Atributo
            local original = element:GetAttribute("OriginalText")
            
            -- Detecção Inteligente: Se o OriginalText não existe (Ex: Textos fixos) 
            -- Mas está na tabela de traduções como chave (Inglês), salva como OriginalText pra não quebrar.
            if not original and Translations["PT"][currentText] then
                original = currentText
                element:SetAttribute("OriginalText", original)
            end

            if original then
                if lang == "EN" then
                    -- VOLTANDO PARA O INGLÊS
                    local splitPos = string.find(currentText, ": ")
                    if splitPos then
                        -- Lógica correta para Dropdown e Inputs (Recupera o valor após o ": ")
                        local val = string.sub(currentText, splitPos + 2)
                        local enVal = GetEnglishKey(val)
                        element.Text = original .. ": " .. enVal
                    else
                        element.Text = original
                    end
                elseif dict then
                    -- TRADUZINDO PARA PT OU ES
                    local translatedText = dict[original]
                    if translatedText then
                        local splitPos = string.find(currentText, ": ")
                        if splitPos then
                            -- É um Dropdown ou Input de Texto Variável (Traduz a Base e o Valor se houver na lista)
                            local val = string.sub(currentText, splitPos + 2)
                            local valTranslated = dict[val] or val
                            element.Text = translatedText .. ": " .. valTranslated
                        else
                            -- Texto Simples
                            element.Text = translatedText
                        end
                    end
                end
            end
        end
    end
end

return TranslationModule
