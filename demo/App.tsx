import React, { useState } from 'react';
import { SafeAreaView, View, StatusBar, useColorScheme, Text, Alert, StyleSheet } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';
import { Highlight, SelectableText, SelectionEvent } from './SelectableText';


const App = () => {
  const handleSelection = (selection: {
    eventType: string;
    content: string;
    selectionStart: number;
    selectionEnd: number;
  }) => {
    console.log('Selected text:', selection);
    Alert.alert(selection.eventType, selection.content);
  };

  return (
    <View style={styles.container}>
      <SelectableText
        textComponentProps={{ multiline: true }}
        menuItems={['Replace', 'Cancel']}
        onSelection={handleSelection}
        highlightColor={'red'}
        highlights={[{ start: 0, end: 10, id: 'test' }]}
        value={'The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.'}
      />
      <SelectableText
        menuItems={['Copy', 'Highlight', 'Share']}
        onSelection={handleSelection}
        textComponentProps={{ style: styles.baseText }}
      >
        <Text style={styles.normal}>This is a </Text>
        <Text style={styles.bold}>sample </Text>
        <Text style={styles.highlighted}>text </Text>
        <Text style={styles.normal}>with </Text>
        <Text style={styles.italic}>different </Text>
        <Text style={styles.underline}>styles</Text>
        <Text style={styles.normal}> applied!</Text>
      </SelectableText>

      <SelectableText
        menuItems={['define']}
        highlightColor={'red'}
        highlights={[{ start: 0, end: 10, id: 'test' }]}
        onSelection={handleSelection}
        textComponentProps={{ style: styles.baseText }}
      >
        <Text style={{ fontSize: 20 }}>
          Great
          <Text style={{ fontSize: 10 }}>
            MESSAGES great message Great MESSAGES
          </Text>
        </Text>
      </SelectableText>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
    justifyContent: 'center',
  },
  baseText: {
    fontSize: 18,
    color: '#000',
  },
  normal: {
    color: '#333',
  },
  bold: {
    fontWeight: 'bold',
    color: '#1a73e8',
  },
  italic: {
    fontStyle: 'italic',
    color: '#d93025',
  },
  underline: {
    textDecorationLine: 'underline',
    color: '#188038',
  },
  highlighted: {
    backgroundColor: '#ffeb3b',
    color: '#000',
  },
});

export default App;
