// const onReady = function(completed) {
//   if (document.readyState === "complete") {
//     setTimeout(completed);
//   } else {
//     document.addEventListener("DOMContentLoaded", completed, false);
//   }
// };

// onReady(function() {
//   const inputSelector = [
//     "input[type=text]",
//     "input[type=password]",
//     "input[type=email]",
//     "input[type=url]",
//     "input[type=time]",
//     "input[type=date]",
//     "input[type=datetime]",
//     "input[type=datetime-local]",
//     "input[type=tel]",
//     "input[type=number]",
//     "input[type=search]",
//     "textarea"
//   ];

//   Array.prototype.slice.call(document.querySelectorAll(inputSelector), 0).forEach(function(input) {
//     input.addEventListener("focus", function(event) {
//       const label = event.target.parentElement.querySelector("label");

//       if (label) {
//         label.classList.add("active");
//       }
//     });

//     input.addEventListener("blur", function(event) {
//       const label = event.target.parentElement.querySelector("label");

//       if (!event.target.value && label) {
//         label.classList.remove("active");
//       }
//     });
//   });
// });
