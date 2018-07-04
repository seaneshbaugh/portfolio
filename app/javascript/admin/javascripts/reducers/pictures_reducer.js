const initialState = {
  "pictures": []
};

const updateObject = (oldObject, newValues) => {
  return Object.assign({}, oldObject, newValues);
};

const addPicture = (state, action) => {
  const newPictures = [action.picture, ...state.pictures];

  return updateObject(state, { "pictures": newPictures });
};

const picturesReducer = (state = initialState, action) => {
  switch(action.type) {
  case "ADD_PICTURE": return addPicture(state, action);
  default: return state;
  }
};

export default picturesReducer;
