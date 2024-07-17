ui = require("ui");

ui:CreateUserInterface();

function onEvent(event)

    local noteIndex = #ui._sequence;
    while isNoteHeld() do

        if self._sequence[1] ~= nil then
            
            local sequenceStartIndex = 1;

            local beatCounter = self._sequence[sequenceStartIndex].duration;
            while beatCounter <= ui._sequence.meta.start - 1 do

                sequenceStartIndex = sequenceStartIndex + 1;
                beatCounter = beatCounter + ui._sequence[sequenceStartIndex].duration;
            end

            local sequenceStartDuration = self._sequence[sequenceStartIndex].duration - (beatCounter - ui._sequence.meta.start - 1);
            local sequenceEndIndex = sequenceStartIndex;

            while beatCounter < ui._sequence.meta.stop do 

                sequenceEndIndex = sequenceEndIndex + 1;
                beatCounter = beatCounter + ui._sequence[sequenceEndIndex].duration;
            end

            local sequenceEndDuration = beatCounter - (beatCounter - ui._sequence.meta.stop);

            
        end
    end
end

function onSave()

    return { ui = ui:Save() };
end

function onLoad(data)

    ui:Load(data.ui);
end