# Browser assets

`javascript/` contains the retained Ace and GLightbox browser distributions. Exact
npm versions are recorded in `javascript/versions.json`; source integrities are
locked in `yarn.lock`. Licenses are retained under `licenses/`. GLightbox's unchanged
CSS lives in `assets/stylesheets` and is served by Propshaft separately from the
small public site stylesheet. No browser request requires a CDN or JS bundler.

After intentionally updating these npm packages, run `node bin/vendor-assets`
(or `docker compose exec web node bin/vendor-assets`) and review the resulting
JS/CSS/version/license changes. Commit them with their lockfile. The command copies
from installed dependencies; it does not resolve or download packages.

GLightbox and Ace set browser globals; small app modules adapt them for native
ESM imports. `lib/ace.js` configures the supported workers using Propshaft asset
URLs. Ace loads through the admin entrypoint; GLightbox through the public one.
Rails gems supply Turbo, Stimulus and Active Storage directly. Tailwind's Rails
integration builds admin/auth CSS independently using its standalone Ruby-gem CLI.
Materialize and the Material Icons font have been removed; UI icons are inline SVG.
