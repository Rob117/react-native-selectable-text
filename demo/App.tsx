import React, { useState } from 'react';
import { SafeAreaView, View, StatusBar, useColorScheme, Text, Alert } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';
import { Highlight, SelectableText, SelectionEvent } from './SelectableText';



const App = () => {
  const isDarkMode = useColorScheme() === 'dark';
  const [highlights, setHighlights] = useState<Highlight[]>([]);

  const handleSelection = ({ eventType, content, selectionStart, selectionEnd }: SelectionEvent) => {
    console.log('Event:', eventType);
    console.log('Selected:', content);

    if (eventType === 'Highlight') {
      const newHighlight: Highlight = {
        start: selectionStart,
        end: selectionEnd,
        id: `${selectionStart}-${selectionEnd}-${Date.now()}`,
        color: '#FFEB3B',
      };
      setHighlights([...highlights, newHighlight]);
    } else {
      Alert.alert(eventType, content);
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: isDarkMode ? Colors.darker : Colors.lighter }}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 20 }}>
        <Text style={{ marginBottom: 10, fontSize: 18, fontWeight: 'bold' }}>Custom Selectable Text:</Text>

        <SelectableText
          textComponentProps={{ multiline: true }}
          menuItems={["Highlight", "Copy", "Share"]}
          onSelection={handleSelection}
          highlightColor="#FFEB3B"
          highlights={highlights}
          style={{
            width: '100%',
            minHeight: 80
          }}
          value={"You can select any part of this sentence to see options like Copy, Highlight, or Share."}
        />

        <SelectableText
          menuItems={["define"]}
          onSelection={({ content }) => console.log(content)}
          highlightColor="#FFEB3B"
          highlights={highlights}
        >
          <Text style={{ color: "black" }}>
            This text is black, but the next word has
            <Text style={[{ color: 'red', textDecorationLine: 'underline' }]}>
              red coloring and an underline
            </Text>
            with a black sentence end
          </Text>
        </SelectableText>


      </View>
    </SafeAreaView>
  );
};

export default App;
