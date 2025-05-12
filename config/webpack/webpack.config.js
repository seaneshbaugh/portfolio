// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig, merge } = require("shakapacker");

const options = {
  resolve: {
    // Not gonna lie, I'm still not 100% sure why this is needed if shakapacker.yml defines extensions.
    extensions: [".jpg", ".jpeg", ".gif", ".js", ".jsx", ".png", ".scss"]
  }
};

const webpackConfig = generateWebpackConfig(options);

// Override default sass-loader config. This is apparently how it's supposed to be done.
// See https://github.com/shakacode/shakapacker/issues/80.
const sassRule = webpackConfig.module.rules.find((rule) => ".sass".match(rule.test));
const sassLoader = sassRule.use.find((use) => use.loader && use.loader.match(/sass-loader/));
const sassOptions = {
  // TODO: Add node_modules to load path?
  quietDeps: true,
  silenceDeprecations: ["global-builtin"]
};

sassLoader.options.sassOptions = merge(sassLoader.options.sassOptions, sassOptions);

module.exports = webpackConfig;
