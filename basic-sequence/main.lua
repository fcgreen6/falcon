-- Main script:
------------------------------------------------------------------------------------------------------

-- The main script sends note events to the five layers of the program. Each subsequent note is sent to a
-- different layer of the program.

-- Each subsequent note alternates between seven half steps or five half steps bellow the previous note.

------------------------------------------------------------------------------------------------------

-- Creates user interface from the ui module.
local ui = require("ui");
ui:CreateUserInterface();

function onNote(e)

    -- Echo ratio.
    local ratio = ui.ratio;

    -- Duration of a beat.
    local beatDuration = getBeatDuration();

    -- Table which represents an echo event.
    local noteEcho = {
        note = e.note - 7, -- Initilized to frequency of first echo.
        velocity = e.velocity, -- Initilized to velocity of first echo.
        duration = 100,
        layer = 2 -- Each echo has a different layer with a different wave index.
    };

    -- Initial note.
    playNote({note = e.note, 
    velocity = e.velocity, 
    duration = 100,
    layer = 1});

    wait(beatDuration / ratio);

    -- Variables used within while loop.
    local counter = false;

    while noteEcho.note > 0 and noteEcho.layer < 6 do

        playNote(noteEcho);

        -- When counter is false five half steps will be 
        -- subtracted from frequency. Else seven steps are subtracted.
        if counter then
            
            noteEcho.note = noteEcho.note - 7;
            counter = false;
        else

            noteEcho.note = noteEcho.note - 5;
            counter = true;
        end

        -- Layer is changed.
        noteEcho.layer = noteEcho.layer + 1;

        wait(beatDuration / ratio);
    end
end

-- Save data for modules is stored with this callback.
function onSave()

    local saveData = { ui = ui:Save() }

    return saveData;
end

-- Loads saved data into modules.
function onLoad(saveData)

    ui:Load(saveData.ui);
end
