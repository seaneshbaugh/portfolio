import React from "react";
import PropTypes from "prop-types";

class Button extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.props.onClick.bind(this);
  }

  render() {
    return(
      <button className={this.props.className} onClick={this.handleClick}>{this.props.text}</button>
    );
  }
}

Button.propTypes = {
  "className": PropTypes.string,
  "onClick": PropTypes.func.isRequired,
  "text": PropTypes.string.isRequired
};

export default Button;
