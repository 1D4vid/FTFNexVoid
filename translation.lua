local TranslationModule = {}

local Dictionary = {
    ["Highlight"] = { PT = "Realce", ES = "Resaltar" },
    ["Highlight Config"] = { PT = "Config Realce", ES = "Config Resaltar" },
    ["Visual"] = { PT = "Visual", ES = "Visual" },
    ["Progress"] = { PT = "Progresso", ES = "Progreso" },
    ["Advanced"] = { PT = "Avançado", ES = "Avanzado" },
    ["Textures"] = { PT = "Texturas", ES = "Texturas" },
    ["Sound"] = { PT = "Som", ES = "Sonido" },
    ["Visual Skins"] = { PT = "Skins Visuais", ES = "Skins Visuales" },["CrossHair"] = { PT = "Mira", ES = "Mira" },
    ["Teleport"] = { PT = "Teleporte", ES = "Teletransporte" },
    ["Info"] = { PT = "Informação", ES = "Información" },
    
    ["ESP Features"] = { PT = "Funções ESP", ES = "Funciones ESP" },
    ["Esp Players"] = { PT = "Esp Jogadores", ES = "Esp Jugadores" },
    ["Esp outline"] = { PT = "Esp Contorno", ES = "Esp Contorno" },
    ["Esp Tracer Line"] = { PT = "Esp Linha Guia", ES = "Esp Línea Guía" },
    ["Tracer Origin"] = { PT = "Origem da Linha", ES = "Origen de Línea" },
    ["Esp Computers"] = { PT = "Esp Computadores", ES = "Esp Computadoras" },
    ["Esp Doors"] = { PT = "Esp Portas", ES = "Esp Puertas" },
    ["Esp Freezepods"] = { PT = "Esp Cápsulas", ES = "Esp Cápsulas" },
    ["Beast Highlight"] = { PT = "Realce da Fera", ES = "Resaltar Bestia" },
    
    ["Global Settings"] = { PT = "Configurações Globais", ES = "Ajustes Globales" },
    ["Only Esp Beast"] = { PT = "Apenas Esp Fera", ES = "Solo Esp Bestia" },
    ["Hide Name Esp Player"] = { PT = "Ocultar Nome Jogador", ES = "Ocultar Nombre Jugador" },
    ["Color Customization"] = { PT = "Personalização de Cor", ES = "Personalización de Color" },
    ["Beast highlight Color"] = { PT = "Cor Realce Fera", ES = "Color Resalte Bestia" },
    ["Survivor ESP Color"] = { PT = "Cor ESP Sobrevivente", ES = "Color ESP Superviviente" },["Beast ESP Color"] = { PT = "Cor ESP Fera", ES = "Color ESP Bestia" },["Freezepod ESP Color"] = { PT = "Cor ESP Cápsula", ES = "Color ESP Cápsula" },
    
    ["Camera & UI"] = { PT = "Câmera e Interface", ES = "Cámara y UI" },
    ["Fov Changer"] = { PT = "Mudar Campo de Visão", ES = "Cambiar Campo de Visión" },
    ["Font Changer"] = { PT = "Mudar Fonte", ES = "Cambiar Fuente" },
    ["stretch screen"] = { PT = "Esticar Tela", ES = "Estirar Pantalla" },
    
    ["Visual Name/Level"] = { PT = "Nome/Nível Visual", ES = "Nombre/Nivel Visual" },["Enable Visuals"] = { PT = "Ativar Visuais", ES = "Activar Visuales" },["Fake Name"] = { PT = "Nome Falso", ES = "Nombre Falso" },["Fake Level"] = { PT = "Nível Falso", ES = "Nivel Falso" },["Select Icon"] = { PT = "Selecionar Ícone", ES = "Seleccionar Icono" },
    
    ["Visual Environment"] = { PT = "Ambiente Visual", ES = "Entorno Visual" },
    ["Hide Leaves (Only Homestead)"] = { PT = "Ocultar Folhas (Homestead)", ES = "Ocultar Hojas (Homestead)" },
    ["No fog"] = { PT = "Sem Neblina", ES = "Sin Niebla" },
    ["Black Fog"] = { PT = "Neblina Escura", ES = "Niebla Oscura" },
    ["Gray characters"] = { PT = "Personagens Cinzas", ES = "Personajes Grises" },
    ["Floorbang"] = { PT = "Floorbang (Atravessar Chão)", ES = "Floorbang (Atravesar Suelo)" },["Textures Settings"] = { PT = "Configurações de Textura", ES = "Ajustes de Texturas" },
    ["Remove Textures"] = { PT = "Remover Texturas", ES = "Quitar Texturas" },["FpsBooster"] = { PT = "Otimizador de FPS", ES = "Aumentar FPS" },["Ultra HD Graphics"] = { PT = "Gráficos Ultra HD", ES = "Gráficos Ultra HD" },
    
    ["Double Jump Effects"] = { PT = "Efeitos de Pulo Duplo", ES = "Efectos de Doble Salto" },
    ["Insert Texture ID"] = { PT = "Inserir ID de Textura", ES = "Insertar ID de Textura" },
    ["Default"] = { PT = "Padrão", ES = "Por defecto" },
    
    ["Mobile Button Jump"] = { PT = "Botão de Pulo Mobile", ES = "Botón de Salto Móvil" },["Enter Texture ID..."] = { PT = "Insira o ID da Textura...", ES = "Ingrese ID de Textura..." },
    
    ["SKIN CHANGER"] = { PT = "MODIFICADOR DE SKIN", ES = "CAMBIADOR DE SKIN" },
    ["QUICK SELECT"] = { PT = "SELEÇÃO RÁPIDA", ES = "SELECCIÓN RÁPIDA" },
    ["Skin Found!"] = { PT = "Skin Encontrada!", ES = "Skin Encontrada!" },
    ["APPLY"] = { PT = "APLICAR", ES = "APLICAR" },
    ["Apply"] = { PT = "Aplicar", ES = "Aplicar" },["PLAYER INFO"] = { PT = "INFO DO JOGADOR", ES = "INFO DEL JUGADOR" },
    ["SERVER INFO"] = { PT = "INFO DO SERVIDOR", ES = "INFO DEL SERVIDOR" },
    ["Server Rejoin"] = { PT = "Reentrar no Servidor", ES = "Reconectar al Servidor" },
    ["Join Random Server"] = { PT = "Entrar em Servidor Aleatório", ES = "Entrar en Servidor Aleatorio" },
    
    ["SETTINGS"] = { PT = "CONFIGURAÇÕES", ES = "AJUSTES" },
    ["Menu Keybind:"] = { PT = "Tecla do Menu:", ES = "Tecla del Menú:" },
    ["Sets the key to Open and Close this menu."] = { PT = "Define a tecla para Abrir e Fechar este menu.", ES = "Establece la tecla para Abrir y Cerrar este menú." },["Save Configurations"] = { PT = "Salvar Configurações", ES = "Guardar Configuraciones" },["Saves ALL your enabled options (Toggles, Sliders, Inputs) and your Keybind so they load automatically on your next execution."] = { PT = "Salva TODAS as suas opções ativas e atalhos para carregarem automaticamente.", ES = "Guarda TODAS las opciones activas y teclas para que carguen automáticamente." },
    ["Reset Configurations"] = { PT = "Redefinir Configurações", ES = "Restablecer Configuraciones" },["Deletes all saved data and restores the script to its default state."] = { PT = "Apaga os dados salvos e restaura o script ao estado padrão.", ES = "Borra los datos guardados y restaura el script al estado predeterminado." },
    ["Close"] = { PT = "Fechar", ES = "Cerrar" },
    ["Cancel"] = { PT = "Cancelar", ES = "Cancelar" },
    ["Exit"] = { PT = "Sair", ES = "Salir" },
    ["CONFIRMATION"] = { PT = "CONFIRMAÇÃO", ES = "CONFIRMACIÓN" },
    ["Exit the Script?"] = { PT = "Sair do Script?", ES = "¿Salir del Script?" },
    
    ["Search..."] = { PT = "Pesquisar...", ES = "Buscar..." }
}

