-- Class Data Members:
------------------------------------------------------------------------------------------------------

-- Synth Representation Objects ----------------------------------------------------------------------
-- synthFilters: Table which represents three analog filters on the master chanel of the template.
-- synthReverbs: Table which represents three reverb effects on the master chanel of the template.

-- Sequence Representation Data Members --------------------------------------------------------------
-- sequence: Table which represents the sequence defined by the user. Bellow, a sequence with a single note event is shown.

-- sequence = {
--  meta = {...},
--  {displacement = ...,
--  duration = ...,
--  end = ...,
--  velocity = ...,
--  effectOne = {...},
--  effectTwo = {...},
--  effectThree = {...},
--  pan = ...}
-- };

-- selected: 
-- copied:

-- Note Display Data Members -------------------------------------------------------------------------
-- displayPanel: Panel on which buttons representing notes are displayed.
-- leftButtonBig: Button which moves the view of the sequence left eight beats.
-- leftButtonSmall: Button which moves the view of the sequence left one beat.
-- rightButtonBig: Button which moves the view of the sequence right eight beats.
-- rightButtonSmall: Button which moves the view of the sequence right one beats.

------------------------------------------------------------------------------------------------------
-- Note Selection Buttons:
-- noteButtons:

-- Sequence Modification Data Members ----------------------------------------------------------------
-- sequencePanel: Panel on which controls related to modifying the sequence are displayed.
-- lengthBox: Box where the length of the sequence is specified.
-- moveNoteLeft: Button which moves a selected note or series of notes one beat to the left.
-- moveNoteRight: Button which moves a selected note or series of notes one beat to the right.
-- startBox: Box where the starting beat of the sequence is specified.
-- endBox: Box where the ending beat of the sequence is specified.
-- consolodateButton: Button which combines a series of similar notes into a single note.
-- subdivideButton: Button which divides a selected note or series of similar notes into multiple notes

-- Note Modification Data Members --------------------------------------------------------------------
-- notePanel: Panel on which controls related to individual notes are displayed.
-- panBox: Controls the pan of individual notes.
-- velocityBox: Controls the velocity of individual notes.
-- offsetBox: Controls the offset of individual notes relative to the root note in the sequence.
-- noteActive: Turns a note off or on.

-- Effect Data Members -------------------------------------------------------------------------------
-- effectPanels: Table containing the panels on which effects are displayed.
-- effectMenus: Table containing the "select effect" menu for each panel. 
-- filterKnobs: If a filter is selected, knobs for the selected filter are displayed on the panel.
-- reverbKnobs: If reverb is selected, reverb knobs are displayed on the panel.

-- Other Data Members --------------------------------------------------------------------------------
-- selectAllButton: Selects all notes in the sequence.
-- deselectAllButton: Deselects all notes in the sequence.
-- copyButton: Copies note and effect information.
-- pasteButton: Pastes copied note and effect information.

------------------------------------------------------------------------------------------------------

ui = {};

