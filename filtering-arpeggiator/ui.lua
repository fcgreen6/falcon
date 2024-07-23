------------------------------------------------------------------------------------------------------
-- Filtering Arpeggiator User Interface Class
------------------------------------------------------------------------------------------------------

-- This class contains all user interface objects and synth effect objects as data members.

-- Based on the user's input, the user interface class modifies the sequence data member.

-- Sequence Data Member: The sequence object stores the notes of the specified sequence in ascending order. 
-- Each note has a specified duration, boolean on / off value, velocity field, offset field, panning field, 
-- and an effects table. In addition, metadata about the sequence itself can be accessed via the sequence's "meta" field.

------------------------------------------------------------------------------------------------------

ui = {};

-- Creates class data members and defines changed functions.
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
                positionsChanged = false, -- Set to true when the user rearranges notes in the sequence.
                maxSubdivide = -1, -- The largest note a selection can be subdivided into.
                displayNoteIndex = -1, -- Index of the note displayed on the user interface.
                flashNoteIndex = -1, -- Index of the note flashing red when the sequence is playing.
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
    self._displayPanel.backgroundImage = "images/notePanel.png";

    self._beatLabels = {};

    for i = 1, 8 do

        self._beatLabels[i] = Label("beatLabel" .. i);
        self._beatLabels[i].pos = {43 + (80 * (i - 1)), 90};
        self._beatLabels[i].text = " " .. i;
    end

    -- Big left button. Moves the view of the sequence left eight beats.
    self._leftButtonBig = Button("leftButtonBig");
    self._leftButtonBig.pos = {5, 20};
    self._leftButtonBig.height = 57;
    self._leftButtonBig.width = 30;
    self._leftButtonBig.displayName = "<-";

    -- Updates the class sequence object and refreshes the user interface.
    self._leftButtonBig.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition - 4;
        self:Refresh();
    end

    -- Small left button. Moves the view of the sequence left one beat.
    self._leftButtonSmall = Button("leftButtonSmall");
    self._leftButtonSmall.pos = {5, 81};
    self._leftButtonSmall.height = 27;
    self._leftButtonSmall.width = 30;
    self._leftButtonSmall.displayName = "<-";

    -- Updates the class sequence object and refreshes the user interface.
    self._leftButtonSmall.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition - 1;
        self:Refresh();
    end

    -- Big right button. Moves the view of the sequence right eight beats.
    self._rightButtonBig = Button("rightButtonBig");
    self._rightButtonBig.pos = {685, 20};
    self._rightButtonBig.height = 57;
    self._rightButtonBig.width = 30;
    self._rightButtonBig.displayName = "->";

    -- Updates the class sequence object and refreshes the user interface.
    self._rightButtonBig.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition + 4;
        self:Refresh();
    end

    -- Small right button. Moves the view of the sequence right one beat.
    self._rightButtonSmall = Button("rightButtonSmall");
    self._rightButtonSmall.pos = {685, 81};
    self._rightButtonSmall.height = 27;
    self._rightButtonSmall.width = 30;
    self._rightButtonSmall.displayName = "->";

    self._rightButtonSmall.changed = function()

        self._sequence.meta.displayPosition = self._sequence.meta.displayPosition + 1;
        self:Refresh();
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Selection Buttons
    ------------------------------------------------------------------------------------------------------

    self._noteButtons = {};

    -- There are a maximum of thirty two selection buttions that can be displayed at the same time.
    -- Buttons that re not needed to display the sequence are disabled and hidden.
    for i = 1, 32 do

        self._noteButtons[i] = OnOffButton("B" .. i, false);
        self._noteButtons[i].y = 47;
        self._noteButtons[i].height = 30;
        self._noteButtons[i].displayName = " ";
        self._noteButtons[i].backgroundColourOff = "#424242";
        self._noteButtons[i].backgroundColourOn = "#2800ba";
        self._noteButtons[i].enabled = false;
        self._noteButtons[i].visible = false;

        -- Determines if a note button has been selected or deselected. If a new note button
        -- was selected, it is added to the selectedIndices table in the sequence's metadata.
        -- If a note button was deselected, it is removed from selected indices.
        self._noteButtons[i].changed = function()

            -- This for loop determines if a button has been deselected.
            for i = 1, #self._sequence.meta.selectedIndices do

                -- The GetButtonIndex takes a sequence note index as a parameter. If there is a button representing
                -- that note on the user interface, the index of that button is returned.
                local buttonIndex = self:GetButtonIndex(self._sequence.meta.selectedIndices[i]);

                if buttonIndex then

                    -- If the value of the note button at a selected index is false, it means the button at
                    -- that index has been deselected.
                    if self._noteButtons[buttonIndex].value == false then

                        -- If the deselected button represents the note being displayed, this if statement determines
                        -- a new note to be displayed based on selected indices.
                        if self._sequence.meta.selectedIndices[i] == self._sequence.meta.displayNoteIndex then

                            if i == 1 then

                                if self._sequence.meta.selectedIndices[2] then
                                
                                    self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[2];
                                else

                                    self._sequence.meta.displayNoteIndex = -1;
                                end
                            else

                                self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
                            end
                        end

                        -- Remove the changed index from selected indices. Since a note is deselected,
                        -- the UpdateMetadata function is called. Refresh is then called to display the sequence.
                        table.remove(self._sequence.meta.selectedIndices, i);
                        self:UpdateMetadata();
                        self:Refresh();
                        return;
                    end
                end
            end

            -- This loop determines if a new note has been selected.
            for i = 1, 32 do

                -- Checks all depressed buttons.
                if self._noteButtons[i].value then

                    local sequenceIndex = self:GetSequenceIndex(i); -- Finds the index of the depressed button in the sequence.
                    local noMatchFound = true; -- This variable will be set to false if a depressed button is in selected indices.

                    -- Checks all selected indices against the depressed button.
                    for j = 1, #self._sequence.meta.selectedIndices do

                        if sequenceIndex == self._sequence.meta.selectedIndices[j] then

                            noMatchFound = false;
                            break;
                        end
                    end

                    -- If there is no matching index in the selected indices table, the button is added to the selection.
                    if noMatchFound then

                        self._sequence.meta.displayNoteIndex = sequenceIndex;
                        table.insert(self._sequence.meta.selectedIndices, #self._sequence.meta.selectedIndices + 1, sequenceIndex);
                        table.sort(self._sequence.meta.selectedIndices);

                        -- Since a new button is selected, the UpdateMetadata function is called. Refresh is then 
                        -- called to display the sequence.
                        self:UpdateMetadata();
                        self:Refresh();
                        return;
                    end
                end
            end
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
    self._sequencePanel.backgroundColour = "#212121";

    -- Box where the number of beats in the sequence is modified.
    self._lengthBox = NumBox("lengthBox", 0, 0, 32, true);
    self._lengthBox.pos = {118, 171};
    self._lengthBox.height = 34;
    self._lengthBox.width = 144;
    self._lengthBox.displayName = "Sequence Length (Beats)"

    -- Changes the length of the sequence by adding or deleting notes. Deletes and resizes existing
    -- notes to meet length requirements.
    self._lengthBox.changed = function()

        -- Adjusts the values of the sequence start and end boxes to fit within the length.
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

        -- This branch of the if statement executes when the length of the sequence is increased.
        if self._lengthBox.value > self._sequence.meta.beats then

            -- Default note objects are inserted for each newly added beat in the sequence.
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
                        
                        defaultNote.effects[j] = { false, 2.0, 0.0, 0.5 };
                    else

                        defaultNote.effects[j] = nil;
                    end
                end

                -- New notes are inserted at the end of the sequence.
                table.insert(self._sequence, #self._sequence + 1, defaultNote);
            end

        -- This branch of the if statement executes when the length of the sequence is decreased.
        else 

            -- The beat difference variable is set to the number of deleted beats.
            -- Deleted beats counter will be used to record how many beats are deleted after each iteration
            -- of the while loop.
            local beatDifference = self._sequence.meta.beats - self._lengthBox.value;
            local deletedBeatsCounter = 0;

            while deletedBeatsCounter < beatDifference do 
                
                deletedBeatsCounter = deletedBeatsCounter + self._sequence[#self._sequence].duration;
                if deletedBeatsCounter > beatDifference then

                    -- Resizes the last note of the sequence if necessary.
                    self._sequence[#self._sequence].duration = deletedBeatsCounter - beatDifference;
                else

                    -- If the note being deleted is currently selected, it is also removed from the selected indices table.
                    if self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] == #self._sequence then

                        table.remove(self._sequence.meta.selectedIndices);
                    end

                    -- If the note being deleted is currently displayed, the display note index is changed to the first
                    -- note in selectedIndices, if possible.
                    if self._sequence.meta.displayNoteIndex == #self._sequence then

                        if self._sequence.meta.selectedIndices[1] then

                            self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
                        else

                            self._sequence.meta.displayNoteIndex = -1;
                        end
                    end

                    -- Removes the last note in the sequence.
                    table.remove(self._sequence);
                end

                -- Updates the display position of the sequence if it is not possible to display at the current position.
                if (self._sequence.meta.displayPosition > self._lengthBox.value - 7) and (self._sequence.meta.displayPosition ~= 1) then
                    
                    self._sequence.meta.displayPosition = self._lengthBox.value - 7;
                end
            end

            -- Since selected notes can be deleted, the UpdateMetadata function must be called.
            self:UpdateMetadata();
        end

        -- Length of the sequence is updated and the user interface is refreshed.
        self._sequence.meta.beats = self._lengthBox.value;
        self:Refresh();
    end

    -- Button which moves the selected series of notes left in the sequence.
    self._moveNoteLeft = Button("moveNoteLeft");
    self._moveNoteLeft.pos = {46, 171};
    self._moveNoteLeft.height = 34;
    self._moveNoteLeft.width = 46;
    self._moveNoteLeft.displayName = "<-";

    -- Moves a series of consecutive notes left one position in the sequence.
    self._moveNoteLeft.changed = function()

        -- This data member is used by the main script when notes are moved during playback.
        self._sequence.meta.positionsChanged = true;

        -- Copies the note to the left of the selection and removes it.
        local leftNoteCopy = self:CopyNote(self._sequence.meta.selectedIndices[1] - 1);
        table.remove(self._sequence, self._sequence.meta.selectedIndices[1] - 1);

        -- Inserts the note on the opposite side of selected indices.
        table.insert(self._sequence, self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices], leftNoteCopy);

        -- Selected indices are shifted down by one.
        for i = 1, #self._sequence.meta.selectedIndices do

            self._sequence.meta.selectedIndices[i] = self._sequence.meta.selectedIndices[i] - 1;
        end

        -- Display note is shifted down by one.
        self._sequence.meta.displayNoteIndex = self._sequence.meta.displayNoteIndex - 1;
        self:Refresh();
    end

    -- Button which moves the selected series of notes right in the sequence.
    self._moveNoteRight = Button("moveNoteRight");
    self._moveNoteRight.pos = {288, 171}
    self._moveNoteRight.height = 34;
    self._moveNoteRight.width = 46;
    self._moveNoteRight.displayName = "->";

    -- Moves a series of consecutive notes right one position in the sequence.
    self._moveNoteRight.changed = function()

        -- This data member is used by the main script when notes are moved during playback.
        self._sequence.meta.positionsChanged = true;

        -- Copies the note to the right of the selection and removes it.
        local rightNoteCopy = self:CopyNote(self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] + 1);
        table.remove(self._sequence, self._sequence.meta.selectedIndices[#self._sequence.meta.selectedIndices] + 1);

        -- Inserts the note on the opposite side of selected indices.
        table.insert(self._sequence, self._sequence.meta.selectedIndices[1], rightNoteCopy);

        -- Selected indices are shifted up by one.
        for i = 1, #self._sequence.meta.selectedIndices do

            self._sequence.meta.selectedIndices[i] = self._sequence.meta.selectedIndices[i] + 1;
        end

        -- Display note is shifted up by one.
        self._sequence.meta.displayNoteIndex = self._sequence.meta.displayNoteIndex + 1;
        self:Refresh();
    end

    -- Box where the start of the sequence is defined.
    self._startBox = NumBox("startBox", 0, 0, 0, true);
    self._startBox.pos = {46, 211};
    self._startBox.height = 34;
    self._startBox.width = 141;
    self._startBox.displayName = "Sequence Start Beat";

    -- Adjusts the beat that the sequence starts on.
    self._startBox.changed = function()

        -- Changing the start of the sequence also impacts the lower bound of the sequence end box.
        self._sequence.meta.start = self._startBox.value;
        self._endBox:setRange(self._startBox.value, self._sequence.meta.beats);
        self:Refresh();
    end

    -- Box where the end of the sequence is defined.
    self._endBox = NumBox("endBox", 0, 0, 0, true);
    self._endBox.pos = {193, 211};
    self._endBox.height = 34;
    self._endBox.width = 141;
    self._endBox.displayName = "Sequence End Beat";

    -- Adjusts the beat that the sequence ends on.
    self._endBox.changed = function()

        -- Changing the end of the sequence also impacts the upper bound of the sequence start box.
        self._sequence.meta.stop = self._endBox.value;
        self._startBox:setRange(1, self._endBox.value);
        self:Refresh();
    end

    -- Button which will consolodate subdivided notes into a single note.
    self._consolodateButton = Button("consolodateButton");
    self._consolodateButton.pos = {46, 251};
    self._consolodateButton.height = 28;
    self._consolodateButton.width = 141;
    self._consolodateButton.displayName = "Consolodate Notes";

    -- Condolodates a series of consecutive notes into a single note if combined duration is less than two.
    self._consolodateButton.changed = function()

        -- Determines the combined duration of all notes in the selection.
        local combinedDuration = 0;
        for i = 1, #self._sequence.meta.selectedIndices do

            combinedDuration = combinedDuration + self._sequence[self._sequence.meta.selectedIndices[i]].duration;
        end

        -- The consolodated note will become the note currently displayed with a longer duration.
        self._sequence[self._sequence.meta.selectedIndices[1]] = self:CopyNote(self._sequence.meta.displayNoteIndex);

        sequenceRemoveIndex = self._sequence.meta.selectedIndices[2];

        -- Removes all notes from the sequence starting at the second selected index.
        -- Removes all notes from the selection starting at index two.
        while self._sequence.meta.selectedIndices[2] do

            table.remove(self._sequence, sequenceRemoveIndex);
            table.remove(self._sequence.meta.selectedIndices, 2);
        end

        -- The remaining note in the selected indices table becomes the combined duration of the selection.
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
    self._subdivideButton.displayName = "Subdivide Notes"

    -- Replaces the subdivide button with a menu.
    -- Initilizes the values within the subdivide menu.
    self._subdivideButton.changed = function()

        -- Enable subdivide menu.
        self._subdivideButton.enabled = false;
        self._subdivideButton.visible = false;

        -- Disable subdivide button.
        self._subdivideMenu.enabled = true;
        self._subdivideMenu.visible = true;

        -- Clear menu elements.
        self._subdivideMenu:setValue(1, false);
        self._subdivideMenu:clear();

        -- If the subdivide menu is activated, 1/4 beat subdivision is always available.
        self._subdivideMenu:addItem("--Select Subdivision--")
        self._subdivideMenu:addItem("1/4 Beats");

        -- Determine if 1/2 beat subdivision is available.
        if self._sequence.meta.maxSubdivide >= 0.5 then

            self._subdivideMenu:addItem("1/2 Beats");
        end

        -- Determine if the selection can be divided into beats.
        if self._sequence.meta.maxSubdivide == 1.0 then

            self._subdivideMenu:addItem("Beats");
        end
    end

    -- Menu used to select how notes are subdivided.
    self._subdivideMenu = Menu("subdivideMenu", {});
    self._subdivideMenu.pos = {193, 251}
    self._subdivideMenu.height = 28;
    self._subdivideMenu.width = 141;
    self._subdivideMenu.showLabel = false;
    self._subdivideMenu.enabled = false;
    self._subdivideMenu.visible = false;

    -- Divides a selection of similar notes into even segments.
    self._subdivideMenu.changed = function()

        -- Gets the length of subdivided notes from the subdivide menu.
        local subdivisionRatio;
        if self._subdivideMenu.value == 2 then

            subdivisionRatio = 0.25;
        elseif self._subdivideMenu.value == 3 then

            subdivisionRatio = 0.5;
        else

            subdivisionRatio = 1;
        end

        -- Visits all selected indices and divides the notes at those indices.
        local i = 1;
        while i <= #self._sequence.meta.selectedIndices do

            local selectedIndex = self._sequence.meta.selectedIndices[i];
            local numSubdivisions = self._sequence[selectedIndex].duration / subdivisionRatio;

            -- Resises the length of the note at the selected index to the subdivision ratio.
            self._sequence[selectedIndex].duration = subdivisionRatio;
            for j = 1, numSubdivisions - 1 do

                -- Note copies are inserted until the correct number of subdivisions is reached.
                table.insert(self._sequence, selectedIndex, self:CopyNote(selectedIndex));
                table.insert(self._sequence.meta.selectedIndices, i + j, selectedIndex + j);
            end

            -- The selected notes after the subdivided note must have their indices shifted according
            -- to the number of added noted.
            for j = i + numSubdivisions, #self._sequence.meta.selectedIndices do 

                self._sequence.meta.selectedIndices[j] = self._sequence.meta.selectedIndices[j] + numSubdivisions - 1;
            end

            -- i is shifted according to the number of added notes.
            i = i + numSubdivisions;
        end

        -- The display note is set to the first note in the selected indices table.
        self._sequence.meta.displayNoteIndex = self._sequence.meta.selectedIndices[1];
        self:UpdateMetadata();
        self:Refresh();
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Modification Panel
    ------------------------------------------------------------------------------------------------------

    -- Panel which note modification elements are displayed on.
    self._notePanel = Panel("notePanel");
    self._notePanel.pos = {380, 165};
    self._notePanel.height = 120;
    self._notePanel.width = 300;
    self._notePanel.backgroundColour = "#212121";

    -- Box which controls the panning of notes in the sequence.
    self._panBox = NumBox("panBox", 0.0, -1.0, 1.0, false);
    self._panBox.pos = {480, 171};
    self._panBox.height = 54;
    self._panBox.width = 94;
    self._panBox.displayName = "Note Pan";

    -- Calls the UpdateSelected function to update the pan of all selected notes.
    self._panBox.changed = function()

        self:UpdateSelected("pan", self._panBox.value);
    end

    -- Box which controls the velocity of notes in the sequence.
    self._velocityBox = NumBox("velocityBox", 100, 0, 127, true);
    self._velocityBox.pos = {580, 171};
    self._velocityBox.height = 54;
    self._velocityBox.width = 94;
    self._velocityBox.displayName = "Note Velocity";

    -- Calls the UpdateSelected function to update the velocity of all selected notes.
    self._velocityBox.changed = function()

        self:UpdateSelected("velocity", self._velocityBox.value);
    end

    -- Box which controls the offset of notes in the sequence.
    self._offsetBox = NumBox("offsetBox", 0, -24, 24, true);
    self._offsetBox.pos = {480, 231};
    self._offsetBox.height = 48;
    self._offsetBox.width = 194;
    self._offsetBox.displayName = "Note Offset";

    -- Calls the UpdateSelected function to update the offset of all selected notes.
    self._offsetBox.changed = function()

        self:UpdateSelected("offset", self._offsetBox.value);
    end

    -- Box which controls if notes in the sequence are on or off.
    self._noteActive = OnOffButton("noteActive", false);
    self._noteActive.pos = {386, 171};
    self._noteActive.height = 108;
    self._noteActive.width = 88;
    self._noteActive.alpha = 0.5;
    self._noteActive.normalImage = "images/bigButtonOn.png";
    self._noteActive.pressedImage = "images/bigButtonOff.png";
    self._noteActive.overImage = "images/bigButtonOnOver.png";
    self._noteActive.overPressedImage = "images/bigButtonOffOver.png";

    -- Calls the UpdateSelected function to update the bypass value of all selected notes.
    self._noteActive.changed = function()

        self:UpdateSelected("active", self._noteActive.value);
    end

    ------------------------------------------------------------------------------------------------------
    -- Note Effects Area
    ------------------------------------------------------------------------------------------------------

    self._effectPanels = {}; -- Table which holds all effect panels.
    self._effectMenus = {}; -- Table which holds all effect menus.
    self._filterKnobs = {}; -- Table which holds all filter knobs.
    self._reverbKnobs = {}; -- Table which holds all reverb knobs.

    self._filterLabels = {};
    self._reverbLabels = {};

    for i = 1, 3 do

        -- Create effect panels.
        self._effectPanels[i] = Panel("effectPanels" .. i);
        self._effectPanels[i].pos = {40, 305 + (55 * (i - 1))};
        self._effectPanels[i].height = 45;
        self._effectPanels[i].width = 640;
        self._effectPanels[i].backgroundColour = "#212121";

        -- Create effect menus.
        self._effectMenus[i] = Menu("effectMenus" .. i, 
        {"--Select Effect--",
        "High Pass Filter", 
        "Low Pass Filter",
        "Reverb"});
        self._effectMenus[i].pos = {43, 318 + (55 * (i - 1))};
        self._effectMenus[i].height = 20;
        self._effectMenus[i].width = 100;
        self._effectMenus[i].showLabel = false;

        -- Each index in the filter knobs table will hold different knobs relating to filter parameters.
        self._filterKnobs[i] = {};
        self._filterLabels[i] = {};

        -- The active field represents the filter bypass button for each effect panel.
        self._filterKnobs[i].active = OnOffButton("filterOn" .. i, false);
        self._filterKnobs[i].active.pos = {175, 313 + (55 * (i - 1))};
        self._filterKnobs[i].active.height = 30;
        self._filterKnobs[i].active.width = 30;
        self._filterKnobs[i].active.enabled = false;
        self._filterKnobs[i].active.visible = false;
        self._filterKnobs[i].active.alpha = 0.25;
        self._filterKnobs[i].active.normalImage = "images/buttonOn.png";
        self._filterKnobs[i].active.pressedImage = "images/buttonOff.png";
        self._filterKnobs[i].active.overImage = "images/buttonOnOver.png";
        self._filterKnobs[i].active.overPressedImage = "images/buttonOffOver.png";

        -- The cutoff field represents the filter cutoff for each effect panel.
        self._filterKnobs[i].cutoff = Knob{"cutoff" .. i, 1000.0, 20.0, 20000.0, false, mapper = Mapper.Exponential};
        self._filterKnobs[i].cutoff.pos = {324, 313 + (55 * (i - 1))};
        self._filterKnobs[i].cutoff.height = 30;
        self._filterKnobs[i].cutoff.width = 30;
        self._filterKnobs[i].cutoff.enabled = false;
        self._filterKnobs[i].cutoff.visible = false;

        self._filterLabels[i].cutoff = Label("cuttoffLabel" .. i);
        self._filterLabels[i].cutoff.pos = {270, 309 + (55 * (i - 1))};
        self._filterLabels[i].cutoff.width = 40;
        self._filterLabels[i].cutoff.height = 40;
        self._filterLabels[i].cutoff.text = "Cutoff";
        self._filterLabels[i].cutoff.visible = false;

        -- The resonance field represents the filter resonance for each effect panel.
        self._filterKnobs[i].resonance = Knob{"resonance" .. i, 0.0, 0.0, 1.0, false};
        self._filterKnobs[i].resonance.pos = {473, 313 + (55 * (i - 1))};
        self._filterKnobs[i].resonance.height = 30;
        self._filterKnobs[i].resonance.width = 30;
        self._filterKnobs[i].resonance.enabled = false;
        self._filterKnobs[i].resonance.visible = false;

        self._filterLabels[i].resonance = Label("resonanceLabel" .. i);
        self._filterLabels[i].resonance.pos = {400, 309 + (55 * (i - 1))};
        self._filterLabels[i].resonance.width = 75;
        self._filterLabels[i].resonance.height = 40;
        self._filterLabels[i].resonance.text = "Resonance";
        self._filterLabels[i].resonance.visible = false;

        self._reverbKnobs[i] = {};
        self._reverbLabels[i] = {};

        -- The active field represents the reverb bypass button for each effect panel.
        self._reverbKnobs[i].active = OnOffButton("reverbOn" .. i, false);
        self._reverbKnobs[i].active.pos = {175, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].active.height = 30;
        self._reverbKnobs[i].active.width = 30;
        self._reverbKnobs[i].active.enabled = false;
        self._reverbKnobs[i].active.visible = false;
        self._reverbKnobs[i].active.alpha = 0.25;
        self._reverbKnobs[i].active.normalImage = "images/buttonOn.png";
        self._reverbKnobs[i].active.pressedImage = "images/buttonOff.png";
        self._reverbKnobs[i].active.overImage = "images/buttonOnOver.png";
        self._reverbKnobs[i].active.overPressedImage = "images/buttonOffOver.png";

        -- The time field represents the reverb time knob for each effect panel.
        self._reverbKnobs[i].time = Knob{"time" .. i, 0.0, 0.0, 10.0, false};
        self._reverbKnobs[i].time.pos = {324, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].time.height = 30;
        self._reverbKnobs[i].time.width = 30;
        self._reverbKnobs[i].time.enabled = false;
        self._reverbKnobs[i].time.visible = false;

        self._reverbLabels[i].time = Label("timeLabel" .. i);
        self._reverbLabels[i].time.pos = {275, 309 + (55 * (i - 1))};
        self._reverbLabels[i].time.width = 40;
        self._reverbLabels[i].time.height = 40;
        self._reverbLabels[i].time.text = "Time";
        self._reverbLabels[i].time.visible = false;

        -- The damp field represents the reverb damp knob for each effect panel.
        self._reverbKnobs[i].damp = Knob{"damp" .. i, 0.0, 0.0, 1.0, false};
        self._reverbKnobs[i].damp.pos = {473, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].damp.height = 30;
        self._reverbKnobs[i].damp.width = 30;
        self._reverbKnobs[i].damp.enabled = false;
        self._reverbKnobs[i].damp.visible = false;

        self._reverbLabels[i].damp = Label("dampLabel" .. i);
        self._reverbLabels[i].damp.pos = {425, 309 + (55 * (i - 1))};
        self._reverbLabels[i].damp.width = 40;
        self._reverbLabels[i].damp.height = 40;
        self._reverbLabels[i].damp.text = "Damp";
        self._reverbLabels[i].damp.visible = false;

        -- The mix field represents the reverb mix knob for each effect panel.
        self._reverbKnobs[i].mix = Knob{"mix" .. i, 0.0, 0.0, 1.0, false};
        self._reverbKnobs[i].mix.pos = {622, 313 + (55 * (i - 1))};
        self._reverbKnobs[i].mix.height = 30;
        self._reverbKnobs[i].mix.width = 30;
        self._reverbKnobs[i].mix.enabled = false;
        self._reverbKnobs[i].mix.visible = false;

        self._reverbLabels[i].mix = Label("mixLabel" .. i);
        self._reverbLabels[i].mix.pos = {586, 309 + (55 * (i - 1))};
        self._reverbLabels[i].mix.width = 40;
        self._reverbLabels[i].mix.height = 40;
        self._reverbLabels[i].mix.text = "Mix";
        self._reverbLabels[i].mix.visible = false;
    end

    -- The effect menu changed functions each manipulate the ChangeEffects function.
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

    -- The filter and reverb knob changed functions all manipulate the UpdateEffects function. 
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

    -- Button which selects all notes in the sequence,
    self._selectAllButton = Button("selectAllButton");
    self._selectAllButton.pos = {223, 113};
    self._selectAllButton.height = 20;
    self._selectAllButton.width = 134;
    self._selectAllButton.displayName = "Select All";

    -- This function adds all notes to the selected indices array and refreshes the user interface.
    self._selectAllButton.changed = function()

        self._sequence.meta.selectedIndices = {};

        for i = 1, #self._sequence do

            table.insert(self._sequence.meta.selectedIndices, i, i);
        end

        -- If no note is displayed, the first available index is displayed.
        if self._sequence.meta.displayNoteIndex == -1 then 

            self._sequence.meta.displayNoteIndex = 1;
        end

        self:UpdateMetadata();
        self:Refresh();
    end

    -- Button which deselects all selected notes.
    self._deselectAllButton = Button("deselectAllButton");
    self._deselectAllButton.pos = {363, 113};
    self._deselectAllButton.height = 20;
    self._deselectAllButton.width = 134;
    self._deselectAllButton.displayName = "Deselect All";

    -- Resets the selected indices table and display note. Refreshes the user interface.
    self._deselectAllButton.changed = function()

        self._sequence.meta.selectedIndices = {};
        self._sequence.meta.displayNoteIndex = -1;

        self:UpdateMetadata();
        self:Refresh();
    end

    -- Button which copies the note displayed by the user interface.
    self._copyButton = Button("copyButton");
    self._copyButton.pos = {345, 255}; -- 345
    self._copyButton.height = 30;
    self._copyButton.width = 30;
    self._copyButton.normalImage = "images/copyButton.png";
    self._copyButton.overImage = "images/copyButtonPressed.png";
    self._copyButton.pressedImage = "images/copyButtonPressed.png";

    -- Enables the paste button and stores the copied note in a data member.
    self._copyButton.changed = function()

        self._pasteButton.enabled = true;
        self._pasteButton.alpha = 1.0;

        self._sequence.meta.copiedNote = self:CopyNote(self._sequence.meta.displayNoteIndex);
    end

    -- Button which pastes a copied note to all selected notes.
    self._pasteButton = Button("pasteButton");
    self._pasteButton.pos = {345, 220};
    self._pasteButton.height = 30;
    self._pasteButton.width = 30;
    self._pasteButton.alpha = 0.5;
    self._pasteButton.normalImage = "images/pasteButton.png";
    self._pasteButton.overImage = "images/pasteButtonPressed.png";
    self._pasteButton.pressedImage = "images/pasteButtonPressed.png";

    -- Ignoring the duration of the copied note, pastes a copied note to all selected indices.
    self._pasteButton.changed = function()

        for i = 1, #self._sequence.meta.selectedIndices do

            local currentDuration = self._sequence[self._sequence.meta.selectedIndices[i]].duration;

            self._sequence[self._sequence.meta.selectedIndices[i]] = self._sequence.meta.copiedNote;
            self._sequence[self._sequence.meta.selectedIndices[i]].duration = currentDuration;
        end

        self:Refresh();
    end

    -- User interface is refreshed in case there is no saved data.
    self:Refresh();
end

------------------------------------------------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------------------------------------------------

-- Function which updates the concecutive, consolodate, and maxSubdivide fields within the sequence
-- metadata. This function should be called whenever selected notes change in any way.
function ui.UpdateMetadata(self)

    local firstSelectedIndex = self._sequence.meta.selectedIndices[1];

    if firstSelectedIndex == nil then

        self._sequence.meta.consecutive = false;
        self._sequence.meta.consolodate = false;
        self._sequence.meta.maxSubdivide = -1;
        return;
    end

    self._sequence.meta.consecutive = false;
    if #self._sequence.meta.selectedIndices > 1 then
        
        -- The while loop checks that all values in the selected indices table increment by one.
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
    elseif (smallestNoteDuration == 0.5) or (smallestNoteDuration == 0.75) then

        self._sequence.meta.maxSubdivide = 0.25;
    else

        self._sequence.meta.maxSubdivide = -1;
    end
end

-- Function which visually displays the notes of the sequence. 
function ui.Refresh(self)
    
    -- Sets the text of beat labels depending on sequence position.
    for i = 1, 8 do

        self._beatLabels[i].text = " " .. self._sequence.meta.displayPosition + i - 1;
    end

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
        self:EnableNavigationButtons();
        return;
    end

    i = 1;
    local currentButtonWidth = self:GetButtonWidth(1);
    local buttonPosition = 40;

    -- Uses the GetButtonWidth function to correctly size all buttons displayed on the user interface.
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

        -- Sets buttons as selected based on the selected indices array.
        for j = 1, #self._sequence.meta.selectedIndices do

            local selectedButtonIndex = self:GetButtonIndex(self._sequence.meta.selectedIndices[j]);

            if selectedButtonIndex then

                self._noteButtons[selectedButtonIndex]:setValue(true, false);
            end
        end
    else

        -- Disables all elements if there are no selected indices.
        self._selectAllButton.enabled = true;
        self:DisableAll();
        self:EnableNavigationButtons();
        return;
    end

    -- Sets the values of all elements based on the note being displayed.
    self:SetDisplayNote(self._sequence.meta.displayNoteIndex);
    self:EnableNavigationButtons();
end

-- Converts a sequence index into the coresponding index in the noteButtons table if it exists.
-- Returns the coresponding sequence index if it exists. Returns nil otherwise.
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

-- Converts a button index into the coresponding index in the sequence table.
-- Returns the coresponding sequence index if it exists. Returns nil if the button is deactivated or
-- the sequence index does not exist.
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

-- Returns the width in pixels of a button at a given index.
-- Returns nil if that button is deactivated.
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

        -- Resize at start of sequence.
        noteDuration = (self._sequence[sequenceIndex].duration + preceedingBeats) - (self._sequence.meta.displayPosition - 1);
    elseif (preceedingBeats + self._sequence[sequenceIndex].duration) > self._sequence.meta.displayPosition + 7 then

        -- Resize at end of sequence.
        local durationOverLimit = (self._sequence[sequenceIndex].duration + preceedingBeats) - (self._sequence.meta.displayPosition + 7);
        noteDuration = self._sequence[sequenceIndex].duration - durationOverLimit;
    else

        noteDuration = self._sequence[sequenceIndex].duration;
    end

    -- Display width of 640 pixels. Each button has a margin of six.
    return ((640 * noteDuration) / 8) - 6;
end

-- Disables most elements. This function is called when no notes are selected or there are
-- no notes in the sequence.
function ui.DisableAll(self)

    -- Set values...
    self._moveNoteLeft.enabled = false;
    self._moveNoteRight.enabled = false;
    self._consolodateButton.enabled = false;

    self._subdivideButton.visible = true;
    self._subdivideButton.enabled = false;

    self._subdivideMenu.visible = false;
    self._subdivideMenu.enabled = false;
    
    self._noteActive:setValue(false, false);
    self._noteActive.enabled = false;
    self._noteActive.alpha = 0.25;

    self._panBox:setValue(0.0, false);
    self._panBox.enabled = false;

    self._velocityBox:setValue(100, false);
    self._velocityBox.enabled = false;
    
    self._offsetBox:setValue(0, false);
    self._offsetBox.enabled = false;

    -- Effects are disabled based on their visibility to the user.
    for i = 1, 3 do

        if (self._sequence.meta.effectTypes[i] == 2) or (self._sequence.meta.effectTypes[i] == 3) then

            self._filterKnobs[i].active:setValue(false, false);
            self._filterKnobs[i].active.enabled = false;
            self._filterKnobs[i].active.alpha = 0.25;

            self._filterKnobs[i].cutoff:setValue(1000, false);
            self._filterKnobs[i].cutoff.enabled = false;

            self._filterLabels[i].cutoff.alpha = 0.5;

            self._filterKnobs[i].resonance:setValue(0.0, false);
            self._filterKnobs[i].resonance.enabled = false;

            self._filterLabels[i].resonance.alpha = 0.5;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._reverbKnobs[i].active:setValue(false, false);
            self._reverbKnobs[i].active.enabled = false;
            self._reverbKnobs[i].active.alpha = 0.25;

            self._reverbKnobs[i].time:setValue(2.0, false);
            self._reverbKnobs[i].time.enabled = false;

            self._reverbLabels[i].time.alpha = 0.5;

            self._reverbKnobs[i].damp:setValue(0.0, false);
            self._reverbKnobs[i].damp.enabled = false;

            self._reverbLabels[i].damp.alpha = 0.5;

            self._reverbKnobs[i].mix:setValue(0.5, false);
            self._reverbKnobs[i].mix.enabled = false;

            self._reverbLabels[i].mix.alpha = 0.5;
        end
    end

    self._deselectAllButton.enabled = false;

    self._copyButton.enabled = false;
    self._copyButton.alpha = 0.5;

    self._pasteButton.enabled = false;
    self._pasteButton.alpha = 0.5;
end

-- Initalises all elements to the note at the specified index.
function ui.SetDisplayNote(self, sequenceIndex)

    -- Set values...
    local displayNote = self._sequence[sequenceIndex];

    self._noteActive:setValue(displayNote.active, false);
    self._noteActive.enabled = true;
    self._noteActive.alpha = 1.0;

    self._panBox:setValue(displayNote.pan, false);
    self._panBox.enabled = true;

    self._velocityBox:setValue(displayNote.velocity, false);
    self._velocityBox.enabled = true;

    self._offsetBox:setValue(displayNote.offset, false);
    self._offsetBox.enabled = true;

    -- Effects are enabled based on their visibility to the user.
    for i = 1, 3 do

        if (self._sequence.meta.effectTypes[i] == 2) or (self._sequence.meta.effectTypes[i] == 3) then

            self._filterKnobs[i].active:setValue(displayNote.effects[i][1], false);
            self._filterKnobs[i].active.enabled = true;
            self._filterKnobs[i].active.alpha = 1.0;

            self._filterKnobs[i].cutoff:setValue(displayNote.effects[i][2], false);
            self._filterKnobs[i].cutoff.enabled = true;

            self._filterLabels[i].cutoff.alpha = 1.0;

            self._filterKnobs[i].resonance:setValue(displayNote.effects[i][3], false);
            self._filterKnobs[i].resonance.enabled = true;

            self._filterLabels[i].resonance.alpha = 1.0;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._reverbKnobs[i].active:setValue(displayNote.effects[i][1], false);
            self._reverbKnobs[i].active.enabled = true;
            self._reverbKnobs[i].active.alpha = 1.0;

            self._reverbKnobs[i].time:setValue(displayNote.effects[i][2], false);
            self._reverbKnobs[i].time.enabled = true;

            self._reverbLabels[i].time.alpha = 1.0;

            self._reverbKnobs[i].damp:setValue(displayNote.effects[i][3], false);
            self._reverbKnobs[i].damp.enabled = true;

            self._reverbLabels[i].damp.alpha = 1.0;

            self._reverbKnobs[i].mix:setValue(displayNote.effects[i][4], false);
            self._reverbKnobs[i].mix.enabled = true;

            self._reverbLabels[i].mix.alpha = 1.0;
        end
    end

    -- Disable subdivide menu and enable subdivide button.
    self._subdivideButton.visible = true;
    self._subdivideMenu.visible = false;
    self._subdivideMenu.enabled = false;

    -- Determine if consolodate button is enabled.
    if self._sequence.meta.consolodate then

        self._consolodateButton.enabled = true;
    else

        self._consolodateButton.enabled = false;
    end

    -- Determine if subdivide button is enabled.
    if self._sequence.meta.maxSubdivide == -1 then

        self._subdivideButton.enabled = false;
    else
        
        self._subdivideButton.enabled = true;
    end

    -- Determine if the move note buttons are enabled.
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
    self._copyButton.alpha = 1.0;

    -- Determine if the paste button is enabled.
    if self._sequence.meta.copiedNote then

        self._pasteButton.enabled = true;
        self._pasteButton.alpha = 1.0;
    end
end

-- Changes the effects displayed on a particular effect panel index.
function ui.ChangeEffects(self, effectIndex)

    self._pasteButton.enabled = false;
    self._sequence.meta.copiedNote = nil;

    -- This if statement determines how the displayed effects were changed.
    if (self._effectMenus[effectIndex].value == 2) or (self._effectMenus[effectIndex].value == 3) then
        
        -- Set values...
        self._filterKnobs[effectIndex].active.visible = true;
        self._filterKnobs[effectIndex].cutoff.visible = true;
        self._filterKnobs[effectIndex].resonance.visible = true;

        self._filterLabels[effectIndex].cutoff.visible = true;
        self._filterLabels[effectIndex].resonance.visible = true;

        self._reverbKnobs[effectIndex].active.enabled = false;
        self._reverbKnobs[effectIndex].time.enabled = false;
        self._reverbKnobs[effectIndex].damp.enabled = false;
        self._reverbKnobs[effectIndex].mix.enabled = false;

        self._reverbKnobs[effectIndex].active.visible = false;
        self._reverbKnobs[effectIndex].time.visible = false;
        self._reverbKnobs[effectIndex].damp.visible = false;
        self._reverbKnobs[effectIndex].mix.visible = false;

        self._reverbLabels[effectIndex].time.visible = false;
        self._reverbLabels[effectIndex].damp.visible = false;
        self._reverbLabels[effectIndex].mix.visible = false;

        -- Initialize all notes to the default effect settings.
        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = { false, 1000, 0.0 };
        end

        self._sequence.meta.effectTypes[effectIndex] = self._effectMenus[effectIndex].value;
    elseif self._effectMenus[effectIndex].value == 4 then

        -- Set values...
        self._reverbKnobs[effectIndex].active.visible = true;
        self._reverbKnobs[effectIndex].time.visible = true;
        self._reverbKnobs[effectIndex].damp.visible = true;
        self._reverbKnobs[effectIndex].mix.visible = true;

        self._reverbLabels[effectIndex].time.visible = true;
        self._reverbLabels[effectIndex].damp.visible = true;
        self._reverbLabels[effectIndex].mix.visible = true;

        self._filterKnobs[effectIndex].active.enabled = false;
        self._filterKnobs[effectIndex].cutoff.enabled = false;
        self._filterKnobs[effectIndex].resonance.enabled = false;

        self._filterKnobs[effectIndex].active.visible = false;
        self._filterKnobs[effectIndex].cutoff.visible = false;
        self._filterKnobs[effectIndex].resonance.visible = false;

        self._filterLabels[effectIndex].cutoff.visible = false;
        self._filterLabels[effectIndex].resonance.visible = false;

        -- Initialize all notes to the default effect settings.
        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = { false, 2.0, 0.0, 0.5 };
        end

        self._sequence.meta.effectTypes[effectIndex] = self._effectMenus[effectIndex].value;
    else

        -- Set values...
        self._reverbKnobs[effectIndex].active.enabled = false;
        self._reverbKnobs[effectIndex].time.enabled = false;
        self._reverbKnobs[effectIndex].damp.enabled = false;
        self._reverbKnobs[effectIndex].mix.enabled = false;

        self._reverbKnobs[effectIndex].active.visible = false;
        self._reverbKnobs[effectIndex].time.visible = false;
        self._reverbKnobs[effectIndex].damp.visible = false;
        self._reverbKnobs[effectIndex].mix.visible = false;

        self._reverbLabels[effectIndex].time.visible = false;
        self._reverbLabels[effectIndex].damp.visible = false;
        self._reverbLabels[effectIndex].mix.visible = false;

        self._filterKnobs[effectIndex].active.enabled = false;
        self._filterKnobs[effectIndex].cutoff.enabled = false;
        self._filterKnobs[effectIndex].resonance.enabled = false;

        self._filterKnobs[effectIndex].active.visible = false;
        self._filterKnobs[effectIndex].cutoff.visible = false;
        self._filterKnobs[effectIndex].resonance.visible = false;

        self._filterLabels[effectIndex].cutoff.visible = false;
        self._filterLabels[effectIndex].resonance.visible = false;

        -- Initialize all notes to no effect settings.
        for i = 1, #self._sequence do

            self._sequence[i].effects[effectIndex] = nil;
        end

        self._sequence.meta.effectTypes[effectIndex] = nil;
    end
end

-- Iterates through all selected notes in the sequence and updates the given effect.
function ui.UpdateEffects(self, effectIndex, parameterIndex, value)

    for i = 1, #self._sequence.meta.selectedIndices do

        self._sequence[self._sequence.meta.selectedIndices[i]].effects[effectIndex][parameterIndex] = value;
    end
end

-- Determines if navigation buttons should be enabled or disabled based on the sequence display position.
function ui.EnableNavigationButtons(self)

    -- Display position corresponds to the number of the first beat displayed by the user interface.
    self._leftButtonBig.enabled = false;
    self._leftButtonSmall.enabled = false;
    if self._sequence.meta.displayPosition > 4 then -- If the first beat is greater than four, the view can move left four.

        self._leftButtonBig.enabled = true;
        self._leftButtonSmall.enabled = true;
    elseif self._sequence.meta.displayPosition > 1 then -- if the first beat is greater than one, the view can move left one.

        self._leftButtonSmall.enabled = true;
    end

    self._rightButtonBig.enabled = false;
    self._rightButtonSmall.enabled = false;

    -- The display position must be eleven beats smaller than the total number of beats to move right four beats.
    if self._sequence.meta.beats >= self._sequence.meta.displayPosition + 11 then
        
        self._rightButtonBig.enabled = true;
        self._rightButtonSmall.enabled = true;
    
    -- The display position must be eight beats smaller than the total number of beats to move right one beat.
    elseif self._sequence.meta.beats >= self._sequence.meta.displayPosition + 8 then

        self._rightButtonSmall.enabled = true;
    end
end

-- Creates and returns a copy of a note at a selected index in the sequence.
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

-- Applies specified changes to all selected indices.
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

    -- This for loop undoes the process used in the Save function.
    for i = 1, #data - 1 do

        self._sequence[i] = data[i];
    end

    self._sequence.meta = data[#data];

    -- Upon reload, the copied note is not saved.
    self._sequence.meta.copiedNote = {};

    -- All elements are initialized based on saved data.
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

            self._filterLabels[i].cutoff.visible = true;
            self._filterLabels[i].resonance.visible = true;
        elseif self._sequence.meta.effectTypes[i] == 3 then

            self._effectMenus[i]:setValue(3, false);
            self._filterKnobs[i].active.visible = true;
            self._filterKnobs[i].cutoff.visible = true;
            self._filterKnobs[i].resonance.visible = true;

            self._filterLabels[i].cutoff.visible = true;
            self._filterLabels[i].resonance.visible = true;
        elseif self._sequence.meta.effectTypes[i] == 4 then

            self._effectMenus[i]:setValue(4, false);
            self._reverbKnobs[i].active.visible = true;
            self._reverbKnobs[i].time.visible = true;
            self._reverbKnobs[i].damp.visible = true;
            self._reverbKnobs[i].mix.visible = true;

            self._reverbLabels[i].time.visible = true;
            self._reverbLabels[i].damp.visible = true;
            self._reverbLabels[i].mix.visible = true;
        end
    end

    self:UpdateMetadata();
    self:Refresh();
end

-- Turns a note to red when it is being played.
function ui.FlashOn(self, sequenceIndex)

    local buttonIndex = self:GetButtonIndex(sequenceIndex);

    if buttonIndex then

        self._sequence.meta.flashNoteIndex = sequenceIndex;

        self._noteButtons[buttonIndex].backgroundColourOn = "#ff0000";
        self._noteButtons[buttonIndex].backgroundColourOff = "#ff0000";
    else

        self._sequence.meta.flashNoteIndex = -1;
    end
end

-- Resets a note to default colors.
function ui.FlashOff(self)

    if self._sequence.meta.flashNoteIndex ~= -1 then

        local buttonIndex = self:GetButtonIndex(self._sequence.meta.flashNoteIndex);

        self._noteButtons[buttonIndex].backgroundColourOff = "#424242";
        self._noteButtons[buttonIndex].backgroundColourOn = "#2800ba";

        self._sequence.meta.flashNoteIndex = -1;
    end
end

return ui;