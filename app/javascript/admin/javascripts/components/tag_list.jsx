// TODO: Find a replacement for react-tag-input. It has way outdated dependencies.

// import React from "react";
// import { findDOMNode } from "react-dom";
// import PropTypes from "prop-types";
// import { WithContext as ReactTags } from "react-tag-input";

// const KeyCodes = {
//   comma: 188,
//   enter: 13,
//   tab: 9
// };

// const delimiters = [KeyCodes.comma, KeyCodes.enter, KeyCodes.tab];

// class TagList extends React.Component {
//   constructor(props) {
//     super(props);

//     const tags = props.tags.map(tag => ({ id: tag, text: tag }));
//     const suggestions = props.suggestions.map(suggestion => ({ id: suggestion, text: suggestion }));

//     this.state = { tags, suggestions };

//     this.handleDelete = this.handleDelete.bind(this);
//     this.handleAddition = this.handleAddition.bind(this);
//     this.handleDrag = this.handleDrag.bind(this);
//   }

//   handleDelete(index) {
//     const { tags } = this.state;

//     this.setState({
//       tags: tags.filter((tag, i) => index !== i),
//     });
//   }

//   handleAddition(tag) {
//     this.setState(state => ({ tags: [...state.tags, tag] }));
//   }

//   handleDrag(tag, currentPosition, newPosition) {
//     const tags = [...this.state.tags];
//     const newTags = tags.slice();

//     newTags.splice(currentPosition, 1);
//     newTags.splice(newPosition, 0, tag);

//     this.setState({ tags: newTags });
//   }

//   render() {
//     const { tags, suggestions } = this.state;
//     const hiddenInputId = `${this.props.objectName}_${this.props.method}`;
//     const hiddenInputName = `${this.props.objectName}[${this.props.method}]`;
//     const hiddenInputValue = tags.map((tag) => tag.text).join(",");

//     return (
//       <div className="taglist">
//         <ReactTags tags={tags}
//                    suggestions={suggestions}
//                    handleDelete={this.handleDelete}
//                    handleAddition={this.handleAddition}
//                    handleDrag={this.handleDrag}
//                    delimiters={delimiters} />
//         <input type="hidden" id={hiddenInputId} name={hiddenInputName} value={hiddenInputValue} />
//       </div>
//     );
//   }
// };

// export default TagList;
