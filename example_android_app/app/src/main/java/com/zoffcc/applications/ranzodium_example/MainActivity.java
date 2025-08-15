package com.zoffcc.applications.ranzodium_example;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.zoffcc.applications.ranzodium.Ranzodium;

import androidx.annotation.Nullable;

public class MainActivity extends Activity
{
    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Ranzodium dummy = new Ranzodium(); // to load the JNI library
        final String jni_version_string = Ranzodium.getNativeLibGITHASH();
        final String libsodium_version_string = Ranzodium.libsodium_version();
        Ranzodium.init();

        TextView t = this.findViewById(R.id.text_window);
        t.setText("" + jni_version_string + "\n" +
                  libsodium_version_string + "\n" +
                  "random value = " + Ranzodium.get_random(10_000));
        t.setVisibility(View.VISIBLE);
    }
}
