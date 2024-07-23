ui = require("ui");

ui:CreateUserInterface();

-- Function called whenever the user holds a note. This function plays the notes of the sequence in order
-- and applies the specified effects.
function onEvent(event)

    if ui._sequence[1] == nil then

        return;
    end

    local sequenceStartIndex = 1;

    -- This while loop finds the note that the sequence starts on.
    local beatCounter = ui._sequence[sequenceStartIndex].duration;
    while beatCounter <= ui._sequence.meta.start - 1 do

        sequenceStartIndex = sequenceStartIndex + 1;
        beatCounter = beatCounter + ui._sequence[sequenceStartIndex].duration;
    end

    -- Depending on the start position of the sequence, the duration of the first note may need to be shortened.
    local sequenceStartDuration = beatCounter - (ui._sequence.meta.start - 1);
    local sequenceEndIndex = sequenceStartIndex;

    -- This while loop finds the note that the sequence ends on.
    while beatCounter < ui._sequence.meta.stop do 

        sequenceEndIndex = sequenceEndIndex + 1;
        beatCounter = beatCounter + ui._sequence[sequenceEndIndex].duration;
    end

    -- Depending on the ending position of the sequence, the last note in the sequence may need to be shortened.
    local sequenceEndDuration = ui._sequence[sequenceEndIndex].duration - (beatCounter - ui._sequence.meta.stop);

    -- Variables which hold the initial state of the sequence. If these variables are changed within playback,
    -- playback is stopped so that the sequence does not go out of time.
    local initStart = ui._sequence.meta.start;
    local initEnd = ui._sequence.meta.stop;
    local initLength = #ui._sequence;
    ui._sequence.meta.positionsChanged = false;

    local noteIndex = sequenceEndIndex;
    local durationCounter = 0;
    while isNoteHeld() do

        -- Compare current state of the sequence to initial state of sequence.
        if initStart ~= ui._sequence.meta.start then

            break;
        elseif initEnd ~= ui._sequence.meta.stop then

            break;
        elseif initLength ~= #ui._sequence then

            break;
        elseif ui._sequence.meta.positionsChanged then

            break;
        end

        local notePlayed = {};

        -- Sets the duration of the note played.
        if noteIndex == sequenceEndIndex then

            -- Executes if the first note of the sequence is shortened.
            noteIndex = sequenceStartIndex;
            notePlayed.duration = getBeatDuration() * sequenceStartDuration;
        elseif noteIndex == sequenceEndIndex - 1 then

            -- Executes if the last note of the sequence is shortened.
            noteIndex = noteIndex + 1;
            notePlayed.duration = getBeatDuration() * sequenceEndDuration;
        else

            noteIndex = noteIndex + 1;
            notePlayed.duration = getBeatDuration() * ui._sequence[noteIndex].duration;
        end

        -- This for loop sets the effects on the multi's master channel.
        for i = 1, 3 do

            -- Executes if the effect is either low pass or high pass.
            if (ui._sequence.meta.effectTypes[i] == 2) or (ui._sequence.meta.effectTypes[i] == 3) then

                if ui._sequence.meta.effectTypes[i] == 2 then

                    ui._synthFilters[i]:setParameter("Mode", 1);
                else

                    ui._synthFilters[i]:setParameter("Mode", 0);
                end

                ui._synthFilters[i]:setParameter("Bypass", ui._sequence[noteIndex].effects[i][1]);
                ui._synthFilters[i]:setParameter("Freq", ui._sequence[noteIndex].effects[i][2]);
                ui._synthFilters[i]:setParameter("Q", ui._sequence[noteIndex].effects[i][3]);

                ui._synthReverbs[i]:setParameter("Bypass", true);

            -- Executes if the effect is reverb.
            elseif ui._sequence.meta.effectTypes[i] == 4 then

                ui._synthReverbs[i]:setParameter("Bypass", ui._sequence[noteIndex].effects[i][1]);
                ui._synthReverbs[i]:setParameter("DecayTime", ui._sequence[noteIndex].effects[i][2]);
                ui._synthReverbs[i]:setParameter("HighDamp", ui._sequence[noteIndex].effects[i][3]);
                ui._synthReverbs[i]:setParameter("Mix", ui._sequence[noteIndex].effects[i][4]);

                ui._synthFilters[i]:setParameter("Bypass", true);
            else

                ui._synthReverbs[i]:setParameter("Bypass", true);
                ui._synthFilters[i]:setParameter("Bypass", true);
            end
        end

        -- Flash the note being played.
        ui:FlashOn(noteIndex);

        if ui._sequence[noteIndex].active then

            -- Wait the duration of the note and turn off flash.
            wait(notePlayed.duration - (notePlayed.duration / 2));
            ui:FlashOff();
            wait(notePlayed.duration / 2);
        else

            notePlayed.note = event.note + ui._sequence[noteIndex].offset;
            notePlayed.velocity = ui._sequence[noteIndex].velocity;
            notePlayed.pan = ui._sequence[noteIndex].pan;

            playNote(notePlayed);
            
            -- Wait the duration of the note and turn off flash.
            wait(notePlayed.duration - (notePlayed.duration / 2));
            ui:FlashOff();
            wait(notePlayed.duration / 2);
        end
    end
end

-- Saves custom data for modules.
function onSave()

    return { ui = ui:Save() };
end

-- Loads custom data for modules.
function onLoad(data)

    ui:Load(data.ui);
end