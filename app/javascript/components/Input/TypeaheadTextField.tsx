import Downshift, { StateChangeOptions } from "downshift";
import { matchSorter } from "match-sorter";

import Menu from "./Menu";
import MenuItem from "./MenuItem";

interface Props {
  label: string;
  name: string;
  onChange: (value: string) => void;
  onKeyDown: (evt: React.KeyboardEvent) => void | Promise<void>;
  options: string[];
  value: string;
  size?: number;
  autoFocus?: boolean;
  onFocus?: (evt: React.FocusEvent) => void | Promise<void>;
}

export default function TypeaheadTextField(props: Props) {
  const { label, name, onChange, options, size, value } = props;

  const handleKeyDown = (evt: React.KeyboardEvent) => {
    if (props.onKeyDown) {
      void props.onKeyDown(evt);
    }
  };

  const handleStateChange = (changes: StateChangeOptions<string>) => {
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
            {...getRootProps({}, { suppressRefError: true })}>
            <input
              autoFocus={props.autoFocus}
              type="text"
              name={name}
              size={size || 20}
              {...getInputProps({
                isOpen,
                onFocus: props.onFocus,
                onKeyDown: handleKeyDown
              })}
            />
            {selectedItem ? (
              <button onClick={() => clearSelection()}>
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