function TranslationModule.Translate(ScreenGui, Lang)
    for _, obj in pairs(ScreenGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            -- Set Cache
            if obj.Text and obj.Text ~= "" and not obj:GetAttribute("OrigText") then
                obj:SetAttribute("OrigText", obj.Text)
            end
            if obj.PlaceholderText and obj.PlaceholderText ~= "" and not obj:GetAttribute("OrigPlaceholder") then
                obj:SetAttribute("OrigPlaceholder", obj.PlaceholderText)
            end
            
            local orig = obj:GetAttribute("OrigText")
            if orig then
                -- Check for normal translation
                if Dictionary[orig] then
                    obj.Text = Lang == "EN" and orig or Dictionary[orig][Lang]
                else
                    -- Check for Dropdown format "Text: Value"
                    local parts = string.split(orig, ": ")
                    if #parts == 2 and Dictionary[parts[1]] then
                        local translatedPrefix = Lang == "EN" and parts[1] or Dictionary[parts[1]][Lang]
                        obj.Text = translatedPrefix .. ": " .. parts[2]
                    end
                end
            end

            local placeholder = obj:GetAttribute("OrigPlaceholder")
            if placeholder and Dictionary[placeholder] then
                obj.PlaceholderText = Lang == "EN" and placeholder or Dictionary[placeholder][Lang]
            end
        end
    end
end

return TranslationModule
