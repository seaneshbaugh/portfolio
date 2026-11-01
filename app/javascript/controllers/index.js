// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application";
import PictureSelectorController from "./picture_selector_controller";

application.register("picture-selector", PictureSelectorController);
