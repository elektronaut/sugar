import React from "react";
import Downshift, { DownshiftState } from "downshift";
import { matchSorter } from "match-sorter";

import Menu from "./Menu";
import MenuItem from "./MenuItem";

interface TypeaheadTextFieldProps {
  autoFocus: boolean;
  label: string;
  name: string;
  onChange: (value: string) => void;
  onKeyDown: (evt: KeyboardEvent) => void;
  options: string[];
  size: number;
  value: string;
}

export default function TypeaheadTextField(props: TypeaheadTextFieldProps) {
  const { label, name, onChange, options, size, value } = props;

  const handleKeyDown = (evt: KeyboardEvent) => {
    if (props.onKeyDown) {
      props.onKeyDown(evt);
    }
  };

  const handleStateChange = (changes: DownshiftState<string>) => {
    if ("selectedItem" in changes) {
      onChange(changes.selectedItem);
    } else if (changes.inputValue) {
      onChange(changes.inputValue as string);
    }
  };

  return (
    <Downshift onStateChange={handleStateChange} selectedItem={value}>
      {({
        getInputProps,
        getItemProps,
        getLabelProps,
        getMenuProps,
        getToggleButtonProps,
        isOpen,
        clearSelection,
        inputValue,
        highlightedIndex,
        selectedItem,
        getRootProps
      }) => (
        <div className="field">
          <label {...getLabelProps()}>{label}</label>
          <div
            className={"typeahead-input " + (isOpen ? "open" : "")}
            style={{ display: "inline-block" }}
            {...getRootProps({}, { suppressRefError: true })}>
            <input
              autoFocus={props.autoFocus}
              type="text"
              name={name}
              size={size}
              {...getInputProps({
                isOpen,
                onKeyDown: handleKeyDown
              })}
            />
            {selectedItem ? (
              <button onClick={clearSelection}>
                <i className="fa-solid fa-xmark" />
              </button>
            ) : (
              <button {...getToggleButtonProps()}>
                {isOpen ? (
                  <i className="fa-solid fa-chevron-up" />
                ) : (
                  <i className="fa-solid fa-chevron-down" />
                )}
              </button>
            )}
            {isOpen && (
              <Menu {...getMenuProps()}>
                {matchSorter(options, inputValue).map((item, index) => (
                  <MenuItem
                    key={item}
                    {...getItemProps({
                      index,
                      item,
                      isActive: highlightedIndex === index,
                      isSelected: selectedItem === item
                    })}>
                    {item}
                  </MenuItem>
                ))}
              </Menu>
            )}
          </div>
        </div>
      )}
    </Downshift>
  );
}
