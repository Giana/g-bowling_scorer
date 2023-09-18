local QBCore = exports['qb-core']:GetCoreObject()

-- Functions --

function getStrikeScore(game, index, framesLen)
    local score = game[index]

    -- Scenario 1: Not the last frame
    if framesLen < 9 then
        score = score + game[index + 2]
        -- Scenario 1.1: Bonus is a strike
        if game[index + 2] == 10 then
            score = score + game[index + 4]
        -- Scenario 1.2: Bonus is not a strike
        else
            score = score + game[index + 3]
        end
    -- Scenario 2: Last frame
    else
        score = score + game[index + 1] + game[index + 2]
    end

    return score
end

function getSpareScore(game, index)
    return game[index + 1] + game[index + 2]
end

-- Events --

RegisterNetEvent('g-bowling_scorer:server:scoreGame', function(game)
    local src = source
    local score = 0
    local frames = {}
    local i = 0

    while i < #game do
        -- Scenario 1: Not the last frame
        if #frames < 9 then
            -- Scenario 1.1: All 10 pins with one ball
            if game[i] == 10 or game[i + 1] == 10 then
                -- Scenario 1.1.1: Strike
                if game[i] == 10 then
                    local strikeScore = getStrikeScore(game, i, #frames)
                    local newFrame = {strikeScore, 0}
                    table.insert(frames, newFrame)
                -- Scenario 1.1.2: Spare
                else
                    local spareScore = getSpareScore(game, i)
                    local newFrame = {game[i], spareScore}
                    table.insert(frames, newFrame)
                end
            -- Scenario 1.2: Not all 10 pins with one ball
            else
                -- Scenario 1.2.1: Spare
                if (game[i] + game[i + 1]) == 10 then
                    local spareScore = getSpareScore(game, i)
                    local newFrame = {game[i], spareScore}
                    table.insert(frames, newFrame)
                -- Scenario 1.2.2: No spare
                else
                    local newFrame = {game[i], game[i + 1]}
                    table.insert(frames, newFrame)
                end
            end

            i = i + 2
        -- Scenario 2: Last frame
        else
            -- Scenario 1.1: All 10 pins with one ball
            if game[i] == 10 or game[i + 1] == 10 then
                -- Scenario 1.1.1: Strike
                if game[i] == 10 then
                    local strikeScore = getStrikeScore(game, i, #frames)
                    local newFrame = {strikeScore, 0}
                    table.insert(frames, newFrame)
                    -- Scenario 1.1.2: Spare
                else
                    local spareScore = getSpareScore(game, i)
                    local newFrame = {game[i], spareScore}
                    table.insert(frames, newFrame)
                end
            -- Scenario 1.2: Not all 10 pins with one ball
            else
                -- Scenario 1.2.1: Spare
                if (game[i] + game[i + 1]) == 10 then
                    local spareScore = getSpareScore(game, i)
                    local newFrame = {game[i], spareScore}
                    table.insert(frames, newFrame)
                -- Scenario 1.2.2: No spare
                else
                    local newFrame = {game[i], game[i + 1]}
                    table.insert(frames, newFrame)
                end
            end

            break
        end
    end

    -- Get total score
    for k1, v1 in pairs(frames) do
        local currFrame = v1
        for k2, v2 in pairs(currFrame) do
            score = score + v2
        end
    end

    TriggerClientEvent('QBCore:Notify', src, 'Bowling game score: ' .. score, 'primary')
end)