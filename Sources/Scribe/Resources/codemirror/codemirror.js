window.CodeMirror = function(parent, options) {
    // Notify Swift
    window.webkit?.messageHandlers?.consoleLog?.postMessage("JS: Mock CodeMirror Initialized");
    
    const textarea = document.createElement("textarea");
    textarea.style.width = "100%";
    textarea.style.height = "100%";
    textarea.style.fontFamily = "monospace";
    textarea.style.fontSize = "16px";
    textarea.style.background = "#282a36";
    textarea.style.color = "#f8f8f2";
    textarea.style.border = "none";
    textarea.style.resize = "none";
    textarea.style.outline = "none";
    textarea.style.padding = "20px";
    
    if (options.value) textarea.value = options.value;
    
    parent.appendChild(textarea);
    
    const instance = {
        getValue: () => textarea.value,
        setValue: (v) => { textarea.value = v; },
        on: (event, callback) => {
            if (event === "change") {
                textarea.addEventListener("input", () => {
                    callback(instance, { origin: "+input" });
                });
            }
        },
        getCursor: () => ({line: 0, ch: 0}),
        setCursor: () => {}
    };
    
    return instance;
};