-- Creates class data members and defines most changed functions.
function ui.CreateUserInterface(self)

    -- Size of user interface.
    setSize(720, 480);

        -- Default sequence object.
        self._sequence = {
            meta = {
                displayPosition = 1, -- First beat displayed by the user interface.
                beats = 0, -- Number of beats in the sequence.
                start = 0, -- The beat that the sequence starts on.
                stop = 0, -- The beat that the sequence stops on.
                consecutive = false, -- If selected notes are consecutive this parameter is set to true.
                consolodate = false, -- If selected notes can be consolodated this parameter is set to true.
                maxSubdivide = -1, -- The largest note a selection can be subdivided into.
                displayNoteIndex = -1, -- Index of the note displayed on the user interface.
                selectedIndices = {}, -- Table which records notes in the sequence selected by the user.
                effectTypes = {}, -- Table which records the effect types selected by the user. Coresponds to the value of effect menus.
                copiedNote = nil -- Data member which will store a copied note.
            }
        };
        
    ------------------------------------------------------------------------------------------------------
    -- Synth Effect Elements
    ------------------------------------------------------------------------------------------------------

    -- Tables to hold effects on the synth's master chanel.
    self._synthFilters = {};
    self._synthReverbs = {};

    -- Create objects for the effects on the synth's master chanel.
    for i = 1, 3 do

        self._synthFilters[i] = Synth.inserts[(i * 2) - 1];
        self._synthReverbs[i] = Synth.inserts[i * 2];
    end
    
    ------------------------------------------------------------------------------------------------------
    -- Note Display Elements
    ------------------------------------------------------------------------------------------------------

    -- Panel where note events are visually displayed.
    self._displayPanel = Panel("displayPanel");
    self._displayPanel.pos = {40, 20};
    self._displayPanel.height = 90;
    self._displayPanel.width = 640;

    -- Big left button. Moves the view of the sequence left eight beats.
    self._leftButtonBig = Button("<-");
    self._leftButtonBig.pos = {5, 20};
    self._leftButtonBig.height = 57;
    self._leftButtonBig.width = 30;

    self._leftButtonBig.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition - 4;
        self:Refresh();
    end

    -- Small left button. Moves the view of the sequence left one beat.
    self._leftButtonSmall = Button("<-");
    self._leftButtonSmall.pos = {5, 81};
    self._leftButtonSmall.height = 27;
    self._leftButtonSmall.width = 30;

    self._leftButtonSmall.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition - 1;
        self:Refresh();
    end

    -- Big right button. Moves the view of the sequence right eight beats.
    self._rightButtonBig = Button("->");
    self._rightButtonBig.pos = {685, 20};
    self._rightButtonBig.height = 57;
    self._rightButtonBig.width = 30;

    self._rightButtonBig.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition + 4;
        self:Refresh();
    end

    -- Small right button. Moves the view of the sequence right one beat.
    self._rightButtonSmall = Button("->");
    self._rightButtonSmall.pos = {685, 81};
    self._rightButtonSmall.height = 27;
    self._rightButtonSmall.width = 30;

    self._rightButtonSmall.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition + 1;
        self:Refresh();
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Selection Buttons
    ------------------------------------------------------------------------------------------------------

    self._noteButtons = {};

    -- There are a maximum of thirty two selection buttions that can be displayed at the same time.
    for i = 1, 32 do

        self._noteButtons[i] = OnOffButton("B" .. i, false);
        self._noteButtons[i].y = 47;
        self._noteButtons[i].height = 30;
        self._noteButtons[i].enabled = false;
        self._noteButtons[i].visible = false;

        self._noteButtons[i].changed = function()

            for i = 1, #self._sequence.meta.selectedIndices do

                local buttonIndex = self:GetButtonIndex(self._sequence.meta.selectedIndices[i]);

                if buttonIndex then

                    if self._noteButtons[buttonIndex].value == false then

                        if self._sequence.meta.selectedIndices[i] == self._sequence.meta.displayNoteIndex then

                            if i == 1 then

                                self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[2];
                            elseif self._sequence.meta.selectedIndices[1] then

                                self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
                            else

                                self._sequence.meta.displayNoteIndex = -1;
                            end
                        end

                        table.remove(self._sequence.meta.selectedIndices, i);
                        self:UpdateMetadata();
                        self:Refresh();
                        return;
                    end
                end
            end

            for i = 1, 32 do

                if self._noteButtons[i].value then

                    local sequenceIndex = self:GetSequenceIndex(i);
                    local noMatchFound = true;

                    for j = 1, #self._sequence.meta.selectedIndices do

                        if sequenceIndex == self._sequence.meta.selectedIndices[j] then

                            noMatchFound = false;
                            break;
                        end
                    end

                    if noMatchFound then

                        self._sequence.meta.displayNoteIndex = sequenceIndex;
                        table.insert(self._sequence.meta.selectedIndices, #self._sequence.meta.selectedIndices + 1, sequenceIndex);
                        table.sort(self._sequence.meta.selectedIndices);
                    end
                end
            end

            self:UpdateMetadata();
            self:Refresh();
        end
    end

    ------------------------------------------------------------------------------------------------------
    -- Sequence Modification Panel
    ------------------------------------------------------------------------------------------------------

    -- Panel where the sequence is modified.
    self._sequencePanel = Panel("sequencePanel");
    self._sequencePanel.pos = {40, 165};
    self._sequencePanel.height = 120;
    self._sequencePanel.width = 300;

    -- Box where the number of beats in the sequence is modified.
    self._lengthBox = NumBox("lengthBox", 0, 0, 32, true);
    self._lengthBox.pos = {118, 171};
    self._lengthBox.height = 34;
    self._lengthBox.width = 144;

    self._lengthBox.changed = function()

        if self._lengthBox.value ~= 0 then

            self._startBox:setRange(1, self._lengthBox.value);
            self._startBox:setValue(1, false);
            self._sequence.meta.start = 1;

            self._endBox:setRange(1, self._lengthBox.value);
            self._endBox:setValue(self._lengthBox.value, false);
            self._sequence.meta.stop = self._lengthBox.value;
        else

            self._startBox:setRange(0, 0);
            self._startBox:setValue(0, false);
            self._sequence.meta.start = 0;

            self._endBox:setRange(0, 0);
            self._endBox:setValue(0, false);
            self._sequence.meta.stop = 0;
        end

        if self._lengthBox.value > self._sequence.meta.beats then

            for i = self._sequence.meta.beats, self._lengthBox.value - 1 do

                local defaultNote = {
                    duration = 1.0,
                    active = false,
                    pan = 0.0,
                    velocity = 100,
                    offset = 0,
                    effects = {}
                }

                for j = 1, 3 do
                
                    if (self._sequence.meta.effectTypes[j] == 2) or (self._sequence.meta.effectTypes[j] == 3) then

                        defaultNote.effects[j] = { false, 1000, 0.0 };
                    elseif self._sequence.meta.effectTypes[j] == 4 then
                        
                        defaultNote.effects[j] = { false, 2.0, 0.0, 50.0 };
                    else

                        defaultNote.effects[j] = nil;
                    end
                end

                table.insert(self._sequence, #self._sequence + 1, defaultNote);
            end
        else 

            local beatDifference = self._sequence.meta.beats - self._lengthBox.value;
            local deletedBeatsCounter = 0;

            while deletedBeatsCounter < beatDifference do 
                
                deletedBeatsCounter = deletedBeatsCounter + self._sequence[#self._sequence].duration;
                if deletedBeatsCounter > beatDifference then

                    self._sequence[#self._sequence].duration = deletedBeatsCounter - beatDifference;
                else

                    if self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] == #self._sequence then

                        table.remove(self._sequence.meta.selectedIndices);
                    end

                    if self._sequence.meta.displayNoteIndex == #self._sequence then

                        if self._sequence.meta.selectedIndices[1] then

                            self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
                        else

                            self._sequence.meta.displayNoteIndex = -1;
                        end
                    end

                    table.remove(self._sequence);
                end

                if (self._sequence.meta.displayPosition > self._lengthBox.value - 7) and (self._sequence.meta.displayPosition ~= 1) then
                    
                    self._sequence.meta.displayPosition = self._lengthBox.value - 7;
                end
            end

            self:UpdateMetadata();
        end

        self._sequence.meta.beats = self._lengthBox.value;
        self:Refresh();
    end

    -- Button which moves the selected series of notes left in the sequence.
    self._moveNoteLeft = Button("<-");
    self._moveNoteLeft.pos = {46, 171};
    self._moveNoteLeft.height = 34;
    self._moveNoteLeft.width = 46;

    self._moveNoteLeft.changed = function()

        local leftNoteCopy = self:CopyNote(self._sequence.meta.selectedIndices[1] - 1);
        table.remove(self._sequence, self._sequence.meta.selectedIndices[1] - 1);

        table.insert(self._sequence, self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices], leftNoteCopy);

        for i = 1, #self._sequence.meta.selectedIndices do

            self._sequence.meta.selectedIndices[i] = self._sequence.meta.selectedIndices[i] - 1;
        end

        self._sequence.meta.displayNoteIndex = self._sequence.meta.displayNoteIndex - 1;
        self:Refresh();
    end

    -- Button which moves the selected series of notes right in the sequence.
    self._moveNoteRight = Button("->");
    self._moveNoteRight.pos = {288, 171}
    self._moveNoteRight.height = 34;
    self._moveNoteRight.width = 46;

    self._moveNoteRight.changed = function()

        local rightNoteCopy = self:CopyNote(self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] + 1);
        table.remove(self._sequence, self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] + 1);

        table.insert(self._sequence, self._sequence.meta.selectedIndices[1], rightNoteCopy);

        for i = 1, #self._sequence.meta.selectedIndices do

            self._sequence.meta.selectedIndices[i] = self._sequence.meta.selectedIndices[i] + 1;
        end

        self._sequence.meta.displayNoteIndex = self._sequence.meta.displayNoteIndex + 1;
        self:Refresh();
    end

    -- Box where the start of the sequence is defined.
    self._startBox = NumBox("startBox", 0, 0, 0, true);
    self._startBox.pos = {46, 211};
    self._startBox.height = 34;
    self._startBox.width = 141;

    self._startBox.changed = function()

        self._sequence.meta.start = self._startBox.value;
        self._endBox:setRange(self._startBox.value, self._sequence.meta.beats);
        self:Refresh();
    end

    -- Box where the end of the sequence is defined.
    self._endBox = NumBox("endBox", 0, 0, 0, true);
    self._endBox.pos = {193, 211};
    self._endBox.height = 34;
    self._endBox.width = 141;

    self._endBox.changed = function()

        self._sequence.meta.stop = self._endBox.value;
        self._startBox:setRange(1, self._endBox.value);
        self:Refresh();
    end

    -- Button which will consolodate subdivided notes into a single note.
    self._consolodateButton = Button("consolodateButton");
    self._consolodateButton.pos = {46, 251};
    self._consolodateButton.height = 28;
    self._consolodateButton.width = 141;

    self._consolodateButton.changed = function()

        local combinedDuration = 0;
        for i = 1, #self._sequence.meta.selectedIndices do

            combinedDuration = combinedDuration + self._sequence[self._sequence.meta.selectedIndices[i]].duration;
        end

        while self._sequence.meta.selectedIndices[2] do

            table.remove(self._sequence, self._sequence.meta.selectedIndices[2]);
            table.remove(self._sequence.meta.selectedIndices, 2);

            for i = 2, #self._sequence.meta.selectedIndices do

                self._sequence.meta.selectedIndices[i] = self._sequence.meta.selectedIndices[i] - 1;
            end
        end

        self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
        self._sequence[self._sequence.meta.selectedIndices[1]].duration = combinedDuration;

        self:UpdateMetadata();
        self:Refresh();
    end

    -- Button which will divide a single note into multiple notes.
    self._subdivideButton = Button("subdivideButton");
    self._subdivideButton.pos = {193, 251};
    self._subdivideButton.height = 28; 
    self._subdivideButton.width = 141;

    self._subdivideButton.changed = function()

        self._subdivideButton.enabled = false;
        self._subdivideButton.visible = false;

        self._subdivideMenu.enabled = true;
        self._subdivideMenu.visible = true;

        self._subdivideMenu:setValue(1, false);
        self._subdivideMenu:clear();

        self._subdivideMenu:addItem("--Select Subdivision--")
        self._subdivideMenu:addItem("16th Notes");

        if self._sequence.meta.maxSubdivide >= 0.5 then

            self._subdivideMenu:addItem("8th Notes");
        end

        if self._sequence.meta.maxSubdivide == 1.0 then

            self._subdivideMenu:addItem("Quarter Notes");
        end
    end

    self._subdivideMenu = Menu("subdivideMenu", {});
    self._subdivideMenu.pos = {193, 251}
    self._subdivideMenu.height = 28;
    self._subdivideMenu.width = 141;
    self._subdivideMenu.showLabel = false;
    self._subdivideMenu.enabled = false;
    self._subdivideMenu.visible = false;

    self._subdivideMenu.changed = function()

        local subdivisionRatio;
        if self._subdivideMenu.value == 2 then

            subdivisionRatio = 0.25;
        elseif self._subdivideMenu.value == 3 then

            subdivisionRatio = 0.5;
        else

            subdivisionRatio = 1;
        end

        local i = 1;
        while i <= #self._sequence.meta.selectedIndices do

            local selectedIndex = self._sequence.meta.selectedIndices[i];
            local numSubdivisions = self._sequence[selectedIndex].duration / subdivisionRatio;

            self._sequence[selectedIndex].duration = subdivisionRatio;
            for j = 1, numSubdivisions - 1 do

                table.insert(self._sequence, selectedIndex, self:CopyNote(selectedIndex));
                table.insert(self._sequence.meta.selectedIndices, i + j, selectedIndex + j);
            end

            for j = i + numSubdivisions, #self._sequence.meta.selectedIndices do 

                self._sequence.meta.selectedIndices[j] = self._sequence.meta.selectedIndices[j] + numSubdivisions - 1;
            end

            i = i + numSubdivisions;
        end

        self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
        self:UpdateMetadata();
        self:Refresh();
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Modification Panel
    ------------------------------------------------------------------------------------------------------

    self._notePanel = Panel("notePanel");
    self._notePanel.pos = {380, 165};
    self._notePanel.height = 120;
    self._notePanel.width = 300;

    -- Pan
    self._panBox = NumBox("panBox", 0.0, -1.0, 1.0, false);
    self._panBox.pos = {480, 171};
    self._panBox.height = 54;
    self._panBox.width = 94;

    self._panBox.changed = function()

        self:UpdateSelected("pan", self._panBox.value);
    end

    -- velocity
    self._velocityBox = NumBox("velocityBox", 100, 0, 127, true);
    self._velocityBox.pos = {580, 171};
    self._velocityBox.height = 54;
    self._velocityBox.width = 94;

    self._velocityBox.changed = function()

        self:UpdateSelected("velocity", self._velocityBox.value);
    end

    -- offset
    self._offsetBox = NumBox("offsetBox", 0, -24, 24, true);
    self._offsetBox.pos = {480, 231};
    self._offsetBox.height = 48;
    self._offsetBox.width = 194;

    self._offsetBox.changed = function()

        self:UpdateSelected("offset", self._offsetBox.value);
    end

    -- On / off
    self._noteActive = OnOffButton("noteActive", false);
    self._noteActive.pos = {386, 171};
    self._noteActive.height = 108;
    self._noteActive.width = 88;

    self._noteActive.changed = function()

        self:UpdateSelected("active", self._noteActive.value);
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Effects Area
    ------------------------------------------------------------------------------------------------------

    self._effectPanels = {};
    self._effectMenus = {};
    self._filterKnobs = {};
    self._reverbKnobs = {};

    for i = 1, 3 do

        -- Effect panels.
        self._effectPanels[i] = Panel("effectPanel" .. i);
        self._effectPanels[i].pos = {40, 305 + (55 * (i - 1))};
        self._effectPanels[i].height = 45;
        self._effectPanels[i].width = 640;

        -- Select effect menus.
        self._effectMenus[i] = Menu("effectMenu" .. i, 
        {"--Select Effect--",
        "High Pass Filter", 
        "Low Pass Filter",
        "Reverb"});
        self._effectMenus[i].pos = {43, 318 + (55 * (i - 1))}; -- 308
        self._effectMenus[i].height = 20; -- 39
        self._effectMenus[i].width = 100;
        self._effectMenus[i].showLabel = false;

        -- Filter Knobs.
        self._filterKnobs[i] = {};

        self._filterKnobs[i].active = OnOffButton("filterOn" .. i, false);
        self._filterKnobs[i].active.pos = {304, 313 + (55 * (i - 1))};
        self._filterKnobs[i].active.height = 30;
        self._filterKnobs[i].active.width = 30;
        self._filterKnobs[i].active.enabled = false;
        self._filterKnobs[i].active.visible = false;

        self._filterKnobs[i].cutoff = Knob{"cutoff" .. i, 1000.0, 20.0, 20000.0, false, mapper = Mapper.Exponential};
        self._filterKnobs[i].cutoff.pos = {476, 313 + (55 * (i - 1))};
        self._filterKnobs[i].cutoff.height = 30;
        self._filterKnobs[i].cutoff.width = 30;
        self._filterKnobs[i].cutoff.enabled = false;
        self._filterKnobs[i].cutoff.visible = false;

        self._filterKnobs[i].resonance = Knob{"resonance" .. i, 0.0, 0.0, 100.0, false};
        self._filterKnobs[i].resonance.pos = {647, 313 + (55 * (i - 1))};
        self._filterKnobs[i].resonance.height = 30;
        self._filterKnobs[i].resonance.width = 30;
        self._filterKnobs[i].resonance.enabled = false;
        self._filterKnobs[i].resonance.visible = false;

        self._reverbKnobs[i] = {};

        self._reverbKnobs[i].active = OnOffButton("reverbOn" .. i, false);
        self._reverbKnobs[i].active.pos = {304, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].active.height = 30;
        self._reverbKnobs[i].active.width = 30;
        self._reverbKnobs[i].active.enabled = false;
        self._reverbKnobs[i].active.visible = false;

        self._reverbKnobs[i].time = Knob{"time" .. i, 0.0, 0.0, 10.0, false};
        self._reverbKnobs[i].time.pos = {423, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].time.height = 30;
        self._reverbKnobs[i].time.width = 30;
        self._reverbKnobs[i].time.enabled = false;
        self._reverbKnobs[i].time.visible = false;

        self._reverbKnobs[i].damp = Knob{"damp" .. i, 0.0, 0.0, 100.0, false};
        self._reverbKnobs[i].damp.pos = {542, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].damp.height = 30;
        self._reverbKnobs[i].damp.width = 30;
        self._reverbKnobs[i].damp.enabled = false;
        self._reverbKnobs[i].damp.visible = false;

        self._reverbKnobs[i].mix = Knob{"mix" .. i, 0.0, 0.0, 100.0, false};
        self._reverbKnobs[i].mix.pos = {647, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].mix.height = 30;
        self._reverbKnobs[i].mix.width = 30;
        self._reverbKnobs[i].mix.enabled = false;
        self._reverbKnobs[i].mix.visible = false;
    end

    self._effectMenus[1].changed = function()
        
        self:ChangeEffects(1);
        self:Refresh();
    end

    self._effectMenus[2].changed = function()
        
        self:ChangeEffects(2);
        self:Refresh();
    end

    self._effectMenus[3].changed = function()
        
        self:ChangeEffects(3);
        self:Refresh();
    end

    self._filterKnobs[1].active.changed = function()

        self:UpdateEffects(1, 1, self._filterKnobs[1].active.value);
    end

    self._filterKnobs[2].active.changed = function()

        self:UpdateEffects(2, 1, self._filterKnobs[2].active.value);
    end

    self._filterKnobs[3].active.changed = function()

        self:UpdateEffects(3, 1, self._filterKnobs[3].active.value);
    end

    self._filterKnobs[1].cutoff.changed = function()

        self:UpdateEffects(1, 2, self._filterKnobs[1].cutoff.value);
    end

    self._filterKnobs[2].cutoff.changed = function()

        self:UpdateEffects(2, 2, self._filterKnobs[2].cutoff.value);
    end

    self._filterKnobs[3].cutoff.changed = function()

        self:UpdateEffects(3, 2, self._filterKnobs[3].cutoff.value);
    end

    self._filterKnobs[1].resonance.changed = function()

        self:UpdateEffects(1, 3, self._filterKnobs[1].resonance.value)
    end

    self._filterKnobs[2].resonance.changed = function()

        self:UpdateEffects(2, 3, self._filterKnobs[2].resonance.value)
    end

    self._filterKnobs[3].resonance.changed = function()

        self:UpdateEffects(3, 3, self._filterKnobs[3].resonance.value)
    end

    self._reverbKnobs[1].active.changed = function()

        self:UpdateEffects(1, 1, self._reverbKnobs[1].active.value);
    end

    self._reverbKnobs[2].active.changed = function()

        self:UpdateEffects(2, 1, self._reverbKnobs[2].active.value);
    end

    self._reverbKnobs[3].active.changed = function()

        self:UpdateEffects(3, 1, self._reverbKnobs[3].active.value);
    end

    self._reverbKnobs[1].time.changed = function()

        self:UpdateEffects(1, 2, self._reverbKnobs[1].time.value);
    end

    self._reverbKnobs[2].time.changed = function()

        self:UpdateEffects(2, 2, self._reverbKnobs[2].time.value);
    end

    self._reverbKnobs[3].time.changed = function()

        self:UpdateEffects(3, 2, self._reverbKnobs[3].time.value);
    end

    self._reverbKnobs[1].damp.changed = function()

        self:UpdateEffects(1, 3, self._reverbKnobs[1].damp.value);
    end

    self._reverbKnobs[2].damp.changed = function()

        self:UpdateEffects(2, 3, self._reverbKnobs[2].damp.value);
    end

    self._reverbKnobs[3].damp.changed = function()

        self:UpdateEffects(3, 3, self._reverbKnobs[3].damp.value);
    end

    self._reverbKnobs[1].mix.changed = function()

        self:UpdateEffects(1, 4, self._reverbKnobs[1].mix.value);
    end

    self._reverbKnobs[2].mix.changed = function()

        self:UpdateEffects(2, 4, self._reverbKnobs[2].mix.value);
    end

    self._reverbKnobs[3].mix.changed = function()

        self:UpdateEffects(3, 4, self._reverbKnobs[3].mix.value);
    end

    ------------------------------------------------------------------------------------------------------
    -- Final Additions
    ------------------------------------------------------------------------------------------------------

    self._selectAllButton = Button("selectAllButton");
    self._selectAllButton.pos = {223, 113};
    self._selectAllButton.height = 20;
    self._selectAllButton.width = 134;

    self._selectAllButton.changed = function()

        self._sequence.meta.selectedIndices = {};

        for i = 1, #self._sequence do

            table.insert(self._sequence.meta.selectedIndices, i, i);
        end

        if self._sequence.meta.displayNoteIndex == -1 then 

            self._sequence.meta.displayNoteIndex = 1;
        end

        self:UpdateMetadata();
        self:Refresh();
    end

    self._deselectAllButton = Button("deselectAllButton");
    self._deselectAllButton.pos = {363, 113};
    self._deselectAllButton.height = 20;
    self._deselectAllButton.width = 134;

    self._deselectAllButton.changed = function()

        self._sequence.meta.selectedIndices = {};
        self._sequence.meta.displayNoteIndex = -1;

        self:UpdateMetadata();
        self:Refresh();
    end

    self._copyButton = Button("copyButton");
    self._copyButton.pos = {345, 255};
    self._copyButton.height = 30;
    self._copyButton.width = 30;

    self._copyButton.changed = function()

        self._pasteButton.enabled = true;
        self._sequence.meta.copiedNote = self:CopyNote(self._sequence.meta.displayNoteIndex);
    end

    self._pasteButton = Button("pasteButton");
    self._pasteButton.pos = {345, 220};
    self._pasteButton.height = 30;
    self._pasteButton.width = 30;

    self._pasteButton.changed = function()

        for i = 1, #self._sequence.meta.selectedIndices do

            local currentDuration = self._sequence[self._sequence.meta.selectedIndices[i]].duration;

            self._sequence[self._sequence.meta.selectedIndices[i]] = self._sequence.meta.copiedNote;
            self._sequence[self._sequence.meta.selectedIndices[i]].duration = currentDuration;
        end

        self:Refresh();
    end

    self:Refresh();
