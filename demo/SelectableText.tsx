import React, { ReactNode } from 'react';
import {
  Text,
  requireNativeComponent,
  TextStyle,
  StyleProp,
  TextProps,
  TextInputProps,
  ColorValue,
  ReactElement,
} from 'react-native';
import memoize from 'fast-memoize';

interface RNSelectableTextNativeProps extends TextProps {
  value?: string;
  menuItems?: string[];
  selectable?: boolean;
  onSelection?: (event: { nativeEvent: NativeEvent }) => void;
  highlights?: IHighlights[];
  highlightColor?: ColorValue;
  onHighlightPress?: (id: string) => void;
}

const RNSelectableText = requireNativeComponent<RNSelectableTextNativeProps>('RNSelectableText');

export interface IHighlights {
  start: number;
  end: number;
  id: string;
  color?: ColorValue;
}

export interface NativeEvent {
  content: string;
  eventType: string;
  selectionStart: number;
  selectionEnd: number;
}

export interface SelectableTextProps {
  value?: string; // Make value optional since we’ll derive it from children if not provided
  onSelection: (args: {
    eventType: string;
    content: string;
    selectionStart: number;
    selectionEnd: number;
  }) => void;
  prependToChild?: ReactNode;
  menuItems: string[];
  highlights?: Array<IHighlights>;
  highlightColor?: ColorValue;
  style?: StyleProp<TextStyle>;
  onHighlightPress?: (id: string) => void;
  appendToChildren?: ReactNode;
  TextComponent?: React.ComponentType<any>;
  textValueProp?: string;
  textComponentProps?: TextProps | TextInputProps;
  children?: ReactNode; // Add children prop explicitly
}

const combineHighlights = memoize((numbers: IHighlights[]) => {
  return numbers
    .sort((a, b) => a.start - b.start || a.end - b.end)
    .reduce(function (combined, next) {
      if (!combined.length || combined[combined.length - 1].end < next.start)
        combined.push(next);
      else {
        var prev = combined.pop();
        if (prev)
          combined.push({
            start: prev.start,
            end: Math.max(prev.end, next.end),
            id: next.id,
            color: prev.color,
          });
      }
      return combined;
    }, [] as IHighlights[]);
});

const mapHighlightsRanges = (value: string, highlights: IHighlights[]) => {
  const combinedHighlights = combineHighlights(highlights);

  if (combinedHighlights.length === 0)
    return [{ isHighlight: false, text: value, id: undefined, color: undefined }];

  const data = [
    {
      isHighlight: false,
      text: value.slice(0, combinedHighlights[0].start),
      id: combinedHighlights[0].id,
      color: combinedHighlights[0].color,
    },
  ];

  combinedHighlights.forEach(({ start, end, id, color }, idx) => {
    data.push({
      isHighlight: true,
      text: value.slice(start, end),
      id: id,
      color: color,
    });

    if (combinedHighlights[idx + 1]) {
      data.push({
        isHighlight: false,
        text: value.slice(end, combinedHighlights[idx + 1].start),
        id: combinedHighlights[idx + 1].id,
        color: combinedHighlights[idx + 1].color,
      });
    }
  });

  data.push({
    isHighlight: false,
    text: value.slice(combinedHighlights[combinedHighlights.length - 1].end, value.length),
    id: combinedHighlights[combinedHighlights.length - 1].id,
    color: combinedHighlights[combinedHighlights.length - 1].color,
  });

  return data.filter((x) => x.text);
};

// Utility to extract text from React children
const extractTextFromChildren = (children: ReactNode): string => {
  let text = '';
  React.Children.forEach(children, (child) => {
    if (typeof child === 'string') {
      text += child;
    } else if (React.isValidElement(child)) {
      if (child.type === Text) {
        text += extractTextFromChildren(child.props.children);
      }
    }
  });
  return text;
};

export const SelectableText = ({
  onSelection,
  onHighlightPress,
  textValueProp = 'children',
  value,
  TextComponent,
  textComponentProps,
  prependToChild,
  appendToChildren,
  children,
  ...props
}: SelectableTextProps) => {
  const TX = (TextComponent || Text) as React.ComponentType<any>;

  const onSelectionNative = (event: any) => {
    const nativeEvent = event.nativeEvent as NativeEvent;
    onSelection && onSelection(nativeEvent);
  };

  // Derive the value from children if not provided
  const derivedValue = value || extractTextFromChildren(children);

  let textValue: any = derivedValue;
  if (TextComponent === Text || !TextComponent) {
    if (props.highlights && props.highlights.length > 0) {
      textValue = mapHighlightsRanges(derivedValue, props.highlights).map(
        ({ id, isHighlight, text, color }) => (
          <Text
            key={`${id}-${text}-${Math.random()}`}
            {...textComponentProps}
            selectable={true}
            style={
              isHighlight
                ? { backgroundColor: color ?? props.highlightColor }
                : {}
            }
            onPress={() => {
              if (textComponentProps && textComponentProps.onPress)
                textComponentProps.onPress();
              if (isHighlight) {
                onHighlightPress && onHighlightPress(id ?? '');
              }
            }}
          >
            {text}
          </Text>
        )
      );
    } else {
      // If no highlights, use the children as-is
      textValue = children;
    }

    if (appendToChildren) {
      textValue = Array.isArray(textValue)
        ? [...textValue, appendToChildren]
        : [textValue, appendToChildren];
    }

    if (prependToChild) {
      textValue = Array.isArray(textValue)
        ? [prependToChild, ...textValue]
        : [prependToChild, textValue];
    }
  }

  return (
    <RNSelectableText
      {...props}
      selectable={true}
      onSelection={onSelectionNative}
      value={derivedValue} // Pass the derived or provided value to the native component
    >
      <TX {...{ [textValueProp]: textValue, ...textComponentProps }} />
    </RNSelectableText>
  );
};