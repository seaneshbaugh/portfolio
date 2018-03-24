require.context("../stylesheets", true, /^\.\/[^_].*\.(css|scss|sass)$/i);

//require("../stylesheets/application.scss");

import Rails from "rails-ujs";

Rails.start();

import "./form";