end

function ui.UpdateMetadata(self)

    local firstSelectedIndex = self._sequence.meta.selectedIndices[1];

    if firstSelectedIndex == nil then

        self._sequence.meta.consecutive = false;
        self._sequence.meta.consolodate = false;
        self._sequence.meta.maxSubdivide = -1;
        return;
    end

    -- Check for consecutive notes.
    self._sequence.meta.consecutive = false;
    if #self._sequence.meta.selectedIndices > 1 then
        
        local i = 1;
        while (firstSelectedIndex + i - 1) == (self._sequence.meta.selectedIndices[i]) do

            if i == #self._sequence.meta.selectedIndices then

                self._sequence.meta.consecutive = true;
                break;
            end

            i = i + 1;
        end
    end

    -- Finds the combined duration of all selected notes and the duration of the smallest note.
    local smallestNoteDuration = self._sequence[firstSelectedIndex].duration;
    local combinedDuration = 0;
    for i = 1, #self._sequence.meta.selectedIndices do

        combinedDuration = combinedDuration + self._sequence[self._sequence.meta.selectedIndices[i]].duration;
        
        if smallestNoteDuration > self._sequence[self._sequence.meta.selectedIndices[i]].duration then

            smallestNoteDuration = self._sequence[self._sequence.meta.selectedIndices[i]].duration;
        end
    end

    -- If the selected notes are consecutive and have a combined duration of two or less,
    -- they can be consolodated.
    self._sequence.meta.consolodate = false;
    if self._sequence.meta.consecutive and (combinedDuration <= 2.0) then

            self._sequence.meta.consolodate = true;
    end

    -- This series of if statements determines how a selection of notes can be subdivided.
    if smallestNoteDuration == 2.0 then

        self._sequence.meta.maxSubdivide = 1.0;
    elseif (smallestNoteDuration == 1.5) or (smallestNoteDuration == 1.0) then

        self._sequence.meta.maxSubdivide = 0.5;
    elseif smallestNoteDuration == 0.5 then

        self._sequence.meta.maxSubdivide = 0.25;
    else

        self._sequence.meta.maxSubdivide = -1;
    end
