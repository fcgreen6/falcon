ui = require("ui");

ui:CreateUserInterface();
--ui:Refresh();

function onNote(event)

    print("I am gay")
end

function onSave()

    return { ui = ui:Save() };
end

function onLoad(data)

    ui:Load(data.ui);
end