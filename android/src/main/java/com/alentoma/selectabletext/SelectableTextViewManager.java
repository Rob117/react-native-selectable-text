package com.rob117.selectabletext;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

@ReactModule(name = SelectableTextViewManager.REACT_CLASS)
public class SelectableTextViewManager extends ViewGroupManager<SelectableTextView> {
    public static final String REACT_CLASS = "RNSelectableText";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected SelectableTextView createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new SelectableTextView(reactContext);
    }

    @ReactProp(name = "value")
    public void setValue(SelectableTextView view, @Nullable String value) {
        view.setText(value != null ? value : "");
    }

    @ReactProp(name = "menuItems")
    public void setMenuItems(SelectableTextView view, @Nullable ReadableArray items) {
        if (items != null) {
            String[] menuItems = new String[items.size()];
            for (int i = 0; i < items.size(); i++) {
                menuItems[i] = items.getString(i);
            }
            view.setMenuItems(menuItems);
        } else {
            view.setMenuItems(new String[0]);
        }
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put(
                        "topSelection",
                        MapBuilder.of("registrationName", "onSelection"))
                .build();
    }

    // Implement ViewGroupManager methods to support child views
    @Override
    public void addView(SelectableTextView parent, View child, int index) {
        parent.addView(child, index);
    }

    @Override
    public int getChildCount(SelectableTextView parent) {
        return parent.getChildCount();
    }

    @Override
    public View getChildAt(SelectableTextView parent, int index) {
        return parent.getChildAt(index);
    }

    @Override
    public void removeViewAt(SelectableTextView parent, int index) {
        parent.removeViewAt(index);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return false;
    }
}