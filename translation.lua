local Translations = {
    ["PT"] = {
        -- Menu Lateral (Sidebar)
        ["Highlight"] = "Destaques (ESP)",
        ["Visual"] = "Visuais",
        ["Progress"] = "Progresso",
        ["Textures"] = "Texturas",["Fog"] = "Neblina",
        ["Sound"] = "Sons",
        ["Advanced"] = "Avançado",
        ["Visual Skins"] = "Skins Visuais",
        ["Teleport"] = "Teleporte",
        ["Highlight Config"] = "Config de ESP",
        ["Info"] = "Informações",

        -- Aba: Highlight
        ["ESP Features"] = "Funções de Visão (ESP)",
        ["Esp Players"] = "ESP Jogadores",
        ["Esp outline"] = "Contorno Jogadores",
        ["Esp Tracer Line"] = "Linha (Tracer)",
        ["Tracer Origin"] = "Origem da Linha",
        ["Esp Computers"] = "ESP Computadores",["Esp Doors"] = "ESP Portas",
        ["Esp Freezepods"] = "ESP Cápsulas",
        ["Beast Highlight"] = "Brilho na Fera",

        -- Aba: Highlight Config
        ["Global Settings"] = "Configurações Globais",
        ["Only Esp Beast"] = "Apenas ESP na Fera",
        ["Hide Name Esp Player"] = "Ocultar Nomes no ESP",
        ["Color Customization"] = "Cores Personalizadas",
        ["Beast highlight Color"] = "Cor do Brilho da Fera",
        ["Survivor ESP Color"] = "Cor ESP: Sobrevivente",
        ["Beast ESP Color"] = "Cor ESP: Fera",["Freezepod ESP Color"] = "Cor ESP: Cápsula",

        -- Aba: Visual
        ["Camera & UI"] = "Câmera e Interface",
        ["Fov Changer"] = "Alterar Campo de Visão",
        ["Font Changer"] = "Alterar Fonte da Tela",
        ["stretch screen"] = "Tela Esticada",
        ["Visual Name/Level"] = "Nome/Nível Falso",["Enable Visuals"] = "Ativar Falsificação",
        ["Fake Name"] = "Nome Falso",
        ["Fake Level"] = "Nível Falso",
        ["Select Icon"] = "Ícone Falso",
        ["Visual Environment"] = "Ambiente Visual",
        ["Hide Leaves (Only Homestead)"] = "Sem Folhas (Mapa Homestead)",
        ["Gray characters"] = "Personagens Cinzas",["Floorbang"] = "Atirar pelo Chão",

        -- Aba: Progress (Timers)
        ["Timers & Indicators"] = "Cronômetros e Indicadores",
        ["Computer Progress"] = "Progresso dos Computadores",
        ["Door timer"] = "Tempo das Portas",["GetUp Timer"] = "Tempo de Levantar",
        ["ExitDoor Timer"] = "Tempo da Porta de Saída",
        ["BeastPower timer"] = "Tempo do Poder (Beast)",["BeastPower Timer V2"] = "Tempo do Poder V2",

        -- Aba: Textures
        ["Textures Settings"] = "Configurações de Texturas",
        ["Remove Textures"] = "Remover Texturas",
        ["FpsBooster"] = "Aumentar FPS (FpsBooster)",
        ["Ultra HD Graphics"] = "Gráficos Ultra HD",
        ["Minecraft Texture"] = "Textura de Minecraft",["Double Jump Effects"] = "Efeitos de Pulo Duplo",
        ["Apply"] = "Aplicar",
        ["Mobile Button Jump"] = "Botão de Pulo (Mobile)",
        ["Crosshair Settings"] = "Configurações de Mira",
        ["Cursor Size"] = "Tamanho do Cursor",

        -- Aba: Fog & Calibrator
        ["Fog Settings"] = "Configurações de Neblina",
        ["No fog"] = "Sem Neblina",
        ["Black Fog"] = "Neblina Escura",
        ["FlashLight"] = "Lanterna",
        ["Advanced Color Calibrator"] = "Calibrador de Cores Avançado",
        ["Enable Calibrator"] = "Ativar Calibrador",
        ["Enable FullBright"] = "Ativar Brilho (FullBright)",
        ["Contrast"] = "Contraste",
        ["Brightness"] = "Brilho",
        ["Saturation"] = "Saturação",
        ["Hue Filter"] = "Filtro de Matiz (Cor)",["Filter Opacity"] = "Opacidade do Filtro",
        ["Reset Configurations"] = "Redefinir Configurações",

        -- Aba: Advanced
        ["Survivor"] = "Sobrevivente",["No hack fail"] = "Nunca Errar o PC",
        ["Fling"] = "Girar (Fling / Derrubar)",
        ["Anti Ragdoll"] = "Anti-Desmaio/Queda",["Slow Beast"] = "Fera Lenta (Bug)",
        ["Beast Untie Player"] = "Fera Solta Jogadores",
        ["Auto Save (Teleport)"] = "Salvar Amigos (Teleporte)",
        ["Auto Save (Silent)"] = "Salvar Amigos (Invisível)",

        ["Beast"] = "Fera (Beast)",
        ["No Jump Delay"] = "Sem Atraso no Pulo",
        ["Hitbox extender"] = "Aumentar Hitbox (Caixa de Dano)",
        ["Show Hitbox"] = "Mostrar Hitbox",
        ["Hitbox Size"] = "Tamanho da Hitbox",
        ["Anti Fling"] = "Anti-Fling (Sem Colisão)",
        ["Auto Tie"] = "Amarrar Automático",
        ["Hit Aura"] = "Aura de Dano",["Hit Aura Range"] = "Alcance da Aura de Dano",

        ["Players"] = "Movimentação do Jogador",
        ["Fast Double Jump"] = "Pulo Duplo Rápido",["Inf Jump"] = "Pulo Infinito",
        ["Shiftlock"] = "Travar Câmera (Shiftlock)",
        ["Fly"] = "Voar (Fly)",
        ["Fly Speed"] = "Velocidade de Voo",
        ["No clip"] = "Atravessar Paredes (Noclip)",
        ["Jump Power"] = "Força do Pulo",
        ["Jump Power Val"] = "Ajustar Pulo",
        ["Walkspeed"] = "Velocidade (Walkspeed)",["Speed Value"] = "Ajustar Velocidade",

        -- Menus Extras (Exit, Settings, Player Card)
        ["SETTINGS"] = "CONFIGURAÇÕES",
        ["Menu Keybind:"] = "Tecla do Menu:",
        ["Sets the key to Open and Close this menu."] = "Define a tecla para Abrir e Fechar o menu.",
        ["Save Configurations"] = "Salvar Configurações",["Saves ALL your enabled options (Toggles, Sliders, Inputs) and your Keybind so they load automatically on your next execution."] = "Salva TODAS as suas opções ativas e atalhos para carregar na próxima vez.",
        ["Deletes all saved data and restores the script to its default state."] = "Exclui todos os dados salvos e restaura o script para o padrão.",
        ["Close"] = "Fechar",["Exit NexVoidHub"] = "Sair do NexVoidHub",["Are you absolutely sure you want to close the script? You will need to re-execute to open it again."] = "Tem certeza absoluta que deseja fechar o script? Você precisará reexecutar para abri-lo novamente.",
        ["Cancel"] = "Cancelar",
        ["Yes, Exit"] = "Sim, Sair",
        ["Set Key"] = "Definir Tecla",
        ["Reset"] = "Resetar",
        ["Saved Successfully!"] = "Salvo com Sucesso!",
        ["Reset Successfully!"] = "Redefinido com Sucesso!",

        -- Dropdowns
        ["Inferior"] = "Embaixo",
        ["Topo"] = "Cima",
        ["Torso"] = "Peito",
        ["Default"] = "Padrão",
        ["Nenhum"] = "Nenhum"
    },
    ["ES"] = {
        -- Menu Lateral["Highlight"] = "Destaques (ESP)",
        ["Visual"] = "Visuales",
        ["Progress"] = "Progreso",
        ["Textures"] = "Texturas",
        ["Fog"] = "Niebla",
        ["Sound"] = "Sonido",
        ["Advanced"] = "Avanzado",
        ["Visual Skins"] = "Skins Visuales",
        ["Teleport"] = "Teletransporte",
        ["Highlight Config"] = "Config. de ESP",
        ["Info"] = "Información",

        -- Aba: Highlight["ESP Features"] = "Opciones de ESP",
        ["Esp Players"] = "ESP Jugadores",
        ["Esp outline"] = "Contorno Jugadores",
        ["Esp Tracer Line"] = "Línea Trazadora",
        ["Tracer Origin"] = "Origen de la Línea",
        ["Esp Computers"] = "ESP Computadoras",
        ["Esp Doors"] = "ESP Puertas",["Esp Freezepods"] = "ESP Cápsulas",
        ["Beast Highlight"] = "Brillo de Bestia",

        -- Aba: Highlight Config
        ["Global Settings"] = "Ajustes Globales",
        ["Only Esp Beast"] = "Solo ESP Bestia",
        ["Hide Name Esp Player"] = "Ocultar Nombres ESP",
        ["Color Customization"] = "Personalización de Color",["Beast highlight Color"] = "Color Brillo Bestia",
        ["Survivor ESP Color"] = "Color Superviviente",
        ["Beast ESP Color"] = "Color Bestia",["Freezepod ESP Color"] = "Color Cápsula",

        -- Aba: Visual
        ["Camera & UI"] = "Cámara e Interfaz",
        ["Fov Changer"] = "Cambiar FOV",["Font Changer"] = "Cambiar Fuente",
        ["stretch screen"] = "Pantalla Estirada",["Visual Name/Level"] = "Nombre/Nivel Falso",
        ["Enable Visuals"] = "Activar Falso",
        ["Fake Name"] = "Nombre Falso",
        ["Fake Level"] = "Nivel Falso",
        ["Select Icon"] = "Ícono Falso",
        ["Visual Environment"] = "Entorno Visual",
        ["Hide Leaves (Only Homestead)"] = "Sin Hojas (Solo Homestead)",
        ["Gray characters"] = "Personajes Grises",
        ["Floorbang"] = "Atravesar Suelo",

        -- Aba: Progress (Timers)
        ["Timers & Indicators"] = "Temporizadores e Indicadores",
        ["Computer Progress"] = "Progreso de Computadoras",
        ["Door timer"] = "Tiempo de las Puertas",
        ["GetUp Timer"] = "Tiempo para Levantarse",
        ["ExitDoor Timer"] = "Tiempo de la Puerta de Salida",["BeastPower timer"] = "Tiempo del Poder (Bestia)",
        ["BeastPower Timer V2"] = "Tiempo del Poder V2",

        -- Aba: Textures
        ["Textures Settings"] = "Ajustes de Texturas",
        ["Remove Textures"] = "Eliminar Texturas",["FpsBooster"] = "Aumentar FPS (FpsBooster)",
        ["Ultra HD Graphics"] = "Gráficos Ultra HD",
        ["Minecraft Texture"] = "Textura de Minecraft",
        ["Double Jump Effects"] = "Efectos de Doble Salto",
        ["Apply"] = "Aplicar",["Mobile Button Jump"] = "Botón de Salto (Mobile)",
        ["Crosshair Settings"] = "Ajustes de Mira",
        ["Cursor Size"] = "Tamaño del Cursor",

        -- Aba: Fog & Calibrator
        ["Fog Settings"] = "Ajustes de Niebla",["No fog"] = "Sin Niebla",
        ["Black Fog"] = "Niebla Oscura",["FlashLight"] = "Linterna",
        ["Advanced Color Calibrator"] = "Calibrador de Color Avanzado",
        ["Enable Calibrator"] = "Activar Calibrador",["Enable FullBright"] = "Activar FullBright",
        ["Contrast"] = "Contraste",
        ["Brightness"] = "Brillo",
        ["Saturation"] = "Saturación",
        ["Hue Filter"] = "Filtro de Matiz (Color)",
        ["Filter Opacity"] = "Opacidad del Filtro",
        ["Reset Configurations"] = "Restablecer Configuraciones",

        -- Aba: Advanced["Survivor"] = "Superviviente",
        ["No hack fail"] = "Nunca fallar PC",
        ["Fling"] = "Volar Jugadores (Fling)",
        ["Anti Ragdoll"] = "Anti-Desmayo",["Slow Beast"] = "Bestia Lenta",
        ["Beast Untie Player"] = "Bestia Suelta Jugador",
        ["Auto Save (Teleport)"] = "Auto Salvar (Teletransporte)",
        ["Auto Save (Silent)"] = "Auto Salvar (Invisible)",

        ["Beast"] = "Bestia",
        ["No Jump Delay"] = "Sin Retraso de Salto",["Hitbox extender"] = "Extender Hitbox",
        ["Show Hitbox"] = "Mostrar Hitbox",
        ["Hitbox Size"] = "Tamaño de Hitbox",
        ["Anti Fling"] = "Anti Fling",
        ["Auto Tie"] = "Atar Automático",
        ["Hit Aura"] = "Aura de Golpe",
        ["Hit Aura Range"] = "Rango de Aura",["Players"] = "Jugadores",
        ["Fast Double Jump"] = "Doble Salto Rápido",
        ["Inf Jump"] = "Salto Infinito",
        ["Shiftlock"] = "Bloqueo de Cámara",
        ["Fly"] = "Volar",
        ["Fly Speed"] = "Velocidad de Vuelo",
        ["No clip"] = "Atravesar Paredes",
        ["Jump Power"] = "Poder de Salto",
        ["Jump Power Val"] = "Valor de Salto",
        ["Walkspeed"] = "Velocidad de Caminata",
        ["Speed Value"] = "Valor de Velocidad",

        -- Menus Extras (Exit, Settings, Player Card)
        ["SETTINGS"] = "CONFIGURACIONES",
        ["Menu Keybind:"] = "Tecla del Menú:",["Sets the key to Open and Close this menu."] = "Establece la tecla para Abrir y Cerrar este menú.",
        ["Save Configurations"] = "Guardar Configuraciones",["Saves ALL your enabled options (Toggles, Sliders, Inputs) and your Keybind so they load automatically on your next execution."] = "Guarda TODAS tus opciones activas y atajos para cargar la próxima vez.",["Deletes all saved data and restores the script to its default state."] = "Borra todos los datos guardados y restaura el script por defecto.",
        ["Close"] = "Cerrar",
        ["Exit NexVoidHub"] = "Salir de NexVoidHub",["Are you absolutely sure you want to close the script? You will need to re-execute to open it again."] = "¿Estás absolutamente seguro de que quieres cerrar el script? Necesitarás volver a ejecutarlo para abrirlo.",
        ["Cancel"] = "Cancelar",
        ["Yes, Exit"] = "Sí, Salir",
        ["Set Key"] = "Fijar Tecla",
        ["Reset"] = "Reiniciar",
        ["Saved Successfully!"] = "¡Guardado con Éxito!",["Reset Successfully!"] = "¡Restablecido con Éxito!"
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