end

function ui.Refresh(self)
    
    -- Deselects and disables all note buttons so that they can be rearranged.
    local i = 1;
    while (i <= 32) and (self._noteButtons[i].visible) do

        if self._noteButtons[i].value then

            self._noteButtons[i]:setValue(false, false);
        end

        self._noteButtons[i].visible = false;
        self._noteButtons[i].enabled = false;

        i = i + 1;
    end

    -- Exits the function if there are no notes in the sequence.
    if self._sequence[1] == nil then

        self._selectAllButton.enabled = false;
        self:DisableAll();
        return;
    end

    i = 1;
    local currentButtonWidth = self:GetButtonWidth(1);
    local buttonPosition = 40;

    while currentButtonWidth do

        self._noteButtons[i].width = currentButtonWidth;
        self._noteButtons[i].x = buttonPosition + 3;
        self._noteButtons[i].visible = true;
        self._noteButtons[i].enabled = true;

        i = i + 1;
        buttonPosition = buttonPosition + currentButtonWidth + 6;
        currentButtonWidth = self:GetButtonWidth(i);
    end
    
    if #self._sequence.meta.selectedIndices > 0 then

        for j = 1, #self._sequence.meta.selectedIndices do

            local selectedButtonIndex = self:GetButtonIndex(self._sequence.meta.selectedIndices[j]);

            if selectedButtonIndex then

                self._noteButtons[selectedButtonIndex]:setValue(true, false);
            end
        end
    else

        self._selectAllButton.enabled = true;
        self:DisableAll();
        return;
    end

    self:SetDisplayNote(self._sequence.meta.displayNoteIndex);
