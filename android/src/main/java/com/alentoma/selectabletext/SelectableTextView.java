package com.rob117.selectabletext;

import android.content.Context;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ActionMode;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.view.View;
import android.graphics.Color; // Import for setting transparent color

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.uimanager.events.RCTEventEmitter;

public class SelectableTextView extends FrameLayout {
    private final TextView textView;
    private String[] menuItems = new String[0];

    public SelectableTextView(@NonNull Context context) {
        super(context);
        textView = new TextView(context);
        textView.setTextIsSelectable(true); // Enable text selection
        textView.setTextColor(Color.TRANSPARENT); // Make text visually transparent
        textView.setBackgroundColor(Color.TRANSPARENT); // Ensure background is transparent
        addView(textView);
    }

    public void setText(String text) {
        textView.setText(text);
        // Keep textView visible for selection purposes
        textView.setVisibility(View.VISIBLE);
    }

    public void setMenuItems(@Nullable String[] items) {
        if (items != null) {
            this.menuItems = items;
            registerSelectionListener();
        }
    }

    private void registerSelectionListener() {
        textView.setCustomSelectionActionModeCallback(new ActionMode.Callback() {
            @Override
            public boolean onCreateActionMode(ActionMode mode, Menu menu) {
                return true;
            }

            @Override
            public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
                menu.clear();
                for (int i = 0; i < menuItems.length; i++) {
                    menu.add(0, i, 0, menuItems[i]);
                }
                return true;
            }

            @Override
            public void onDestroyActionMode(ActionMode mode) {
            }

            @Override
            public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
                int selectionStart = textView.getSelectionStart();
                int selectionEnd = textView.getSelectionEnd();
                String selectedText = textView.getText().toString().substring(selectionStart, selectionEnd);

                dispatchOnSelectionEvent(menuItems[item.getItemId()], selectedText, selectionStart, selectionEnd);

                mode.finish();
                return true;
            }
        });
    }

    private void dispatchOnSelectionEvent(String eventType, String content, int selectionStart, int selectionEnd) {
        WritableMap event = Arguments.createMap();
        event.putString("eventType", eventType);
        event.putString("content", content);
        event.putInt("selectionStart", selectionStart);
        event.putInt("selectionEnd", selectionEnd);

        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topSelection",
                event
        );
    }

    @Override
    public void addView(View child, int index) {
        super.addView(child, index);
        // Ensure textView remains the first child for selection
        if (child != textView) {
            bringChildToFront(textView);
        }
    }
}