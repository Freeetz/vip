local VipTable = {}

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

AddEventHandler('esx:playerLoaded', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll("SELECT * FROM vips WHERE identifier=@identifier",{
        ['@identifier'] = xPlayer.identifier,
	}, function(data) 
        if data[1] then
            if tonumber(data[1].expiration) <= os.time() then
                xPlayer.showNotification('~r~Votre V.I.P à expirer !')
                MySQL.Async.execute('DELETE FROM vips WHERE identifier=@identifier', {
                    ['@identifier'] = xPlayer.identifier,
                })
            else
                local tempsrestant = (((tonumber(data[1].expiration)) - os.time())/60)
                local day        = (tempsrestant / 60) / 24
                local hrs        = (day - math.floor(day)) * 24
                local minutes    = (hrs - math.floor(hrs)) * 60
                local txtday     = math.floor(day)
                local txthrs     = math.floor(hrs)
                local txtminutes = math.ceil(minutes)
                xPlayer.showNotification('Votre VIP :\nPrendra fin dans ~g~'..math.floor(day).. ' ~w~jours et ~g~'..txthrs.."~w~ heure(s).")
                if not VipTable[xPlayer.identifier] then
                    VipTable[xPlayer.identifier] = true
                end
                TriggerClientEvent('freetz:updateVIP', src, true)
            end
        else
            VipTable[xPlayer.identifier] = false
            TriggerClientEvent('freetz:updateVIP', src, false)
        end
	end)
end)

RegisterNetEvent('freetz:GetVIP')
AddEventHandler('freetz:GetVIP',function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    while not xPlayer do Wait(1) xPlayer = ESX.GetPlayerFromId(source) end
    if not VipTable[xPlayer.identifier] then
        MySQL.Async.fetchAll("SELECT * FROM vips WHERE identifier=@identifier",{
            ['@identifier'] = xPlayer.identifier,
        }, function(data) 
            if data[1] then
                if tonumber(data[1].expiration) <= os.time() then
                    xPlayer.showNotification('Votre V.I.P à expirer')
                    MySQL.Async.execute('DELETE FROM vips WHERE identifier=@identifier', {
                        ['@identifier'] = xPlayer.identifier,
                    })
                else
                    local tempsrestant = (((tonumber(data[1].expiration)) - os.time())/60)
                    local day        = (tempsrestant / 60) / 24
                    local hrs        = (day - math.floor(day)) * 24
                    local minutes    = (hrs - math.floor(hrs)) * 60
                    local txtday     = math.floor(day)
                    local txthrs     = math.floor(hrs)
                    local txtminutes = math.ceil(minutes)
                    xPlayer.showNotification('Votre VIP :\nPrendra fin dans ~g~'..math.floor(day).. ' ~w~jours et ~g~'..txthrs.."~w~ heure(s).")
                    if not VipTable[xPlayer.identifier] then
                        VipTable[xPlayer.identifier] = true
                    end
                    TriggerClientEvent('freetz:updateVIP', src, true)
                end
            else
                VipTable[xPlayer.identifier] = false
                TriggerClientEvent('freetz:updateVIP', src, false)
            end
        end)
    end
end)

RegisterCommand('addVIP',function(source, args)
    if source == 0 then
        if args[1] then
            local TARGET = ESX.GetPlayerFromId(args[1]) 
            if not VipTable[TARGET.identifier] then
                local TARGET = ESX.GetPlayerFromId(tonumber(args[1]))
                local expiration = (30 * 86400)

                if expiration < os.time() then
                    expiration = os.time() + expiration
                end
                MySQL.Async.execute('INSERT INTO vips    (identifier, vip, expiration) VALUES (@identifier, @vip, @expiration)', {
                    ['@identifier'] = TARGET.identifier,
                    ['@vip'] = 1,
                    ['@expiration'] = expiration,
                })
                TARGET.showNotification('Vous venez d\'obtenir un grade ~y~VIP~w~ !\nGrade : ~b~V.I.P~w~\nMerci de votre achat.')
                VipTable[TARGET.identifier] = true
                TriggerClientEvent('freetz:updateVIP', TARGET.source, true)
            end
        else
            print("ID Du joueur manquante !")
        end
    end
end)

function GetVIP(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if VipTable[xPlayer.identifier] == true then 
        return true
    else
        return false
    end
end