end

function ui.GetButtonIndex(self, targetSequenceIndex)

    local beatCounter = self._sequence[1].duration;
    local currentSequenceIndex = 1;

    -- This while loop stops after currentSequenceIndex is set to the index of the first note displayed on screen.
    while beatCounter <= self._sequence.meta.displayPosition - 1 do

        currentSequenceIndex = currentSequenceIndex + 1;
        beatCounter = beatCounter + self._sequence[currentSequenceIndex].duration;
    end

    -- Returns nil if target is bellow the point where the user interface starts.
    if targetSequenceIndex < currentSequenceIndex then

        return nil;
    end

    -- Counts starting at the beats displayed on the user interface.
    local displayBeatCounter = beatCounter - (self._sequence.meta.displayPosition - 1);
    local currentButtonIndex = 1;

    -- This while loop stops after the indices of notes on the user interface have been checked.
    while displayBeatCounter < 8 do

        -- If the indices match, the index of the coreesponding button is returned.
        if currentSequenceIndex == targetSequenceIndex then

            return currentButtonIndex;
        end

        currentSequenceIndex = currentSequenceIndex + 1;
        currentButtonIndex = currentButtonIndex + 1;
        displayBeatCounter = displayBeatCounter + self._sequence[currentSequenceIndex].duration;
    end

    -- Returns nil if target is above the point where the user interface stops.
    if currentSequenceIndex == targetSequenceIndex then

        return currentButtonIndex;
    else

        return nil;
    end
