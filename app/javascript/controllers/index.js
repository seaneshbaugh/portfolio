// Discover controllers on demand so public pages do not download Ace/admin code.
import { application } from "controllers/application";
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading";
lazyLoadControllersFrom("controllers", application);
