ui = require("ui");

ui:CreateUserInterface();

function onEvent(event)

    if ui._sequence[1] == nil then

        return;
    end

    local sequenceStartIndex = 1;

    local beatCounter = ui._sequence[sequenceStartIndex].duration;
    while beatCounter <= ui._sequence.meta.start - 1 do

        sequenceStartIndex = sequenceStartIndex + 1;
        beatCounter = beatCounter + ui._sequence[sequenceStartIndex].duration;
    end

    local sequenceStartDuration = beatCounter - (ui._sequence.meta.start - 1);
    local sequenceEndIndex = sequenceStartIndex;

    while beatCounter < ui._sequence.meta.stop do 

        sequenceEndIndex = sequenceEndIndex + 1;
        beatCounter = beatCounter + ui._sequence[sequenceEndIndex].duration;
    end

    local sequenceEndDuration = ui._sequence[sequenceEndIndex].duration - (beatCounter - ui._sequence.meta.stop);

    local initStart = ui._sequence.meta.start;
    local initEnd = ui._sequence.meta.stop;
    local initLength = #ui._sequence;
    ui._sequence.meta.positionsChanged = false;

    local noteIndex = sequenceEndIndex;
    local durationCounter = 0;
    while isNoteHeld() do

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

        if noteIndex == sequenceEndIndex then

            noteIndex = sequenceStartIndex;
            notePlayed.duration = getBeatDuration() * sequenceStartDuration;
        elseif noteIndex == sequenceEndIndex - 1 then

            noteIndex = noteIndex + 1;
            notePlayed.duration = getBeatDuration() * sequenceEndDuration;
        else

            noteIndex = noteIndex + 1;
            notePlayed.duration = getBeatDuration() * ui._sequence[noteIndex].duration;
        end

        for i = 1, 3 do

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

        if ui._sequence[noteIndex].active then

            wait(notePlayed.duration);
        else

            notePlayed.note = event.note + ui._sequence[noteIndex].offset;
            notePlayed.velocity = ui._sequence[noteIndex].velocity;
            notePlayed.pan = ui._sequence[noteIndex].pan;

            playNote(notePlayed);
            wait(notePlayed.duration);
        end
    end
end

function onSave()

    return { ui = ui:Save() };
end

function onLoad(data)

    ui:Load(data.ui);
end