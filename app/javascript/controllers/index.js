// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import PictureSelectorController from "controllers/picture_selector_controller";
import AceEditorController from "controllers/ace_editor_controller";
import PictureUploadsController from "controllers/picture_uploads_controller";
import GalleryPicturesController from "controllers/gallery_pictures_controller";

application.register("picture-selector", PictureSelectorController);
application.register("ace-editor", AceEditorController);
application.register("picture-uploads", PictureUploadsController);
application.register("gallery-pictures", GalleryPicturesController);
