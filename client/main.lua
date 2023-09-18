local QBCore = exports['qb-core']:GetCoreObject()
local game = {}
local submitted = false

-- Functions --

function confirmScoreGameMenu()
    local menu = {
        {
            header = Lang:t('menu.confirm_score'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.yes'),
            params = {
                event = 'g-bowling_scorer:client:scoringInputMenu'
            }
        },
        {
            header = Lang:t('menu.no'),
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }

    return menu
end

function inBounds(throw)
    if throw then
        if throw < 0 or throw > 10 then
            return false
        end
    else
        return false
    end

    return true
end

function bonusEarned(throw1, throw2)
    if throw1 == 10 or throw1 + throw2 == 10 then
        return true
    end

    return false
end

-- Commands --

RegisterCommand(Config.BowlingScorerCommand, function(source, args)
    local menu = confirmScoreGameMenu()
    exports['qb-menu']:openMenu(menu)

    while not submitted do
        Wait(1000)
    end

    TriggerServerEvent('g-bowling_scorer:server:scoreGame', game)

    game = {}
    submitted = false
end)

-- Events --

RegisterNetEvent('g-bowling_scorer:client:scoringInputMenu', function()
    local i = 1;
    local j = 0;

    while i <= 10 do
        local input = {
            header = Lang:t('input.frame') .. ' ' .. i,
            submitText = Lang:t('input.submit'),
            inputs = {
                {
                    text = Lang:t('input.throw_1'),
                    name = 'throw1',
                    type = 'number',
                    isRequired = true
                },
                {
                    text = Lang:t('input.throw_2'),
                    name = 'throw2',
                    type = 'number',
                    isRequired = false
                }
            }
        }

        local inputResult = exports['qb-input']:ShowInput(input)

        if not inputResult.throw1 then
            QBCore.Functions.Notify(Lang:t('error.getting_input'), 'error')
            return
        end

        local throw1 = tonumber(inputResult.throw1)

        -- Not on last frame
        if i ~= 10 then
            -- Second throw not entered
            if not inputResult.throw2 then
                -- First throw not a strike
                if throw1 ~= 10 then
                    QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
                    return
                end
                -- First throw a strike
                inputResult.throw2 = 0
            end

            local throw2 = tonumber(inputResult.throw2)

            -- Out of bounds
            if not inBounds(throw1) or not inBounds(throw2) or (throw1 + throw2 > 10) then
                QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
                return
            end

            game[j] = throw1
            game[j + 1] = throw2
        else
            -- Second throw not entered
            if not inputResult.throw2 then
                QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
                return
            end

            local throw2 = tonumber(inputResult.throw2)

            -- Out of bounds
            if not inBounds(throw1) or not inBounds(throw2) then
                QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
                return
            end

            local throw3

            -- Bonus earned
            if bonusEarned(throw1, throw2) then
                input = {
                    header = Lang:t('input.frame') .. ' ' .. i .. ' - Bonus',
                    submitText = Lang:t('input.submit'),
                    inputs = {
                        {
                            text = Lang:t('input.throw_3'),
                            name = 'throw3',
                            type = 'number',
                            isRequired = true
                        }
                    }
                }

                inputResult = exports['qb-input']:ShowInput(input)

                if not inputResult.throw3 then
                    QBCore.Functions.Notify(Lang:t('error.getting_input'), 'error')
                    return
                end

                throw3 = tonumber(inputResult.throw3)

                -- Out of bounds
                if not inBounds(throw3) then
                    QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
                    return
                end
            end

            game[j] = throw1
            game[j + 1] = throw2

            if throw3 then
                game[j + 2] = throw3
            end
        end

        j = j + 2
        i = i + 1
    end

    submitted = true
end)