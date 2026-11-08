import "@hotwired/turbo-rails";
import { application } from "controllers/application";
import FlashController from "controllers/flash_controller";

application.register("flash", FlashController);
