//= require jquery
//= require jquery_ujs
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require twitter/bootstrap
//= require vendor_assets
//= require ace
//= require shared
//= require_self

$.fn.extend({
    insertAtCaret: function(myValue) {
        this.each(function() {
            if (document.selection) {
                this.focus();

                var selection = document.selection.createRange();

                selection.text = myValue;

                this.focus();
            } else {
                if (this.selectionStart || this.selectionStart === "0") {
                    var startPosition = this.selectionStart;
                    var endPosition = this.selectionEnd;
                    var scrollTop = this.scrollTop;

                    this.value = this.value.substring(0, startPosition) + myValue + this.value.substring(endPosition, this.value.length);

                    this.focus();

                    this.selectionStart = startPosition + myValue.length;

                    this.selectionEnd = startPosition + myValue.length;

                    this.scrollTop = scrollTop;
                } else {
                    this.value += myValue;

                    this.selectionStart = myValue.length;

                    this.selectionEnd = myValue.length;

                    this.focus();
                }
            }
        });
    },
    insertImageTagAtCaret: function(url, altText, title, isLink) {
        this.each(function(index) {
            var imageTag = "<img src=\"" + url.substr(0, url.indexOf("?")).trim() + "\" alt=\"" + altText.trim() + "\" title=\"" + title.trim() + "\">";

            if (isLink) {
                imageTag = "<a href=\"" + url.trim() + "\">" + imageTag.trim() + "</a>";
            }

            $(this).insertAtCaret(imageTag);
        });
    }
});

$(function() {
    var lastTextArea;

    $("[rel*=tooltip]").tooltip({placement: "top"});

    $("[rel*=popover]").popover({trigger: "hover"});

    lastTextArea = $("textarea").first();

    $("textarea").on("focus", function() {
        lastTextArea = this;
    });

    $(".ace-editor").each(function() {
        var editorContainer, editorID, editorName, textarea, mode, theme, editor;

        editorContainer = $(this);

        editorID = editorContainer.attr("id");

        // This expects the editor ID to be in the form of "model_name_attribute-editor"
        editorName = "#" + editorID.split("-")[0];

        textarea = $(editorName);

        mode = editorContainer.data("mode").toLowerCase();

        if (mode === "erb") {
            mode = "rhtml";
        }

        if (textarea.length === 1 && ["coffee", "css", "html", "javascript", "json", "less", "rhtml", "ruby", "text"].indexOf(mode) !== -1) {
            $(textarea).hide();

            editor = ace.edit(editorID);

            $("#" + editorID).data("editor", editor);

            theme = editorContainer.data("theme");

            if (theme) {
                theme = theme.toLowerCase();
            } else {
                theme = "pastel_on_dark";
            }

            editor.setTheme("ace/theme/" + theme);

            editor.getSession().setMode("ace/mode/" + mode);

            editor.getSession().setValue($(textarea).val());

            editor.getSession().setTabSize(2);

            editor.getSession().setUseSoftTabs(true);

            editor.getSession().on("change", function() {
                $(textarea).val(editor.getSession().getValue());
            });
        }
    });

    $("body").on("click", ".picture-selector-button", function(event) {
        event.preventDefault();

        if ($("#picture-selector").length === 0) {
            $.get("/admin/pictures/selector", null, function(data, textStatus, jqXHR) {
                $("body").append('<div id="picture-selector-container" class="hidden"></div>');

                $("#picture-selector-container").append('<a href="#picture-selector" id="picture-selector-activator" class="btn">Show Picture Selector</a>');

                $("#picture-selector-container").append($(data));

                $("#picture-selector-activator").colorbox({height: "75%", inline: true, open: true, width: "75%"});

            }, "html");
        } else {
            $("#picture-selector-activator").colorbox({height: "75%", inline: true, open: true, width: "75%"});
        }
    });

    $("body").on("click", ".picture-selector-picture img", function() {
        if (lastTextArea !== undefined) {
            $(lastTextArea).insertImageTagAtCaret($(this).data("url"), $(this).attr("alt"), $(this).attr("title"), false);
        }

        $.colorbox.close();
    });


    $("#pictures #new_picture").fileupload({
        dataType: "script",
        add: function(event, data) {
            var file, types;

            types = new RegExp("(\\.|\\/)(" + $(this).data("accept") + ")$", "i");

            file = data.files[0];

            if (types.test(file.type) || types.test(file.name)) {
                data.context = $($.trim(tmpl("template-upload", file)));

                $(this).append(data.context);

                return data.submit();
            } else {
                return alert("" + file.name + " is not a valid file");
            }
        },
        progress: function(event, data) {
            var progress;

            if (data.context) {
                progress = parseInt(data.loaded / data.total * 100, 10);

                data.context.find(".bar").css("width", progress + "%");
            }
        },
        done: function(event, data) {
            if (data.context) {
                data.context.find(".bar").css("width", "100%");

                setTimeout(function(){
                    data.context.find(".progress").removeClass("progress-info active").delay(500).addClass("progress-success").parent().fadeOut(4000);
                }, 500);
            }
        },
        fail: function(event, data) {
            if (data.context) {
                data.context.find(".progress").removeClass("progress-info active").delay(500).addClass("progress-danger");
            }
        }
    });
});
