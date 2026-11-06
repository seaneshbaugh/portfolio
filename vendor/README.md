# Browser assets

`javascript/` contains only the browser distributions needed by the import map.
The matching exact npm versions are in `javascript/versions.json`; source package
versions/integrities remain locked in `yarn.lock`. Licenses are retained under
`licenses/`. No browser requests depend on a CDN or a running JavaScript bundler.

After intentionally updating the relevant npm packages, run `node bin/vendor-assets`
(or `docker compose exec web node bin/vendor-assets`) and review the resulting
JavaScript, font, version and license changes. Commit these files together with
the lockfile. This command copies assets from installed dependencies; it does not
resolve or download dependencies. Material icon fonts are copied to
`app/assets/fonts/material-icons` by the same command.

Materialize ships an ES module. GLightbox and Ace ship browser distributions that
set globals; small app modules adapt them for native ESM imports. `lib/ace.js`
configures only the supported CSS/HTML/JavaScript workers, using Propshaft's
fingerprinted asset URLs. Ace core/modes/theme load only through the admin
entrypoint; GLightbox loads only through the public entrypoint.

Rails gems supply Stimulus, Active Storage and Rails UJS directly. Sass sources
continue to use npm's Materialize, Animate.css and GLightbox CSS through the
separate cssbundling-rails build. These builds use the installed lockfile versions.
