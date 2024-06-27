-- Using the ui module:
------------------------------------------------------------------------------------------------------

-- The module constructor is the CreateUserInterface function. This function creates the user interface
-- and initializes all data members listed bellow. 

-- This module contains data which must be saved by the main script. To do this, call the Save function 
-- within the main script to receive a table of values to be saved. Using the Load function, the main script
-- can resend the saved table.

------------------------------------------------------------------------------------------------------

-- ui module data members:
------------------------------------------------------------------------------------------------------

-- oscillators: Table of objects which represent oscillators within the program.

-- gainKnobs: Table of objects which represent gain knobs on the user interface. These knobs are connected
-- to the gain of each oscillator.

-- menu: Object which represents the ratio menu on the user interface.

-- ratio: Data member which contains the value of menu. This can be used within the main script to manually
-- create sequences.

-- lowPass: Object which represents the program's low pass filter.

-- lowPassKnob: Object which represents the knob on the user interface connected to the low pass filter.

-- highPass: Object which represents the program's high pass filter.

-- highPassKnob: Object which represents the knob on the user interface connected to the high pass filter.

------------------------------------------------------------------------------------------------------

ui = {};

function ui.CreateUserInterface(self)
    
    setSize(720, 480);
    makePerformanceView();

    ------------------------------------------------------------------------------------------------------
    -- Oscilators
    ------------------------------------------------------------------------------------------------------

    self.oscillators = {};

    -- Create table of program oscillators.
    for i = 1, 5 do

        self.oscillators[i] = Program.layers[i].keygroups[1].oscillators[1];
    end

    ------------------------------------------------------------------------------------------------------
    -- Oscilator Knobs
    ------------------------------------------------------------------------------------------------------

    self.gainKnobs = {};

    -- Create table of gain knobs which control oscilators.
    for i = 1, 5 do
        
        self.gainKnobs[i] = Knob("gain" .. i, 1.0, 0.0, 1.5);
        self.gainKnobs[i].size = {50, 50};
        self.gainKnobs[i].position = {115 * i, 420};

        -- The value of the knob is saved within the program and does not need to be retreived
        -- using the save function.
        self.gainKnobs[i]:setValue(self.oscillators[i]:getParameter("Gain"));

        -- Labels for knobs.
        local knobLabel = Label("Gain " .. i);
        knobLabel.size = {50, 25};
        knobLabel.position = {(115 * i) + 3, 390};
    end

    -- Callback functions for gain knobs. Oscillator one.
    self.gainKnobs[1].changed = function()
        
        self.oscillators[1]:setParameter("Gain", self.gainKnobs[1].value);
    end

    -- Oscillator two.
    self.gainKnobs[2].changed = function()
        
        self.oscillators[2]:setParameter("Gain", self.gainKnobs[2].value);
    end

    -- Oscillator three.
    self.gainKnobs[3].changed = function()
        
        self.oscillators[3]:setParameter("Gain", self.gainKnobs[3].value);
    end

    -- Oscillator four.
    self.gainKnobs[4].changed = function()
        
        self.oscillators[4]:setParameter("Gain", self.gainKnobs[4].value);
    end

    -- Oscillator five.
    self.gainKnobs[5].changed = function()
        
        self.oscillators[5]:setParameter("Gain", self.gainKnobs[5].value);
    end

    ------------------------------------------------------------------------------------------------------
    -- Ratio Menu
    ------------------------------------------------------------------------------------------------------

    -- Create ratio menu.
    self.menu = Menu("Ratio", {"1/2", "1/3", "1/4"});
    self.menu.size = {50, 50};
    self.menu.position = {575, 305};

    -- Changed function sets the ui ratio data member.
    self.menu.changed = function()

        if self.menu.value == 1 then

            self.ratio = 2;
            Program.layers[5].inserts[1]:setParameter("DelayTime", 1.0);
        elseif self.menu.value == 2 then

            self.ratio = 3;
            Program.layers[5].inserts[1]:setParameter("DelayTime", 0.7);
        else

            self.ratio = 4;
            Program.layers[5].inserts[1]:setParameter("DelayTime", 0.5);
        end
    end

    -- Changed called to update ratio data member.
    self.menu:changed();

    ------------------------------------------------------------------------------------------------------
    -- Low Pass Filter
    ------------------------------------------------------------------------------------------------------

    -- Define low pass filter object.
    self.lowPass = Program.inserts[1];

    -- Build low pass knob.
    self.lowPassKnob = Knob("lowPass", 1000.0, 20.0, 5000.0);
    self.lowPassKnob:setValue(self.lowPass:getParameter("Freq"));
    self.lowPassKnob.size = {50, 50};
    self.lowPassKnob.position = {460, 330};

    local knobLabel = Label("Low Pass");
    knobLabel.size = {50, 25};
    knobLabel.position = {460, 300};

    self.lowPassKnob.changed = function()

        self.lowPass:setParameter("Freq", self.lowPassKnob.value);
    end

    ------------------------------------------------------------------------------------------------------
    -- High Pass Filter
    ------------------------------------------------------------------------------------------------------

    -- Define high pass filter object.
    self.highPass = Program.inserts[2];

    -- Build low pass knob.
    self.highPassKnob = Knob("highPass", 1000.0, 20.0, 10000.0);
    self.highPassKnob:setValue(self.highPass:getParameter("Freq"));
    self.highPassKnob.size = {50, 50};
    self.highPassKnob.position = {345, 330};

    knobLabel = Label("High Pass");
    knobLabel.size = {50, 25};
    knobLabel.position = {345, 300};

    self.highPassKnob.changed = function()

        self.highPass:setParameter("Freq", self.highPassKnob.value);
    end

    ------------------------------------------------------------------------------------------------------
    -- Info
    ------------------------------------------------------------------------------------------------------

    local title = Label("Basic Sequence");
    title.size = {300, 100};
    title.fontSize = 40;
    title.position = {115, 40};

    local description = Label("This is my first scripting project within UVI Falcon. This program contains five oscillators " ..
    "which are triggered at different intervals when a note is played. The gain of these oscillators can be modified to " ..
    "create interesting sequences. The ratio controls the timing of different voices.");
    description.size = {575, 100};
    description.fontSize = 20;
    description.position = {115, 120};

end

-- Returns a table of values to be saved by the main script.
function ui.Save(self)

    return { menuValue = self.menu.value };
end

-- Loads data saved from previous program state.
function ui.Load(self, data)

    self.menu.value = data.menuValue;
end

return ui;