end

function ui.GetSequenceIndex(self, targetButtonIndex)

    -- There are always less or an equal ammount of buttons compared to notes in the sequence.
    if targetButtonIndex > #self._sequence then

        return nil;
    end

    local beatCounter = self._sequence[1].duration;
    local sequenceIndex = 1;
    local currentButtonIndex = 1;

    -- This while loop stops after sequenceIndex is set to the index of the first note displayed on screen.
    while beatCounter <= self._sequence.meta.displayPosition - 1 do

        sequenceIndex = sequenceIndex + 1;
        beatCounter = beatCounter + self._sequence[sequenceIndex].duration;
    end

    local displayBeatCounter = beatCounter - (self._sequence.meta.displayPosition - 1);

    -- This while loop stops when the target index is reached.
    while (currentButtonIndex ~= targetButtonIndex) and (displayBeatCounter < 8) do

        sequenceIndex = sequenceIndex + 1;
        currentButtonIndex = currentButtonIndex + 1;
        displayBeatCounter = displayBeatCounter + self._sequence[sequenceIndex].duration;
    end

    -- Returns nil if the target button is deactivated.
    if targetButtonIndex == currentButtonIndex then
    
        return sequenceIndex;
    else

        return nil;
    end
end

function ui.GetButtonWidth(self, buttonIndex)

    local sequenceIndex = self:GetSequenceIndex(buttonIndex);
    local preceedingBeats = 0;

    -- If the button is deactivated, nil is returned.
    if sequenceIndex == nil then

        return nil;
    end

    -- This for loop finds the number of beats in the sequence leading up to the note at the
    -- selected sequence index.
    for i = 1, sequenceIndex - 1 do

        preceedingBeats = preceedingBeats + self._sequence[i].duration;
    end

    -- This if statement determines if a note needs to be resized based on the preceeding notes of the
    -- sequence.
    local noteDuration;
    if preceedingBeats < self._sequence.meta.displayPosition - 1 then

        noteDuration = (self._sequence[sequenceIndex].duration + preceedingBeats) - (self._sequence.meta.displayPosition - 1);
    elseif (preceedingBeats + self._sequence[sequenceIndex].duration) > self._sequence.meta.displayPosition + 7 then

        local durationOverLimit = (self._sequence[sequenceIndex].duration + preceedingBeats) - (self._sequence.meta.displayPosition + 7);
        noteDuration = self._sequence[sequenceIndex].duration - durationOverLimit;
    else

        noteDuration = self._sequence[sequenceIndex].duration;
    end

    return ((640 * noteDuration) / 8) - 6;
end

