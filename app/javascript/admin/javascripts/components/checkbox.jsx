import React from "react";

const Checkbox = ({ name, id, checked, onChange, labelText }) => {
  return (
    <p>
      <label htmlFor={id}>
        <input type="hidden" name={name} value="0"></input>
        <input type="checkbox" name={name} id={id} value="1" checked={checked} onChange={onChange}></input>
        <span>{labelText}</span>
      </label>
    </p>
  );
};

export default Checkbox;
