import "@hotwired/turbo-rails";
import * as Materialize from "@materializecss/materialize";
import "flash_messages";

const components = Object.values(Materialize).filter(component => typeof component.getInstance === "function");
const teardown = () => {
  const instances = new Set();
  document.querySelectorAll("*").forEach(element => {
    components.forEach(component => {
      const instance = component.getInstance(element);
      if (instance) instances.add(instance);
    });
  });
  instances.forEach(instance => instance.destroy());
};

document.addEventListener("turbo:load", () => Materialize.AutoInit());
document.addEventListener("turbo:before-cache", teardown);
document.addEventListener("turbo:before-render", teardown);
