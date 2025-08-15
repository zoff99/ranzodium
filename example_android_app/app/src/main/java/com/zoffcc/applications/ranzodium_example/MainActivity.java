package com.zoffcc.applications.ranzodium_example;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;

public class MainActivity extends Activity
{
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView t = this.findViewById(R.id.text_window);
        t.setText("...");
        t.setVisibility(View.VISIBLE);
    }
}
