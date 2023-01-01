import React from "react";
import PropTypes from "prop-types";
import Downshift from "downshift";
import { matchSorter } from "match-sorter";

import Menu from "./Menu";
import MenuItem from "./MenuItem";

export default function TypeaheadTextField(props) {
  const { label, name, onChange, options, size, value } = props;

  const handleKeyDown = (evt) => {
    if (props.onKeyDown) {
      props.onKeyDown(evt);
    }
  };

  const handleStateChange = (changes) => {
    if (Object.prototype.hasOwnProperty.call(changes, "selectedItem")) {
      onChange(changes.selectedItem);
    } else if (Object.prototype.hasOwnProperty.call(changes, "inputValue")) {
      onChange(changes.inputValue);
    }
  };

  return (
    <Downshift
      onStateChange={handleStateChange}
      selectedItem={value}>
      {({ getInputProps,
          getItemProps,
          getLabelProps,
          getMenuProps,
          getToggleButtonProps,
          isOpen,
          clearSelection,
          inputValue,
          highlightedIndex,
          selectedItem,
          getRootProps}) => (
            <div className="field">
              <label {...getLabelProps()}>{label}</label>
              <div className={"typeahead-input " + (isOpen ? "open" : "")}
                   style={{display: "inline-block"}}
                   {...getRootProps({}, { suppressRefError: true })}>
                <input autoFocus={props.autoFocus}
                       type="text"
                       name={name}
                       size={size}
                       {...getInputProps({
                         isOpen,
                         onKeyDown: handleKeyDown
                       })} />
                {selectedItem ?
                 <button onClick={clearSelection}>
                   <i className="fa fa-remove" />
                 </button> :
                 <button {...getToggleButtonProps()}>
                   {isOpen ?
                    <i className="fa fa-chevron-up" /> :
                    <i className="fa fa-chevron-down" />}
                 </button>}
                {isOpen &&
                 <Menu {...getMenuProps()}>
                   {matchSorter(options, inputValue).map((item, index) => (
                     <MenuItem
                       {...getItemProps({
                         key: item,
                         index,
                         item,
                         isActive: highlightedIndex === index,
                         isSelected: selectedItem === item})}>
                       {item}
                     </MenuItem>
                   ))}
                 </Menu>}
              </div>
            </div>
          )}
    </Downshift>
  );
}

TypeaheadTextField.propTypes = {
  autoFocus: PropTypes.bool,
  label: PropTypes.string,
  name: PropTypes.string,
  onChange: PropTypes.func,
  onKeyDown: PropTypes.func,
  options: PropTypes.array,
  size: PropTypes.number,
  value: PropTypes.string
};