function ui.DisableAll(self)

    self._moveNoteLeft.enabled = false;
    self._moveNoteRight.enabled = false;
    self._consolodateButton.enabled = false;

    self._subdivideButton.visible = true;
    self._subdivideButton.enabled = false;

    self._subdivideMenu.visible = false;
    self._subdivideMenu.enabled = false;
    
    self._noteActive:setValue(false, false);
    self._noteActive.enabled = false;

    self._panBox:setValue(0.0, false);
    self._panBox.enabled = false;

    self._velocityBox:setValue(100, false);
    self._velocityBox.enabled = false;
    
    self._offsetBox:setValue(0, false);
    self._offsetBox.enabled = false;

    for i = 1, 3 do

        if (self._sequence.meta.effectTypes[i] == 2) or (self._sequence.meta.effectTypes[i] == 3) then

            self._filterKnobs[i].active:setValue(false, false);
            self._filterKnobs[i].active.enabled = false;

            self._filterKnobs[i].cutoff:setValue(1000, false);
            self._filterKnobs[i].cutoff.enabled = false;

            self._filterKnobs[i].resonance:setValue(0.0, false);
            self._filterKnobs[i].resonance.enabled = false;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._reverbKnobs[i].active:setValue(false, false);
            self._reverbKnobs[i].active.enabled = false;

            self._reverbKnobs[i].time:setValue(2.0, false);
            self._reverbKnobs[i].time.enabled = false;

            self._reverbKnobs[i].damp:setValue(0.0, false);
            self._reverbKnobs[i].damp.enabled = false;

            self._reverbKnobs[i].mix:setValue(50.0, false);
            self._reverbKnobs[i].mix.enabled = false;
        end
    end

    self._deselectAllButton.enabled = false;
    self._copyButton.enabled = false;
    self._pasteButton.enabled = false;

    self:EnableNavigationButtons();
end

function ui.SetDisplayNote(self, sequenceIndex)

    local displayNote = self._sequence[sequenceIndex];

    self._noteActive:setValue(displayNote.active, false);
    self._noteActive.enabled = true;

    self._panBox:setValue(displayNote.pan, false);
    self._panBox.enabled = true;

    self._velocityBox:setValue(displayNote.velocity, false);
    self._velocityBox.enabled = true;

    self._offsetBox:setValue(displayNote.offset, false);
    self._offsetBox.enabled = true;

    for i = 1, 3 do

        if (self._sequence.meta.effectTypes[i] == 2) or (self._sequence.meta.effectTypes[i] == 3) then

            self._filterKnobs[i].active:setValue(displayNote.effects[i][1], false);
            self._filterKnobs[i].active.enabled = true;

            self._filterKnobs[i].cutoff:setValue(displayNote.effects[i][2], false);
            self._filterKnobs[i].cutoff.enabled = true;

            self._filterKnobs[i].resonance:setValue(displayNote.effects[i][3], false);
            self._filterKnobs[i].resonance.enabled = true;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._reverbKnobs[i].active:setValue(displayNote.effects[i][1], false);
            self._reverbKnobs[i].active.enabled = true;

            self._reverbKnobs[i].time:setValue(displayNote.effects[i][2], false);
            self._reverbKnobs[i].time.enabled = true;

            self._reverbKnobs[i].damp:setValue(displayNote.effects[i][3], false);
            self._reverbKnobs[i].damp.enabled = true;

            self._reverbKnobs[i].mix:setValue(displayNote.effects[i][4], false);
            self._reverbKnobs[i].mix.enabled = true;
        end
    end

    self._subdivideButton.visible = true;

    self._subdivideMenu.visible = false;
    self._subdivideMenu.enabled = false;

    if self._sequence.meta.consolodate then

        self._consolodateButton.enabled = true;
    else

        self._consolodateButton.enabled = false;
    end

    if self._sequence.meta.maxSubdivide == -1 then

        self._subdivideButton.enabled = false;
    else
        
        self._subdivideButton.enabled = true;
    end

    self._moveNoteLeft.enabled = false;
    self._moveNoteRight.enabled = false;
    if self._sequence.meta.consecutive or (#self._sequence.meta.selectedIndices == 1) then

        if self._sequence.meta.selectedIndices[1] ~= 1 then

            self._moveNoteLeft.enabled = true;
        end

        if self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] ~= #self._sequence then

            self._moveNoteRight.enabled = true;
        end
    end

    self._selectAllButton.enabled = true;
    self._deselectAllButton.enabled = true;

    self._copyButton.enabled = true;

    if self._sequence.meta.copiedNote then

        self._pasteButton.enabled = true;
    end

    self:EnableNavigationButtons();
end

function ui.ChangeEffects(self, effectIndex)

    self._pasteButton.enabled = false;
    self._sequence.meta.copiedNote = nil;

    if (self._effectMenus[effectIndex].value == 2) or (self._effectMenus[effectIndex].value == 3) then
        
        self._filterKnobs[effectIndex].active.visible = true;
        self._filterKnobs[effectIndex].cutoff.visible = true;
        self._filterKnobs[effectIndex].resonance.visible = true;

        self._reverbKnobs[effectIndex].active.enabled = false;
        self._reverbKnobs[effectIndex].time.enabled = false;
        self._reverbKnobs[effectIndex].damp.enabled = false;
        self._reverbKnobs[effectIndex].mix.enabled = false;

        self._reverbKnobs[effectIndex].active.visible = false;
        self._reverbKnobs[effectIndex].time.visible = false;
        self._reverbKnobs[effectIndex].damp.visible = false;
        self._reverbKnobs[effectIndex].mix.visible = false;

        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = { false, 1000, 0.0 };
        end

        self._sequence.meta.effectTypes[effectIndex] = self._effectMenus[effectIndex].value;
    elseif self._effectMenus[effectIndex].value == 4 then

        self._reverbKnobs[effectIndex].active.visible = true;
        self._reverbKnobs[effectIndex].time.visible = true;
        self._reverbKnobs[effectIndex].damp.visible = true;
        self._reverbKnobs[effectIndex].mix.visible = true;

        self._filterKnobs[effectIndex].active.enabled = false;
        self._filterKnobs[effectIndex].cutoff.enabled = false;
        self._filterKnobs[effectIndex].resonance.enabled = false;

        self._filterKnobs[effectIndex].active.visible = false;
        self._filterKnobs[effectIndex].cutoff.visible = false;
        self._filterKnobs[effectIndex].resonance.visible = false;

        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = { false, 2.0, 0.0, 50.0 };
        end

        self._sequence.meta.effectTypes[effectIndex] = self._effectMenus[effectIndex].value;
    else

        self._reverbKnobs[effectIndex].active.enabled = false;
        self._reverbKnobs[effectIndex].time.enabled = false;
        self._reverbKnobs[effectIndex].damp.enabled = false;
        self._reverbKnobs[effectIndex].mix.enabled = false;

        self._reverbKnobs[effectIndex].active.visible = false;
        self._reverbKnobs[effectIndex].time.visible = false;
        self._reverbKnobs[effectIndex].damp.visible = false;
        self._reverbKnobs[effectIndex].mix.visible = false

        self._filterKnobs[effectIndex].active.enabled = false;
        self._filterKnobs[effectIndex].cutoff.enabled = false;
        self._filterKnobs[effectIndex].resonance.enabled = false;

        self._filterKnobs[effectIndex].active.visible = false;
        self._filterKnobs[effectIndex].cutoff.visible = false;
        self._filterKnobs[effectIndex].resonance.visible = false;

        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = nil;
        end

        self._sequence.meta.effectTypes[effectIndex] = nil;
    end
