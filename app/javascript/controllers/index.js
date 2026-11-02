// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application";
import PictureSelectorController from "./picture_selector_controller";
import AceEditorController from "./ace_editor_controller";
import PictureUploadsController from "./picture_uploads_controller";

application.register("picture-selector", PictureSelectorController);
application.register("ace-editor", AceEditorController);
application.register("picture-uploads", PictureUploadsController);
