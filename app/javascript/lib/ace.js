import "ace/core";
import "ace/mode-css";
import "ace/mode-html";
import "ace/mode-javascript";
import "ace/mode-text";
import "ace/mode-rhtml";
import "ace/theme-github";

// Propshaft rewrites these explicit worker URLs to fingerprinted assets.
const ace = window.ace;
ace.config.setModuleUrl("ace/mode/css_worker", RAILS_ASSET_URL("/ace/worker-css.js"));
ace.config.setModuleUrl("ace/mode/html_worker", RAILS_ASSET_URL("/ace/worker-html.js"));
ace.config.setModuleUrl("ace/mode/javascript_worker", RAILS_ASSET_URL("/ace/worker-javascript.js"));

export default ace;