end

function ui.UpdateEffects(self, effectIndex, parameterIndex, value)

    for i = 1, #self._sequence.meta.selectedIndices do

        self._sequence[self._sequence.meta.selectedIndices[i]].effects[effectIndex][parameterIndex] = value;
    end
end

function ui.EnableNavigationButtons(self)

    self._leftButtonBig.enabled = false;
    self._leftButtonSmall.enabled = false;
    if self._sequence.meta.displayPosition > 4 then

        self._leftButtonBig.enabled = true;
        self._leftButtonSmall.enabled = true;
    elseif self._sequence.meta.displayPosition > 1 then

        self._leftButtonSmall.enabled = true;
    end

    self._rightButtonBig.enabled = false;
    self._rightButtonSmall.enabled = false;
    if self._sequence.meta.beats >= self._sequence.meta.displayPosition + 11 then
        
        self._rightButtonBig.enabled = true;
        self._rightButtonSmall.enabled = true;
    elseif self._sequence.meta.beats >= self._sequence.meta.displayPosition + 8 then

        self._rightButtonSmall.enabled = true;
    end
end

function ui.CopyNote(self, sequenceIndex)

    local newNote = {
        duration = self._sequence[sequenceIndex].duration,
        active = self._sequence[sequenceIndex].active,
        pan = self._sequence[sequenceIndex].pan,
        velocity = self._sequence[sequenceIndex].velocity,
        offset = self._sequence[sequenceIndex].offset,
        effects = {}
    }

    for i = 1, 3 do

        if (self._sequence.meta.effectTypes[i] == 2) or (self._sequence.meta.effectTypes[i] == 3) then
            
            newNote.effects[i] = {};

            newNote.effects[i][1] = self._sequence[sequenceIndex].effects[i][1];
            newNote.effects[i][2] = self._sequence[sequenceIndex].effects[i][2];
            newNote.effects[i][3] = self._sequence[sequenceIndex].effects[i][3];
        elseif self._sequence.meta.effectTypes[i] == 4 then

            newNote.effects[i] = {};

            newNote.effects[i][1] = self._sequence[sequenceIndex].effects[i][1];
            newNote.effects[i][2] = self._sequence[sequenceIndex].effects[i][2];
            newNote.effects[i][3] = self._sequence[sequenceIndex].effects[i][3];
            newNote.effects[i][4] = self._sequence[sequenceIndex].effects[i][4];
        end
    end

    return newNote;
end

function ui.UpdateSelected(self, key, value)

    for i = 1, #self._sequence.meta.selectedIndices do

        self._sequence[self._sequence.meta.selectedIndices[i]][key] = value;
    end
end

-- After testing, the UVI onSave callback does not work when the sequence metadata feild is defined.
-- Because of this, I have to put the sequence metadata at the end of the saved table.
function ui.Save(self)

    local saveData = {};
    for i = 1, #self._sequence do

        saveData[i] = self._sequence[i];
    end

    saveData[#saveData + 1] = self._sequence.meta;

    return saveData;
end

function ui.Load(self, data)

    for i = 1, #data - 1 do

        self._sequence[i] = data[i];
    end

    self._sequence.meta = data[#data];

    self._sequence.meta.copiedNote = {};

    self._lengthBox:setValue(self._sequence.meta.beats, false);

    if self._sequence.meta.beats == 0 then

        self._startBox:setRange(0, 0)
        self._endBox:setRange(0, 0);

        self._startBox:setValue(0, false);
        self._endBox:setValue(0, false);
    else

        self._startBox:setRange(1, self._sequence.meta.stop);
        self._endBox:setRange(self._sequence.meta.start, self._sequence.meta.beats);

        self._startBox:setValue(self._sequence.meta.start, false);
        self._endBox:setValue(self._sequence.meta.stop, false);
    end

    for i = 1, 3 do

        if self._sequence.meta.effectTypes[i] == 2 then

            self._effectMenus[i]:setValue(2, false);
            self._filterKnobs[i].active.visible = true;
            self._filterKnobs[i].cutoff.visible = true;
            self._filterKnobs[i].resonance.visible = true;
        elseif self._sequence.meta.effectTypes[i] == 3 then

            self._effectMenus[i]:setValue(3, false);
            self._filterKnobs[i].active.visible = true;
            self._filterKnobs[i].cutoff.visible = true;
            self._filterKnobs[i].resonance.visible = true;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._effectMenus[i]:setValue(4, false);
            self._reverbKnobs[i].active.visible = true;
            self._reverbKnobs[i].time.visible = true;
            self._reverbKnobs[i].damp.visible = true;
            self._reverbKnobs[i].mix.visible = true;
        end
    end

    self:UpdateMetadata();
    self:Refresh();
end

return ui;