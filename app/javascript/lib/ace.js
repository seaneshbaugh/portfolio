import ace from "ace-builds/src-noconflict/ace";
import "ace-builds/src-noconflict/mode-css";
import "ace-builds/src-noconflict/mode-html";
import "ace-builds/src-noconflict/mode-javascript";
import "ace-builds/src-noconflict/mode-text";
import "ace-builds/src-noconflict/mode-rhtml";
import "ace-builds/src-noconflict/theme-github";

// Keep asset delivery separate from the controller. When webpack is retired,
// these URLs must come from the Rails asset pipeline instead.
ace.config.setModuleUrl("ace/mode/css_worker", new URL("ace-builds/src-noconflict/worker-css.js", import.meta.url).href);
ace.config.setModuleUrl("ace/mode/html_worker", new URL("ace-builds/src-noconflict/worker-html.js", import.meta.url).href);
ace.config.setModuleUrl("ace/mode/javascript_worker", new URL("ace-builds/src-noconflict/worker-javascript.js", import.meta.url).href);

export default ace;
